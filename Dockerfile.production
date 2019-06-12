# Build and run Europeana Portal for production use

FROM ruby:2.6.0-slim

MAINTAINER Europeana Foundation <development@europeana.eu>

ENV RAILS_ENV production
ENV BUNDLE_WITHOUT development:test:doc:localeapp:profiling
ENV PORT 80

WORKDIR /app

COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
      build-essential git nodejs \
      libcurl3 libpq-dev file imagemagick && \
    echo "gem: --no-document" >> /etc/gemrc && \
    bundle install --deployment --without ${BUNDLE_WITHOUT} --jobs=4 --retry=4 && \
    rm -rf vendor/bundle/ruby/2.6.0/bundler/gems/*/.git && \
    rm -rf vendor/bundle/ruby/2.6.0/cache && \
    rm -rf /root/.bundle && \
    apt-get remove -y -q --purge build-essential git && \
    apt-get autoremove -y -q && \
    rm -rf /var/lib/apt/lists/*

# Copy code
COPY . .

# Precompile assets
RUN DATABASE_URL=postgres://postgres@localhost/portal \
    SECRET_KEY_BASE=dummy-key \
    RAILS_RELATIVE_URL_ROOT=/portal \
    bundle exec rake assets:precompile

EXPOSE 80

ENTRYPOINT ["bundle", "exec", "puma"]
CMD ["-C", "config/puma.rb", "-v"]
