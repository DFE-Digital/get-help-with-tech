[![Build Status](https://travis-ci.org/DFE-Digital/get-help-with-tech.svg?branch=master)](https://travis-ci.com/DFE-Digital/get-help-with-tech)

# Get Help With Tech

An app to host content and forms for the "Get Help With Tech" COVID-19 response initiative.

## Prerequisites

- Ruby 2.6.3
- PostgreSQL
- NodeJS >= 12.13.x
- Yarn >= 1.12.x

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
4. Run `bundle exec rails server` to launch the app on http://localhost:3000
5. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets


## Running specs
```
bundle exec rspec
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rubocop app config db lib spec Gemfile --format clang -a

or

bundle exec scss-lint app/webpacker/styles
```
## Static analysis for security issues

```bash
bundle exec brakeman
```

 All the above are run automatically on Travis CI when pushing a PR

## Integrations

[GOV.UK Notify](https://www.notifications.service.gov.uk/) for sending emails

## Deploying on GOV.UK PaaS

### Prerequisites

- Your department, agency or team has a GOV.UK PaaS account
- You have a personal account granted by your organisation manager
- You have downloaded and installed the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) for your platform
- You have downloaded and installed [Docker Desktop](https://docs.docker.com/desktop/)

### The deployment process

1. [Sign in to Cloud Foundry](https://docs.cloud.service.gov.uk/get_started.html#sign-in-to-cloud-foundry) (using either your GOV.UK PaaS account or single sign-on, once you've enabled it for your account)
2. Run `docker login` to log in to Docker Hub
3. Run `make dev build push deploy` to build, push and deploy the Docker image to GOV.UK PaaS development instance
4. Test on https://get-help-with-tech-dev.london.cloudapps.digital
5. Run `make staging promote FROM=dev` to deploy the -dev image to staging
7. Test on https://get-help-with-tech-staging.london.cloudapps.digital
8. Run `make prod promote FROM=staging` to deploy to production
10. Test on https://get-help-with-tech-prod.london.cloudapps.digital

The app should be available at https://get-help-with-tech-(dev|staging|prod).london.cloudapps.digital

## Environment variables

Some values are configurable with environment variables:

Name                                             |Description                                                                                                                                 |Default
-------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|-------
GHWT__SIGN_IN_TOKEN_TTL_SECONDS                  |Sign-in tokens will expire after this many seconds                                                                                          |600
GHWT__HTTP_BASIC_AUTH__USERNAME                  |Username for HTTP Basic authentication - only has an effect if the `http_basic_auth` FeatureFlag is set                                     |(nil)
GHWT__HTTP_BASIC_AUTH__PASSWORD                  |Password for HTTP Basic authentication - only has an effect if the `http_basic_auth` FeatureFlag is set                                     |(nil)
GHWT__GOVUK_NOTIFY__API_KEY                      |API key for the GOV.UK Notify service, used for sending emails                                                                              |REQUIRED
GHWT__HOSTNAME_FOR_URLS                          |Hostname used for generating URLs in emails                                                                                                 |http://localhost:3000/
GHWT__GOVUK_NOTIFY__TEMPLATES__SIGN_IN_TOKEN_MAIL|ID of the template in GOV.UK Notify used for mailing sign-in tokens                                                                         |'89b4abbb-0f01-4546-bf30-f88db5e0ae3c'
GHWT__STATIC_FILE_CACHE_TTL                      |how long CDNs and browsers should cache static assets for in production, in seconds.                                                        |(nil)
GHWT__THROTTLE__*                                |Request throttling limits, see [settings.yaml](config/settings.yml) for more info                                                           |_(see settings)_
GHWT__LOGSTASH__HOST                             | Hostname for where logstash should send logs                                                           | (nil)
GHWT__LOGSTASH__PORT                             | Port for where logstash should send logs                                                               | (nil)

See the [settings.yaml file](config/settings.yml) for full details on configurable options.

### Feature Flags

Certain aspects of app behaviour are governed by a minimal implementation of Feature Flags.
These are activated by having an environment variable FEATURES_(flag name) set to 'active', for example:

```
# start the rails server with debug info rendered into the footer
FEATURES_show_debug_info=active bundle exec rails s
```

The available flags are listed in `app/services/feature_flag.rb`, and available in the constant `FeatureFlag::FEATURES`. Each one is tested with a dedicated spec in `spec/features/feature_flags/`.

To set / unset environment variables on GOV.UK PaaS, use the commands:

```
# set an env var
cf set-env (app name) (environment variable name) (value)

# For example:
cf set-env get-help-with-tech-prod FEATURES_show_debug_info active

# To unset the var:
cf unset-env (app name) (environment variable name)

# For example:
cf unset-env get-help-with-tech-prod FEATURES_show_debug_info
```

## Operations

Some service steps can only be carried out using the Rails console. To get to the console on GOV.UK PaaS:

### Running the Rails console

Log on to the container with:
```
make (env) ssh
```

Once you have a prompt on the container, you'll need to run this command - this will launch a subshell with the correct environment variables and in the app's root directory:
```
./setup_env_for_rails_app
```

In this subshell, you can then launch the console in the normal way:
```
bundle exec rails c
```

### Viewing Logs

Tail the logs for a given env:

```sh
make (env) logs
```

View recent logs for a given env:

```sh
make (env) logs-recent
```

### Log Aggregration

[Semantic Logger](https://logger.rocketjob.io/rails.html) is used to generate
single-line logs. In production environments, when `RAILS_LOG_TO_STDOUT` is
enabled, this is configured to output JSON logs. These logs are then sent to the
log aggregator.

#### Development

You can configure logstash to send logs to your log aggregator by setting the
[logstash host and port environment variables](#environment-variables).

#### Logstash Configuration

A copy of the [logstash filter](etc/logstash-filter.conf) we use exists in the
repo. This has to be installed manually in the log aggregator to be used.

