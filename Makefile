APP_NAME=data-allowances-prototype
REMOTE_DOCKER_IMAGE_NAME=dfedigital/data-allowances-prototype

.PHONY: build
build: ## Create & tag a new docker image
	docker build -t $(APP_NAME) .

.PHONY: push
push: ## push the Docker image to Docker Hub
	docker tag $(APP_NAME) $(REMOTE_DOCKER_IMAGE_NAME)
	docker push $(REMOTE_DOCKER_IMAGE_NAME)

.PHONY: deploy
deploy: ## Deploy the docker image to gov.uk PaaS
	cf push $(APP_NAME) --docker-image $(REMOTE_DOCKER_IMAGE_NAME)

.PHONY: release
release:
	make build push deploy
