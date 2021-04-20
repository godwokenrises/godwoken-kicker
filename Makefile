build-docker:
	cd docker && docker build -t retricsu/gowoken-build_dev:ubuntu20 .

install:
	git submodule update --init --recursive

init:
	make install
#	cd godwoken-polyjuice && make all-via-docker
	cd docker/init && docker-compose up
	
start:
	cd docker && docker-compose up -d

stop:
	cd docker && docker-compose stop

pause:
	cd docker && docker-compose pause

unpause:
	cd docker && docker-compose unpause

down:
	cd docker/init && docker-compose down
	cd docker && docker-compose down

show-polyjuice:
	cd docker && docker-compose logs -f polyjuice

show-godwoken:
	cd docker && docker-compose logs -f godwoken

show-indexer:
	cd docker && docker-compose logs -f ckb-indexer

clean:
	rm -rf ckb-data/data
	cd godwoken-examples/packages/runner && rm -rf db && rm -rf temp-db

re-init:
	make down
	rm -rf ckb-data
	rm -rf godwoken
	rm -rf godwoken-examples
	rm -rf lumos
	make init

test:
	docker run -t -d --name testimage retricsu/gowoken-build_dev:ubuntu20 
	docker exec -it testimage bash 