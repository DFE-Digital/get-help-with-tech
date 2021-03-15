APP_NAME=get-help-with-tech
REMOTE_DOCKER_IMAGE_NAME=dfedigital/get-help-with-tech
PAAS_ORGANISATION=dfe
PAAS_SPACE=get-help-with-tech

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
				logs logs-recent remote-docker-tags push-tag rollback-to timestamp-latest setup_ssh_params \
				setup_scp_params

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
	cf update-service $(APP_NAME)-$(env_stub)-cdn-route -c '{"headers": ["Content-Type", "Host", "Set-Cookie", "X-Forwarded-Host", "Authorization"]}'

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

push: require_env_stub timestamp-latest ## push the Docker image to Docker Hub
	docker tag $(APP_NAME)-$(env_stub) $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):latest
	docker push $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):latest

timestamp-latest: require_env_stub
	docker pull $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):latest
	$(eval export timestamp_tag=replaced-at-$(shell (date -u +%Y%m%d-%H%M%S)))
	docker tag  $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):latest $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):$(timestamp_tag)
	docker push $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):$(timestamp_tag)

remote-docker-tags: require_env_stub
	@curl -L -s 'https://registry.hub.docker.com/v2/repositories/$(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub)/tags?page_size=1024' |jq -r '."results"[]["name"]'

push-tag: require_env_stub timestamp-latest ## pull a remote tag, re-tag it as :latest and push it to Docker Hub
	@test ${TAG} || (echo ">> TAG is not set (${TAG})- please use make push-tag TAG=(some tag that already exists on Docker Hub)."; echo "You can list all existing tags with: \nmake $(env_stub) remote-docker-tags"; exit 1)
	docker pull $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):${TAG}
	docker tag  $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):${TAG} $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):latest
	docker push $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub):latest

deploy: set_cf_target set_docker_image_id ## Deploy the docker image to gov.uk PaaS
	cf push $(APP_NAME)-$(env_stub) --manifest ./config/manifests/${env_stub}-manifest.yml --var docker_image_id=$(DOCKER_IMAGE_ID) --docker-image $(REMOTE_DOCKER_IMAGE_NAME)-$(env_stub) --docker-username ${CF_DOCKER_USERNAME} --strategy rolling

set_docker_image_id: require_env_stub
	# The Github action will pass in DOCKER_IMAGE_ID from a previous step
	# So we take that value if given, otherwise pull the latest image and get it
	# from that
	$(eval DOCKER_IMAGE_ID ?= $(shell (docker pull ${REMOTE_DOCKER_IMAGE_NAME}-${env_stub}:latest > /dev/null) && docker images ${REMOTE_DOCKER_IMAGE_NAME}-${env_stub}:latest -q) )

release: require_env_stub
	make ${env_stub} build push deploy

rollback-to: require_env_stub ## rollback to a given TAG, which must already exist on Docker Hub
	@test ${TAG} || (echo ">> TAG is not set (${TAG})- please use make rollback-to TAG=(some tag that already exists on Docker Hub)."; echo "You can list all existing tags with: \nmake $(env_stub) remote-docker-tags"; exit 1)
	make ${env_stub} push-tag TAG=${TAG}
	make ${env_stub} deploy

promote:
	@test ${FROM} || (echo ">> FROM is not set (${FROM})- please use make promote FROM=(dev|staging|prod)"; exit 1)
	docker pull $(REMOTE_DOCKER_IMAGE_NAME)-$(FROM)
	docker tag $(REMOTE_DOCKER_IMAGE_NAME)-$(FROM) $(APP_NAME)-$(env_stub)
	make $(env_stub) push deploy

ssh: set_cf_target setup_ssh_params
	@echo "\nTo get a Rails console, run: \nunset RAILS_LOG_TO_STDOUT\nbundle exec rails c\n\n" && \
		cf $(CF_V3_PREFIX)ssh $(APP_NAME)-$(env_stub) --process $(PROCESS) -i $(INSTANCE)

logs: set_cf_target
	cf logs $(APP_NAME)-$(env_stub)

logs-recent: set_cf_target
	cf logs --recent $(APP_NAME)-$(env_stub)

setup_ssh_params:
	$(eval export PROCESS ?= 'sidekiq')
	$(eval export INSTANCE ?= '0')
	@echo "\nConnecting to $(PROCESS) instance $(INSTANCE)"

setup_scp_params: set_cf_target setup_ssh_params
	$(eval export PROCESS ?= 'sidekiq')
	$(eval export INSTANCE ?= '0')
	$(eval export sshpass = $(shell (cf ssh-code)))
	$(eval export app_guid = $(shell (cf app $(APP_NAME)-$(env_stub) --guid)))
	$(eval export process_guid=$(shell (cf curl /v3/apps/$(app_guid)/processes | jq -r '.resources | map(select(.type == "$(PROCESS)") | .guid)[$(INSTANCE)]')))
	@echo "\n\n*** Enter ${sshpass} at the password prompt (this is a one-time-only password) ***\n"

download: setup_scp_params
	@test ${REMOTE_PATH} || (echo ">> REMOTE_PATH is not set (${REMOTE_PATH})- please use make (env) download REMOTE_PATH=(some path to download from) LOCAL_PATH=(path to download to) PROCESS=(process name - defaults to sidekiq) INSTANCE=(instance number - defaults to 0)"; exit 1)
	@test ${LOCAL_PATH} || (echo ">> FROM is not set (${FROM})- please use make (env) download REMOTE_PATH=(some path to download from) LOCAL_PATH=(path to download to) PROCESS=(process name - defaults to sidekiq) INSTANCE=(instance number - defaults to 0)"; exit 1)
	scp -P 2222 -o StrictHostKeyChecking=no -o User=cf:${process_guid}/0 ssh.london.cloud.service.gov.uk:$(REMOTE_PATH) $(LOCAL_PATH)

upload: setup_scp_params
	@test ${REMOTE_PATH} || (echo ">> REMOTE_PATH is not set (${REMOTE_PATH})- please use make (env) upload REMOTE_PATH=(remote path to upload to) LOCAL_PATH=(local path to upload from) PROCESS=(process name - defaults to sidekiq) INSTANCE=(instance number - defaults to 0)"; exit 1)
	@test ${LOCAL_PATH} || (echo ">> FROM is not set (${FROM})- please use make (env) upload REMOTE_PATH=(remote path to upload to) LOCAL_PATH=(local path to upload from) PROCESS=(process name - defaults to sidekiq) INSTANCE=(instance number - defaults to 0)"; exit 1)
	scp -P 2222 -o StrictHostKeyChecking=no -o User=cf:${process_guid}/0 $(LOCAL_PATH) ssh.london.cloud.service.gov.uk:$(REMOTE_PATH)
