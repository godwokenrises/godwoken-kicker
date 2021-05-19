# if env file exits, include it.
MANUAL_ENV_FILE=./docker/.manual.build.list.env
ifneq ($(wildcard $(MANUAL_ENV_FILE)),)
    include $(MANUAL_ENV_FILE)
	export $(shell sed 's/=.*//' $(MANUAL_ENV_FILE))
endif


###### command list ########

# manual-builded-godwoken binary need this based-image to run
build-manual:
	cd build-manual && docker build -t retricsu/godwoken-manual-build .

build-image: SHELL:=/bin/bash
build-image:
	cp docker/layer2/Dockerfile.example docker/layer2/Dockerfile
	if [ "$(MANUAL_BUILD_GODWOKEN)" = true ] ; then \
		source ./gw_util.sh && update_godwoken_dockerfile_to_manual_mode ; \
	fi
# pass the env file if exisit	
	if [ -f ".manual.build.list.env" ] ; then \
		cd docker && docker-compose build --no-rm --env-file .manual.build.list.env ;\
	else cd docker && docker-compose build --no-rm ;\
	fi 

gen-submodule-env: SHELL:=/bin/bash
gen-submodule-env:
	source gw_util.sh && generateSubmodulesEnvFile

update-submodule: SHELL:=/bin/bash
update-submodule:
	source ./gw_util.sh && update_submodules	

install: SHELL:=/bin/bash
install:
	git submodule update --init --recursive
	docker run --rm -v `pwd`/godwoken-examples:/app -w=/app nervos/godwoken-prebuilds:v0.2.0-rc2 yarn
# if manual build web3
	if [ "$(MANUAL_BUILD_WEB3)" = true ] ; then \
		docker run --rm -v `pwd`/godwoken-web3:/app -w=/app nervos/godwoken-prebuilds:v0.2.0-rc2 /bin/bash -c "yarn; yarn workspace @godwoken-web3/godwoken tsc" ; \
	fi
# if manual build godwoken
# todo: add cache improving repeat build speed
	if [ "$(MANUAL_BUILD_GODWOKEN)" = true ] ; then \
		docker run --rm -v `pwd`/godwoken:/app \
		 -w=/app retricsu/godwoken-manual-build cargo build ; \
	fi

init:
	make install
	mkdir -p godwoken-polyjuice/build
	mkdir -p ./godwoken/deploy
	cp ./config/private_key ./godwoken/deploy/private_key
	sh ./docker/layer2/init_config_json.sh
# prepare lumos config file (if not exists) for polyjuice
	[ -e "godwoken-examples/packages/runner/configs/lumos-config.json" ] && echo 'lumos-config file exits' || cp ./config/lumos-config.json ./godwoken-examples/packages/runner/configs/
# cp godwoken/c/ scripts => TODO: use /scripts in nervos/godwoken-prebuilds image
	cp -r ./config/scripts ./godwoken/
	cp ./config/meta-contract-validator ./godwoken/godwoken-scripts/c/build/meta-contract-validator
	cp ./config/meta-contract-generator ./godwoken/godwoken-scripts/c/build/meta-contract-generator 
	cp ./config/sudt-validator ./godwoken/godwoken-scripts/c/build/sudt-validator 
	cp ./config/sudt-generator ./godwoken/godwoken-scripts/c/build/sudt-generator
	cp ./config/polyjuice-generator godwoken-polyjuice/build/generator
	cp ./config/polyjuice-validator godwoken-polyjuice/build/validator
# build image for docker-compose build cache
	make build-image

start: SHELL:=/bin/bash	
start: 
# pass the env file if exisit	
	if [ -f ".manual.build.list.env" ] ; then \
		cd docker && docker-compose up -d --build --env-file .manual.build.list.env ;\
	else cd docker && docker-compose up -d --build ;\
	fi 

start-f: SHELL:=/bin/bash
start-f:
# pass the env file if exisit	
	if [ -f ".manual.build.list.env" ] ; then \
		cd docker && docker-compose --env-file .force.new.chain.env --env-file .manual.build.list.env up -d --build ;\
	else cd docker && docker-compose --env-file .force.new.chain.env up -d --build ;\
	fi

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

prepare-money:
	cd godwoken-examples && yarn clean &&  yarn prepare-money:normal

rebuild-scripts:
	make prepare-prebuild-scripts
	make paste-prebuild-scripts 

prepare-prebuild-scripts:
	git submodule update --init --recursive
	cd godwoken-scripts && cd c && make && cd - && capsule build --release --debug-output
	cd godwoken-polyjuice && make all-via-docker

paste-prebuild-scripts:
	cp godwoken-scripts/c/build/meta-contract-generator config/meta-contract-generator
	cp godwoken-scripts/c/build/meta-contract-validator config/meta-contract-validator	
	cp godwoken-scripts/c/build/sudt-generator config/sudt-generator	
	cp godwoken-scripts/c/build/sudt-validator config/sudt-validator
	cp godwoken-scripts/build/release/* config/scripts/release/
	cp godwoken-polyjuice/build/generator_log config/polyjuice-generator
	cp godwoken-polyjuice/build/validator_log config/polyjuice-validator
