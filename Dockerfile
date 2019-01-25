FROM ruby:2.6.0-slim

MAINTAINER Europeana Foundation <development@europeana.eu>

RUN apt-get update
RUN apt-get install -q -y build-essential nodejs libpq-dev git

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD bundle exec puma -C config/puma.rb -v
