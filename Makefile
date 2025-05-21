up:
	docker-compose up -d

down:
	docker-compose down

ssh-apisix:
	docker-compose exec -it apisix bash

ssh-etcd:
	docker-compose exec -it etcd bash