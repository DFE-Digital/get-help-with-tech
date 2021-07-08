FROM ruby:3.0.2-alpine

ARG APPNAME=get-help-with-tech

USER root

# dependencies relied upon to build native-extension gems etc
RUN apk update
RUN apk add libxml2-dev libxslt-dev build-base postgresql-dev tzdata
# Fix incompatibility with slim tzdata from 2020b onwards
# see https://github.com/tzinfo/tzinfo/issues/120 for details
RUN wget https://data.iana.org/time-zones/tzdb/tzdata.zi -O /usr/share/zoneinfo/tzdata.zi && \
    /usr/sbin/zic -b fat /usr/share/zoneinfo/tzdata.zi

RUN apk add nodejs yarn postgresql-contrib libpq less git

ENV RAILS_ROOT /var/www/${APPNAME}
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

RUN addgroup deploy && adduser -S -u 1001 -s bash -D -G deploy deploy
RUN chown deploy:deploy /var/www/${APPNAME}

ENV BUNDLER_VERSION 2.2.15
RUN gem install bundler
RUN chown -R deploy:deploy /usr/local/bundle/
USER 1001

# make it easier to get a rails console when ssh-ed on
RUN echo "PATH=/usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/sbin:/usr/local/bin:${PATH}" >> /home/deploy/.profile
RUN echo "cd ${RAILS_ROOT}" >> /home/deploy/.profile
RUN chown deploy:deploy /home/deploy/.profile

# install all gems
COPY --chown=deploy:deploy Gemfile Gemfile.lock .ruby-version ./
ARG BUNDLE_FLAGS="--jobs 2"
RUN bundle config set cache_all true
RUN bundle config set without 'development test'
RUN bundle install
RUN bundle package

COPY --chown=deploy:deploy . .

# allow access to port 3000
ENV APP_PORT 3000
EXPOSE $APP_PORT

# precompile assets
RUN yarn
ARG RAILS_ENV=production
RUN RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=$(bin/rake secret) bundle exec rails webpacker:compile

# Render the 'too many requests' error page
RUN RAILS_ENV=${RAILS_ENV} SECRET_KEY_BASE=$(bin/rake secret) bundle exec rake release:render_429_to_file

# Cache the git commit sha & branch
ARG GIT_COMMIT_SHA=""
ARG GIT_BRANCH=""
ENV GIT_COMMIT_SHA=${GIT_COMMIT_SHA}
ENV GIT_BRANCH=${GIT_BRANCH}
RUN echo "[{'commit_sha': '${GIT_COMMIT_SHA}', 'branch': '${GIT_BRANCH}'}]" > ./.gitinfo.json

# run the rails server
ARG RAILS_ENV=production
CMD bundle exec rake db:migrate && bundle exec rails s -e ${RAILS_ENV} -p ${APP_PORT} --binding=0.0.0.0
