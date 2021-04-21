build-docker:
	cd docker && docker build -t retricsu/gowoken-build_dev:ubuntu20 .

install:
	git submodule update --init --recursive

init:
	make install
	cd godwoken/godwoken-scripts/c && make all-via-docker
	cd godwoken-polyjuice && make all-via-docker
	cd docker/init && docker-compose up
	
start:
	cd docker && docker-compose up -d

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
	cd docker && docker-compose logs -f polyjuice

# show godwoken
sg:
	cd docker && docker-compose logs -f godwoken

# show ckb-indexer
si:
	cd docker && docker-compose logs -f ckb-indexer

clean:
	rm -rf ckb-data/data
	rm -rf ckb-cli-data/*
	[ -e "indexer-data/ckb-indexer-data" ] && rm -rf indexer-data/ckb-indexer-data || echo 'file not exits.'
	[ -e "indexer-data/indexer-log" ] && rm indexer-data/indexer-log || echo 'file not exits.'
	cd godwoken-examples/packages/runner && rm -rf db && rm -rf temp-db

re-init:
	make down
	rm -rf ckb-data
	rm -rf godwoken
	rm -rf godwoken-polyjuice
	rm -rf godwoken-examples
	rm -rf lumos
	make init

enter-g:
	cd docker && docker-compose exec godwoken bash

test:
	docker run -t -d --name testimage retricsu/gowoken-build_dev:ubuntu20 
	docker exec -it testimage bash 

test-rpc:
	./scripts/test_rpc.sh

gen-schema:
	cd docker && docker-compose up gen-godwoken-schema

clean-schema:
	cd docker/gen-godwoken-schema && rm -rf schemas/*
