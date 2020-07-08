APP_NAME=get-help-with-tech
REMOTE_DOCKER_IMAGE_NAME=dfedigital/get-help-with-tech
PAAS_ORGANISATION=dfe-teacher-services
PAAS_SPACE=get-help-with-tech

.PHONY: dev staging prod
dev:
	$(eval export env_stub=dev)
	$(eval export db_plan=tiny-unencrypted-11)
	@true

staging:
	$(eval export env_stub=staging)
	$(eval export db_plan=tiny-unencrypted-11)
	@true

prod:
	$(eval export env_stub=prod)
	$(eval export db_plan=small-ha-11)
	@true

.PHONY: require_env_stub build push deploy setup_paas_env setup_paas_db setup_paas_app promote ssh \
				logs logs-recent

require_env_stub:
	@test ${env_stub} || (echo ">> env_stub is not set (${env_stub})- please use make dev|staging|prod (task)"; exit 1)

get_git_status:
	$(eval export git_commit_sha=$(shell git rev-parse --short HEAD))
	$(eval export git_branch=$(shell git rev-parse --abbrev-ref HEAD))
	@true

setup_paas_db: set_cf_target
	cf create-service postgres $(db_plan) $(APP_NAME)-$(env_stub)-db

setup_paas_app: set_cf_target
	cf scale $(APP_NAME)-$(env_stub) -k 2G

set_cf_target: require_env_stub
	cf target -o $(PAAS_ORGANISATION) -s $(PAAS_SPACE)-$(env_stub)

setup_paas_env: set_cf_target
	cf set-env $(APP_NAME)-$(env_stub) RAILS_ENV production
	cf set-env $(APP_NAME)-$(env_stub) RAILS_SERVE_STATIC_FILES true
	bin/rails secret | xargs cf set-env $(APP_NAME)-$(env_stub) SECRET_KEY_BASE
	cf restage $(APP_NAME)-$(env_stub)

build: require_env_stub get_git_status ## Create & tag a new docker image
	docker build -t $(APP_NAME)-$(env_stub) --build-arg GIT_COMMIT_SHA=$(git_commit_sha) --build-arg GIT_BRANCH=$(git_branch) .

push: require_env_stub ## push the Docker image to Docker Hub
	docker tag $(APP_NAME)-$(env_stub) $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub)
	docker push $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub)

deploy: set_cf_target ## Deploy the docker image to gov.uk PaaS
	cf v3-apply-manifest -f ./config/manifests/$(env_stub)-manifest.yml
	cf v3-zdt-push $(APP_NAME)-$(env_stub) --docker-image $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub) --wait-for-deploy-complete

release: require_env_stub
	make ${env_stub} build push deploy

promote:
	@test ${FROM} || (echo ">> FROM is not set (${FROM})- please use make promote FROM=(dev|staging|prod)"; exit 1)
	docker pull $(REMOTE_DOCKER_IMAGE_NAME)-$(FROM)
	docker tag $(REMOTE_DOCKER_IMAGE_NAME)-$(FROM) $(APP_NAME)-$(env_stub)
	make $(env_stub) push deploy

ssh: set_cf_target
	@echo "\n\nTo get a Rails console, run: \n./setup_env_for_rails_app \nbundle exec rails c\n\n" && \
		cf v3-ssh $(APP_NAME)-$(env_stub)

logs: set_cf_target
	cf logs $(APP_NAME)-$(env_stub)

logs-recent: set_cf_target
	cf logs --recent $(APP_NAME)-$(env_stub)
