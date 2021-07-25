# include build mode env file
BUILD_MODE_ENV_FILE=./docker/.build.mode.env
include $(BUILD_MODE_ENV_FILE)
export $(shell sed 's/=.*//' $(BUILD_MODE_ENV_FILE))

ifndef VERBOSE
.SILENT:
endif


.PHONY: ckb

###### command list ########

# manual-builded-godwoken binary need this based-image to run
manual-image:
	cd docker/manual-image && docker build -t ${DOCKER_MANUAL_BUILD_IMAGE_NAME} .

pass-godwoken-binary: SHELL:=/bin/bash
pass-godwoken-binary:
	mkdir -p `pwd`/workspace/bin
	printf "godwoken "
	source ./gw_util.sh && paste_binary_into_path `pwd`/workspace/bin/godwoken
	printf "gw-tools "
	source ./gw_util.sh && paste_binary_into_path `pwd`/workspace/bin/gw-tools	

create-folder:
	mkdir -p workspace/deploy/backend
	mkdir -p workspace/deploy/polyjuice-backend
	mkdir -p workspace/scripts/release

install: SHELL:=/bin/bash
install:
# if manual build polyman
	if [ "$(MANUAL_BUILD_POLYMAN)" = true ] ; then \
		source ./gw_util.sh && prepare_package godwoken-polyman $$POLYMAN_GIT_URL $$POLYMAN_GIT_CHECKOUT ; \
		docker run --rm -v `pwd`/packages/godwoken-polyman:/app -w=/app $$DOCKER_JS_PREBUILD_IMAGE_NAME:$$DOCKER_JS_PREBUILD_IMAGE_TAG yarn ; \
	fi
# if manual build web3
	if [ "$(MANUAL_BUILD_WEB3)" = true ] ; then \
		source ./gw_util.sh && prepare_package godwoken-web3 $$WEB3_GIT_URL $$WEB3_GIT_CHECKOUT ; \
		docker run --rm -v `pwd`/packages/godwoken-web3:/app -w=/app $$DOCKER_JS_PREBUILD_IMAGE_NAME:$$DOCKER_JS_PREBUILD_IMAGE_TAG /bin/bash -c "yarn; yarn workspace @godwoken-web3/godwoken tsc; yarn workspace @godwoken-web3/api-server tsc" ; \
	fi
# if manual build godwoken
	if [ "$(MANUAL_BUILD_GODWOKEN)" = true ] ; then \
		source ./gw_util.sh && prepare_package godwoken $$GODWOKEN_GIT_URL $$GODWOKEN_GIT_CHECKOUT ; \
		source ./gw_util.sh && cargo_build_local_or_docker ; \
		make copy-godwoken-binary-from-packages-to-workspace ; \
	fi
# if skip build godwoken, using paste mode
	if [ "$(MANUAL_BUILD_GODWOKEN)" = "skip" ] ; then \
		printf '%b\n' "skip godwoken building.." ; \
	fi
# if manual build godwoken-polyjuice
	if [ "$(MANUAL_BUILD_POLYJUICE)" = true ] ; then \
		source ./gw_util.sh && prepare_package godwoken-polyjuice $$POLYJUICE_GIT_URL $$POLYJUICE_GIT_CHECKOUT ; \
		cd packages/godwoken-polyjuice && git submodule update --init --recursive && cd ../.. ; \
		make rebuild-polyjuice-bin ; \
	else make copy-polyjuice-bin-from-docker ; \
	fi
# if manual build godwoken-scripts
	if [ "$(MANUAL_BUILD_SCRIPTS)" = true ] ; then \
		source ./gw_util.sh && prepare_package godwoken-scripts $$SCRIPTS_GIT_URL $$SCRIPTS_GIT_CHECKOUT ; \
		make rebuild-gw-scripts-and-bin ; \
	else make copy-gw-scripts-and-bin-from-docker ; \
	fi
# if manual build clerkb for POA
	if [ "$(MANUAL_BUILD_CLERKB)" = true ] ; then \
		source ./gw_util.sh && prepare_package clerkb $$CLERKB_GIT_URL $$CLERKB_GIT_CHECKOUT ; \
		make rebuild-poa-scripts ; \
	else \
		source ./gw_util.sh && copy_poa_scripts_from_docker_or_abort ;\
	fi

uninstall:
	rm -rf packages/*

clean:
# FIXME: clean needs sudo privilage
	rm -rf cache/activity/*
	rm -rf workspace/*
# prepare brand new lumos config file for polyman 
	[ -e "packages/godwoken-polyman/packages/runner" ] && cp config/lumos-config.json packages/godwoken-polyman/packages/runner/configs/ || : 
	echo "remove cache data from activities."

clean-build-cache:
	rm -rf cache/build/*

init:
	make create-folder
	cp ./config/private_key ./workspace/deploy/private_key
	sh ./docker/layer2/init_config_json.sh
	cp docker/layer2/Dockerfile.example docker/layer2/Dockerfile
# build image for docker-compose build cache
	make build-image

build-image: SHELL:=/bin/bash
build-image: 
	if [ "$(MANUAL_BUILD_GODWOKEN)" = true ] || [ "$(MANUAL_BUILD_GODWOKEN)" = "skip" ]; then \
		source ./gw_util.sh && update_godwoken_dockerfile_to_manual_mode ; \
	fi
	make install
	cd docker && docker-compose build --no-rm 	


start: 
	cd docker && FORCE_GODWOKEN_REDEPLOY=false docker-compose --env-file .build.mode.env up -d --build

start-f:
	cd docker && FORCE_GODWOKEN_REDEPLOY=true docker-compose --env-file .build.mode.env up -d --build

restart:
	cd docker && docker-compose restart

stop:
	cd docker && docker-compose stop

pause:
	cd docker && docker-compose pause

unpause:
	cd docker && docker-compose unpause

down:
	cd docker && docker-compose down --remove-orphans

# show polyjuice
sp:
	cd docker && docker-compose logs -f --tail 200 polyjuice

# show godwoken
sg:
	cd docker && docker-compose logs -f --tail 200 godwoken

stop-godwoken:
	cd docker && docker-compose stop godwoken

stop-polyjuice:
	cd docker && docker-compose stop polyjuice

start-polyjuice:
	cd docker && docker-compose start polyjuice

# show ckb-indexer
si:
	cd docker && docker-compose logs -f ckb-indexer

web3:
	cd docker && docker-compose logs -f --tail 200 web3

stop-web3:
	cd docker && docker-compose stop web3

start-web3:
	cd docker && docker-compose start web3

enter-web3:
	cd docker && docker-compose exec web3 bash

ckb:
	cd docker && docker-compose logs -f --tail 200 ckb

stop-ckb:
	cd docker && docker-compose stop ckb

start-ckb:
	cd docker && docker-compose start ckb

enter-ckb:
	cd docker && docker-compose exec ckb bash

enter-db:
	cd docker && docker-compose exec postgres bash

enter-g:
	cd docker && docker-compose exec godwoken bash

enter-p:
	cd docker && docker-compose exec polyjuice bash	

test:
	docker run -t -d --name testimage retricsu/gowoken-build_dev:ubuntu20 
	docker exec -it testimage bash 

test-rpc:
	./scripts/test_rpc.sh

test-web3-rpc:
	./scripts/test_web3_rpc.sh

gen-schema:
	make clean-schema
	cd docker && docker-compose up gen-godwoken-schema

clean-schema:
	cd docker/gen-godwoken-schema && rm -rf schemas/*

prepare-schema-for-polyman:
	make gen-schema
	cp -r ./docker/gen-godwoken-schema/schemas ./godwoken-polyman/packages/godwoken/

prepare-schema-for-provider:
	make gen-schema
	cp -r ./docker/gen-godwoken-schema/schemas/godwoken.* ./polyjuice-providers-http/src/godwoken/
	mv ./polyjuice-providers-http/src/godwoken/godwoken.d.ts ./polyjuice-providers-http/src/godwoken/schemas/index.d.ts	
	mv ./polyjuice-providers-http/src/godwoken/godwoken.esm.js ./polyjuice-providers-http/src/godwoken/schemas/index.esm.js	
	mv ./polyjuice-providers-http/src/godwoken/godwoken.js ./polyjuice-providers-http/src/godwoken/schemas/index.js	
	mv ./polyjuice-providers-http/src/godwoken/godwoken.json ./polyjuice-providers-http/src/godwoken/schemas/index.json	

prepare-schema-for-web3:
	make gen-schema
	cp -r ./docker/gen-godwoken-schema/schemas/godwoken.* ./godwoken-web3/packages/godwoken/
	mv ./godwoken-web3/packages/godwoken/godwoken.d.ts ./godwoken-web3/packages/godwoken/schemas/index.d.ts	
	mv ./godwoken-web3/packages/godwoken/godwoken.esm.js ./godwoken-web3/packages/godwoken/schemas/index.esm.js	
	mv ./godwoken-web3/packages/godwoken/godwoken.js ./godwoken-web3/packages/godwoken/schemas/index.js	
	mv ./godwoken-web3/packages/godwoken/godwoken.json ./godwoken-web3/packages/godwoken/schemas/index.json

status:
	cd docker && docker-compose ps


clean-polyjuice:
	cd godwoken-polyman && yarn clean

reset-polyjuice:
	make stop-polyjuice
	make clean-polyjuice	
	make start-polyjuice

call-polyman:
	cd docker && docker-compose logs -f call-polyman

start-godwoken:
	cd docker && docker-compose start godwoken

build-godwoken:
	docker run --rm -it -v `pwd`/godwoken:/app -v `pwd`/cargo-cache-data:/root/.cargo/registry -w=/app retricsu/godwoken-manual-build cargo build

clean-cargo-cache:
	rm -rf cargo-cache-data

prepare-money:
	cd godwoken-polyman && yarn clean &&  yarn prepare-money:normal

########### manual-build-mode #############
### rebuild components's scripts and bin all in one
rebuild-scripts:
	make rebuild-gw-scripts-and-bin 
	make rebuild-polyjuice-bin
	make rebuild-poa-scripts

#### rebuild components's scripts and bin standalone
rebuild-polyjuice-bin:
	cd packages/godwoken-polyjuice && make all-via-docker
	cp packages/godwoken-polyjuice/build/validator_log workspace/scripts/release/polyjuice-validator
	cp packages/godwoken-polyjuice/build/generator_log workspace/deploy/polyjuice-backend/polyjuice-generator
	cp packages/godwoken-polyjuice/build/validator_log workspace/deploy/polyjuice-backend/polyjuice-validator	

rebuild-gw-scripts-and-bin:
	cd packages/godwoken-scripts && cd c && make && cd - && capsule build --release --debug-output
	cp packages/godwoken-scripts/build/release/* workspace/scripts/release/
	cp packages/godwoken-scripts/c/build/meta-contract-validator workspace/scripts/release/	
	cp packages/godwoken-scripts/c/build/meta-contract-generator workspace/deploy/backend/meta-contract-generator
	cp packages/godwoken-scripts/c/build/meta-contract-validator workspace/deploy/backend/meta-contract-validator	
	cp packages/godwoken-scripts/c/build/sudt-validator workspace/scripts/release/ 
	cp packages/godwoken-scripts/c/build/sudt-generator workspace/deploy/backend/sudt-generator	
	cp packages/godwoken-scripts/c/build/sudt-validator workspace/deploy/backend/sudt-validator

rebuild-poa-scripts:
	cd packages/clerkb && yarn && make all-via-docker
	cp packages/clerkb/build/debug/poa workspace/scripts/release/
	cp packages/clerkb/build/debug/state workspace/scripts/release/

########## prebuild-quick-mode #############
copy-polyjuice-bin-from-docker:	
	mkdir -p `pwd`/quick-mode/polyjuice
	docker run -it -d --name dummy $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG
	docker cp dummy:/scripts/godwoken-polyjuice/. `pwd`/quick-mode/polyjuice
	docker rm -f dummy
# paste the prebuild bin to config dir for use
	cp quick-mode/polyjuice/generator_log workspace/deploy/polyjuice-backend/polyjuice-generator
	cp quick-mode/polyjuice/validator_log workspace/deploy/polyjuice-backend/polyjuice-validator	

copy-gw-scripts-and-bin-from-docker:
	mkdir -p `pwd`/quick-mode/godwoken
	docker run -it -d --name dummy $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG
	docker cp dummy:/scripts/godwoken-scripts/. `pwd`/quick-mode/godwoken
	docker rm -f dummy
# paste the prebuild bin to config dir for use	
	cp quick-mode/godwoken/meta-contract-generator config/meta-contract-generator
	cp quick-mode/godwoken/meta-contract-validator config/meta-contract-validator	
	cp quick-mode/godwoken/sudt-generator workspace/deploy/backend/sudt-generator	
	cp quick-mode/godwoken/sudt-validator workspace/deploy/backend/sudt-validator
# paste the prebuild scripts to config dir for use
	cp quick-mode/godwoken/withdrawal-lock workspace/scripts/release/
	cp quick-mode/godwoken/eth-account-lock workspace/scripts/release/
	cp quick-mode/godwoken/tron-account-lock workspace/scripts/release/
	cp quick-mode/godwoken/stake-lock workspace/scripts/release/
	cp quick-mode/godwoken/challenge-lock workspace/scripts/release/
	cp quick-mode/godwoken/state-validator workspace/scripts/release/
	cp quick-mode/godwoken/custodian-lock workspace/scripts/release/
	cp quick-mode/godwoken/deposit-lock workspace/scripts/release/
	cp quick-mode/godwoken/always-success workspace/scripts/release/

copy-poa-scripts-from-docker:
	mkdir -p `pwd`/quick-mode/clerkb
	docker run -it -d --name dummy $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG
	docker cp dummy:/scripts/clerkb/. `pwd`/quick-mode/clerkb
	docker rm -f dummy
# paste the prebuild scripts to config dir for use	
	cp quick-mode/clerkb/* workspace/scripts/release/

copy-godwoken-binary-from-packages-to-workspace:
	mkdir -p workspace/bin
	cp packages/godwoken/target/debug/godwoken workspace/bin/godwoken
	cp packages/godwoken/target/debug/gw-tools workspace/bin/gw-tools
