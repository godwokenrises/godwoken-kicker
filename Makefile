build-docker:
	cd docker && docker build -t retricsu/gowoken-build_dev:ubuntu20 .

install:
	git submodule update --init --recursive

init:
	make install
#	cd godwoken/godwoken-scripts/c && make all-via-docker
# 	todo: should build this file instead of copying later.
#	cd godwoken-polyjuice && make all-via-docker
	mkdir -p godwoken-polyjuice/build && cp config/polyjuice-generator godwoken-polyjuice/build/generator 
	cd docker/init && docker-compose up 
	
start:
	cd docker && docker-compose up -d

start-f:
	cd docker && docker-compose --env-file .force.new.chain.env  up -d	

re-start:
	cd docker && docker-compose restart

stop:
	cd docker && docker-compose stop

# stop godwoken
exit-g:
	cd docker && docker-compose stop godwoken

# run godwoken only start or exit ./godwoken
# run-g:
#	cd docker && docker-compose 


pause:
	cd docker && docker-compose pause

unpause:
	cd docker && docker-compose unpause

down:
	cd docker/init && docker-compose down
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

clean:
	rm -rf ckb-data/data
	rm -rf ckb-cli-data/*
	[ -e "indexer-data/ckb-indexer-data" ] && rm -rf indexer-data/ckb-indexer-data || echo 'file not exits.'
	[ -e "indexer-data/indexer-log" ] && rm indexer-data/indexer-log || echo 'file not exits.'
	cd godwoken-examples/packages/runner && rm -rf db && rm -rf temp-db
	rm -rf postgres-data/*
# prepare brand new lumos config file for polyjuice
	cp config/lumos-config.json godwoken-examples/packages/runner/configs/
# delete the godwoken outdated config file as well
	rm -f godwoken/config.toml 
	rm -f godwoken/deploy/*-result.json

smart-clean:
	rm -rf ckb-cli-data/*
	[ -e "indexer-data/ckb-indexer-data" ] && rm -rf indexer-data/ckb-indexer-data || echo 'file not exits.'
	[ -e "indexer-data/indexer-log" ] && rm indexer-data/indexer-log || echo 'file not exits.'
	cd godwoken-examples/packages/runner && rm -rf db && rm -rf temp-db
	rm -rf postgres-data/*	

re-init:1
	make down
	rm -rf ckb-data
	rm -rf godwoken
	rm -rf godwoken-polyjuice
	rm -rf godwoken-examples
	rm -rf lumos
	make init

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

test-con:
	./testParseConfig.sh

prepare-money:
	cd godwoken-examples && yarn clean &&  yarn prepare-money:normal

rebuild-scripts:
	make prepare-prebuild-scripts
	make paste-prebuild-scripts 

prepare-prebuild-scripts:
#	make install
	cd godwoken/godwoken-scripts && cd c && make && cd - && capsule build --release --debug-output
	cd godwoken-polyjuice && make all-via-docker

paste-prebuild-scripts:
	cp godwoken/godwoken-scripts/c/build/meta-contract-generator config/meta-contract-generator
	cp godwoken/godwoken-scripts/c/build/meta-contract-validator config/meta-contract-validator	
	cp godwoken/godwoken-scripts/c/build/sudt-generator config/sudt-generator	
	cp godwoken/godwoken-scripts/c/build/sudt-validator config/sudt-validator
	cp godwoken/godwoken-scripts/build/release/* config/scripts/release/
	cp godwoken-polyjuice/build/generator_log config/polyjuice-generator
	cp godwoken-polyjuice/build/validator_log config/polyjuice-validator

