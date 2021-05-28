# include build mode env file
BUILD_MODE_ENV_FILE=./docker/.build.mode.env
include $(BUILD_MODE_ENV_FILE)
export $(shell sed 's/=.*//' $(BUILD_MODE_ENV_FILE))


###### command list ########

# manual-builded-godwoken binary need this based-image to run
manual-image:
	cd docker/manual-image && docker build -t ${DOCKER_MANUAL_BUILD_IMAGE_NAME} .

build-image: SHELL:=/bin/bash
build-image:
	cp docker/layer2/Dockerfile.example docker/layer2/Dockerfile
	if [ "$(MANUAL_BUILD_GODWOKEN)" = true ] ; then \
		source ./gw_util.sh && update_godwoken_dockerfile_to_manual_mode ; \
	fi
# todo: remove env file when build image through cleanning web3 dockerfile 
	cd docker && docker-compose build --no-rm 

gen-submodule-env: SHELL:=/bin/bash
gen-submodule-env:
	source gw_util.sh && generateSubmodulesEnvFile

update-submodule: SHELL:=/bin/bash
update-submodule:
	source ./gw_util.sh && update_submodules	

install: SHELL:=/bin/bash
install:
	source ./gw_util.sh && init_submodule_if_empty
	docker run --rm -v `pwd`/godwoken-examples:/app -w=/app $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG yarn
# if manual build web3
	if [ "$(MANUAL_BUILD_WEB3)" = true ] ; then \
		docker run --rm -v `pwd`/godwoken-web3:/app -w=/app $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG /bin/bash -c "yarn; yarn workspace @godwoken-web3/godwoken tsc; yarn workspace @godwoken-web3/api-server tsc" ; \
	fi
# if manual build godwoken
	if [ "$(MANUAL_BUILD_GODWOKEN)" = true ] ; then \
		docker run --rm -it -v `pwd`/godwoken:/app -v `pwd`/cargo-cache-data:/root/.cargo/registry -w=/app retricsu/godwoken-manual-build cargo build ; \
	fi
# if manual build godwoken-polyjuice
	if [ "$(MANUAL_BUILD_POLYJUICE)" = true ] ; then \
		make rebuild-polyjuice-bin ; \
	else make copy-polyjuice-bin-from-docker ; \
	fi
# if manual build godwoken-scripts
	if [ "$(MANUAL_BUILD_SCRIPTS)" = true ] ; then \
		make rebuild-gw-scripts-and-bin ; \
	else make copy-gw-scripts-and-bin-from-docker ; \
	fi
# if manual build clerkb for POA
	if [ "$(MANUAL_BUILD_CLERKB)" = true ] ; then \
		make rebuild-poa-scripts ; \
	elif [ "$(DOCKER_PREBUILD_IMAGE_TAG)" > "v0.2.4" ]; then \
		make copy-poa-scripts-from-docker ; \
	else "prebuild image version is lower than v0.2.5, there is no poa scripts in docker. use poa scripts in config folder. do nothing." ; \
	fi

init:
	make install
	mkdir -p godwoken-polyjuice/build
	mkdir -p ./godwoken/deploy
	cp ./config/private_key ./godwoken/deploy/private_key
	sh ./docker/layer2/init_config_json.sh
# prepare lumos config file (if not exists) for polyjuice
	[ -e "godwoken-examples/packages/runner/configs/lumos-config.json" ] && echo 'lumos-config file exits' || cp ./config/lumos-config.json ./godwoken-examples/packages/runner/configs/
# cp godwoken/c/ scripts => TODO: use /scripts in $$DOCKER_PREBUILD_IMAGE_NAME image
	cp -r ./config/scripts ./godwoken/
	cp ./config/meta-contract-validator ./godwoken/godwoken-scripts/c/build/meta-contract-validator
	cp ./config/meta-contract-generator ./godwoken/godwoken-scripts/c/build/meta-contract-generator 
	cp ./config/sudt-validator ./godwoken/godwoken-scripts/c/build/sudt-validator 
	cp ./config/sudt-generator ./godwoken/godwoken-scripts/c/build/sudt-generator
	cp ./config/polyjuice-generator godwoken-polyjuice/build/generator
	cp ./config/polyjuice-validator godwoken-polyjuice/build/validator
# build image for docker-compose build cache
	make build-image

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
	cd docker && docker-compose down

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
	cd docker && docker-compose logs -f web3

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

clean:
# FIXME: clean needs sudo privilage
	rm -rf ckb-data/data
	rm -rf ckb-cli-data/*
	[ -e "indexer-data/ckb-indexer-data" ] && rm -rf indexer-data/ckb-indexer-data || echo 'file not exits.'
	[ -e "indexer-data/indexer-log" ] && rm indexer-data/indexer-log || echo 'file not exits.'
	[ -e "godwoken-examples/packages/runner" ] && cd godwoken-examples/packages/runner && rm -rf db && rm -rf temp-db || echo 'file not exits.'
	rm -rf postgres-data/*
# prepare brand new lumos config file for polyjuice
	[ -e "godwoken-examples/packages/runner" ] && cp config/lumos-config.json godwoken-examples/packages/runner/configs/ || echo 'file not exits.'
# delete the godwoken outdated config file as well
	rm -f godwoken/config.toml 
	rm -f godwoken/deploy/*-result.json

smart-clean:
	rm -rf ckb-cli-data/*
	[ -e "indexer-data/ckb-indexer-data" ] && rm -rf indexer-data/ckb-indexer-data || echo 'file not exits.'
	[ -e "indexer-data/indexer-log" ] && rm indexer-data/indexer-log || echo 'file not exits.'
	[ -e "godwoken-examples/packages/runner" ] && cd godwoken-examples/packages/runner && rm -rf db && rm -rf temp-db  || echo 'file not exits.'
	rm -rf postgres-data/*	

uninit:
	make down
	make clean
	rm -rf godwoken
	rm -rf godwoken-polyjuice
	rm -rf godwoken-examples
	rm -rf godwoken-web3

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

status:
	cd docker && docker-compose ps


clean-polyjuice:
	cd godwoken-examples && yarn clean

reset-polyjuice:
	make stop-polyjuice
	make clean-polyjuice	
	make start-polyjuice

start-godwoken:
	cd docker && docker-compose start godwoken

build-godwoken:
	docker run --rm -it -v `pwd`/godwoken:/app -v `pwd`/cargo-cache-data:/root/.cargo/registry -w=/app retricsu/godwoken-manual-build cargo build

clean-cargo-cache:
	rm -rf cargo-cache-data

prepare-money:
	cd godwoken-examples && yarn clean &&  yarn prepare-money:normal

########### manual-build-mode #############
### rebuild components's scripts and bin all in one
rebuild-scripts:
	make rebuild-polyjuice-bin
	make rebuild-gw-scripts-and-bin 
	make rebuild-poa-scripts

#### rebuild components's scripts and bin standalone
rebuild-polyjuice-bin:
	cd godwoken-polyjuice && make all-via-docker
	cp godwoken-polyjuice/build/generator_log config/polyjuice-generator
	cp godwoken-polyjuice/build/validator_log config/polyjuice-validator	

rebuild-gw-scripts-and-bin:
	cd godwoken-scripts && cd c && make && cd - && capsule build --release --debug-output
	cp godwoken-scripts/c/build/meta-contract-generator config/meta-contract-generator
	cp godwoken-scripts/c/build/meta-contract-validator config/meta-contract-validator	
	cp godwoken-scripts/c/build/sudt-generator config/sudt-generator	
	cp godwoken-scripts/c/build/sudt-validator config/sudt-validator
	cp godwoken-scripts/build/release/* config/scripts/release/	

rebuild-poa-scripts:
	cd clerkb && yarn && make all-via-docker
	cp clerkb/build/debug/poa config/scripts/release/
	cp clerkb/build/debug/state config/scripts/release/

########## prebuild-quick-mode #############
copy-polyjuice-bin-from-docker:	
	mkdir -p `pwd`/quick-mode/polyjuice
	docker run -it -d --name dummy $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG
	docker cp dummy:/scripts/godwoken-polyjuice/. `pwd`/quick-mode/polyjuice
	docker rm -f dummy
# paste the prebuild bin to config dir for use
	cp quick-mode/polyjuice/generator_log config/polyjuice-generator
	cp quick-mode/polyjuice/validator_log config/polyjuice-validator	

copy-gw-scripts-and-bin-from-docker:
	mkdir -p `pwd`/quick-mode/godwoken
	docker run -it -d --name dummy $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG
	docker cp dummy:/scripts/godwoken-scripts/. `pwd`/quick-mode/godwoken
	docker rm -f dummy
# paste the prebuild bin to config dir for use	
	cp quick-mode/godwoken/meta-contract-generator config/meta-contract-generator
	cp quick-mode/godwoken/meta-contract-validator config/meta-contract-validator	
	cp quick-mode/godwoken/sudt-generator config/sudt-generator	
	cp quick-mode/godwoken/sudt-validator config/sudt-validator
# paste the prebuild scripts to config dir for use
	cp quick-mode/godwoken/withdrawal-lock config/scripts/release/
	cp quick-mode/godwoken/eth-account-lock config/scripts/release/
	cp quick-mode/godwoken/stake-lock config/scripts/release/
	cp quick-mode/godwoken/challenge-lock config/scripts/release/
	cp quick-mode/godwoken/state-validator config/scripts/release/
	cp quick-mode/godwoken/custodian-lock config/scripts/release/
	cp quick-mode/godwoken/deposition-lock config/scripts/release/
	cp quick-mode/godwoken/always-success config/scripts/release/

copy-poa-scripts-from-docker:
	mkdir -p `pwd`/quick-mode/clerkb
	docker run -it -d --name dummy $$DOCKER_PREBUILD_IMAGE_NAME:$$DOCKER_PREBUILD_IMAGE_TAG
	docker cp dummy:/scripts/clerkb/. `pwd`/quick-mode/clerkb
	docker rm -f dummy
# paste the prebuild scripts to config dir for use	
	cp quick-mode/clerkb/* config/scripts/release/
