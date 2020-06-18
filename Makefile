APP_NAME=get-help-with-tech
REMOTE_DOCKER_IMAGE_NAME=dfedigital/get-help-with-tech

.PHONY: dev staging prod
dev:
	$(eval export env_stub=dev)
	@true

staging:
	$(eval export env_stub=staging)
	@true

prod:
	$(eval export env_stub=prod)
	@true

.PHONY: require_env_stub build push deploy
require_env_stub:
	test ${env_stub} || (echo ">> env_stub is not set (${env_stub})- please use make dev|staging|prod (task)"; exit 1)

build: require_env_stub ## Create & tag a new docker image
	docker build -t $(APP_NAME)-$(env_stub) .

push: require_env_stub ## push the Docker image to Docker Hub
	docker tag $(APP_NAME)-$(env_stub) $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub)
	docker push $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub)

deploy: require_env_stub ## Deploy the docker image to gov.uk PaaS
	ls -l ./manifest.yml && rm ./manifest.yml
	ln -s ./config/manifests/$(env_stub)-manifest.yml ./manifest.yml
	cf push $(APP_NAME)-$(env_stub) --docker-image $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub)
	rm ./manifest.yml

release: require_env_stub
	make ${env_stub} build push deploy
