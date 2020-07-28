APP_NAME=get-help-with-tech
REMOTE_DOCKER_IMAGE_NAME=dfedigital/get-help-with-tech
PAAS_ORGANISATION=dfe-teacher-services
PAAS_SPACE=get-help-with-tech

# support CF CLI 6 as well as 7, until we're confident that everyone can run v7
$(eval export cf_major_version=$(shell cf version | grep -o -E '[0-9]+' | head -n 1))
ifeq "$(cf_major_version)" "6"
	CF_V3_PREFIX:=v3-
	CF_PUSH_TASK:=cf-6-push
else
	CF_V3_PREFIX:=
	CF_PUSH_TASK:=cf-7-push
endif

.PHONY: dev staging prod

dev:
	$(eval export env_stub=dev)
	$(eval export db_plan=tiny-unencrypted-11)
	$(eval export redis_plan=tiny-5.x)
	@true

staging:
	$(eval export env_stub=staging)
	$(eval export db_plan=tiny-unencrypted-11)
	$(eval export redis_plan=tiny-ha-5.x)
	@true

prod:
	$(eval export env_stub=prod)
	$(eval export db_plan=small-ha-11)
	$(eval export redis_plan=tiny-ha-5.x)
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

setup_cdn_route: set_cf_target
	# tell it to forward all headers from Cloudfront, otherwise we only get Host
	cf update-service $(APP_NAME)-$(env_stub)-cdn-route -c '{"headers": ["*"]}'

setup_paas_redis: set_cf_target
	cf create-service redis $(redis_plan) $(APP_NAME)-$(env_stub)-redis

setup_logit: set_cf_target
	@test ${LOGIT_ENDPOINT} || (echo ">> LOGIT_ENDPOINT is not set (${LOGIT_ENDPOINT})- please use make setup_logit LOGIT_ENDPOINT=(Logit Logstash endpoint) LOGIT_PORT=(Logit TCP-SSL port)\n\nYou can get these values from the Logit stack settings"; exit 1)
	@test ${LOGIT_PORT} || (echo ">> LOGIT_PORT is not set (${LOGIT_PORT})- please use make setup_logit LOGIT_ENDPOINT=(Logit Logstash endpoint) LOGIT_PORT=(Logit TCP-SSL port)\n\nYou can get these values from the Logit stack settings"; exit 1)
	cf create-user-provided-service logit-ssl-drain -l syslog-tls://${LOGIT_ENDPOINT}:${LOGIT_PORT}
	cf bind-service $(APP_NAME)-$(env_stub) logit-ssl-drain
	cf restage $(APP_NAME)-$(env_stub)

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
	cf $(CF_V3_PREFIX)apply-manifest -f ./config/manifests/$(env_stub)-manifest.yml
	make $(CF_PUSH_TASK)

cf-6-push:
	cf $(CF_V3_PREFIX)zdt-push $(APP_NAME)-$(env_stub) --docker-image $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub) --wait-for-deploy-complete

cf-7-push:
	cf push $(APP_NAME)-$(env_stub) --docker-image $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub) --strategy rolling

release: require_env_stub
	make ${env_stub} build push deploy

promote:
	@test ${FROM} || (echo ">> FROM is not set (${FROM})- please use make promote FROM=(dev|staging|prod)"; exit 1)
	docker pull $(REMOTE_DOCKER_IMAGE_NAME)-$(FROM)
	docker tag $(REMOTE_DOCKER_IMAGE_NAME)-$(FROM) $(APP_NAME)-$(env_stub)
	make $(env_stub) push deploy

ssh: set_cf_target
	@echo "\n\nTo get a Rails console, run: \n./setup_env_for_rails_app \nbundle exec rails c\n\n" && \
		cf $(CF_V3_PREFIX)ssh $(APP_NAME)-$(env_stub)

logs: set_cf_target
	cf logs $(APP_NAME)-$(env_stub)

logs-recent: set_cf_target
	cf logs --recent $(APP_NAME)-$(env_stub)
