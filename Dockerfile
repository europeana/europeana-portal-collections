FROM ruby:2.6.0-slim

MAINTAINER Europeana Foundation <development@europeana.eu>

RUN apt-get update
RUN apt-get install -q -y build-essential nodejs libpq-dev git libcurl3

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

ENTRYPOINT ["bundle", "exec", "puma"]
CMD ["-C", "config/puma.rb", "-v"]
