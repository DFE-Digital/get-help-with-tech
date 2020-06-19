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

## Deploying on GOV.UK PaaS

### Prerequisites

- Your department, agency or team has a GOV.UK PaaS account
- You have a personal account granted by your organisation manager
- You have downloaded and installed the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) for your platform

### Deploy

1. Run `cf login -u USERNAME [--sso]`, `USERNAME` is your personal GOV.UK PaaS account email address and the optional `--sso` allows you to use a Single Sign On provider like Google.
2. Run `docker login` to log in to Docker Hub
3. Run `make (dev|staging|prod) build push deploy` to build, push and deploy the Docker image to Gov.uk PaaS

The app should be available at https://get-help-with-tech-(dev|staging|prod).london.cloudapps.digital
