# Europeana Channels

[![Build Status](https://travis-ci.org/europeana/europeana-channels-blacklight.svg?branch=master)](https://travis-ci.org/europeana/europeana-channels-blacklight) [![Coverage Status](https://coveralls.io/repos/europeana/europeana-channels-blacklight/badge.svg?branch=188-coveralls)](https://coveralls.io/r/europeana/europeana-channels-blacklight?branch=master) [![security](https://hakiri.io/github/europeana/europeana-channels-blacklight/master.svg)](https://hakiri.io/github/europeana/europeana-channels-blacklight/master)

Europeana Channels as a Rails + 
[Blacklight](https://github.com/projectblacklight/blacklight) application.

## License

Licensed under the EUPL V.1.1.

For full details, see [LICENSE.md](LICENSE.md).

## Requirements

* Ruby 2.2.2
* A key for the Europeana REST API, available from:
  http://labs.europeana.eu/api/registration/

## Installation

* Download the source code
* Run `bundle install`

## Configuration

### Environment variables

Most configuration settings are read from environment variables, described in
detail below.

In development and test environments, these can be placed in a 
[.env](https://github.com/bkeepers/dotenv) file in your application root.

#### SECRET_KEY_BASE

Your secret key is used for verifying the integrity of signed cookies.
If you change this key, all old signed cookies will become invalid!

Make sure the secret is at least 30 characters and all random,
no regular words or you'll be exposed to dictionary attacks.
You can use `bundle exec rake secret` to generate a secure secret key.

#### EUROPEANA_API_KEY

This is the API key used by the application to authenticate requests to the
Europeana REST API. One can be obtained at:
http://labs.europeana.eu/api/registration/

#### EUROPEANA_API_URL

The base URL of the Europeana API. This only needs to be set if you are not
using the live production version of the API.

#### EUROPEANA_STYLEGUIDE_CDN

The base URL of the Europeana styleguide from which images, stylesheets and
javascripts will be loaded.

#### EDM_IS_SHOWN_BY_PROXY

The HTTP address of a proxy capabable of receiving Europeana record IDs as URL
paths, looking up edm:isShownBy for that record, and downloading the target to
the user agent.

#### PORT

This sets the TCP port on which the Puma web server will listen for HTTP
connections. If unset, it will default to 3000.

#### RACK_ENV

The application environment to run, i.e. development, test or production.
Defaults to development.

#### WEB_CONCURRENCY

The number of Puma workers to run. Defaults to 2.

#### MAX_THREADS

The number of threads to run per Puma worker. Defaults to 5.

#### LOCALEAPP_API_KEY

The Localeapp API key to retrieve locale files from a localeapp.com project.

**NB:** This is only required on a deployment where translations are to be
retrieved from localeapp.com in order to update the repo. This should be part
of an automated build workflow, and so a typical development or production
deployment will not require this API key.

### Database

1. Create a MySQL database, and configure in config/database.yml (see
  http://guides.rubyonrails.org/configuring.html#configuring-a-database)
2. Include a "test" section in the database configuration if you 
  plan on running the unit and integration tests
3. Initialize the database: `bundle exec rake db:setup`

### Channels

For each Channel, create a YAML file in config/channels/. See the bundled 
files in that directory for example configuration settings.


### Testing

Use the command `bundle exec rspec` from the project root to run the RSpec
tests.

The integration tests use the poltergeist gem which has an external dependency
on phantomjs. See here for installation instructions:
https://github.com/teampoltergeist/poltergeist/tree/v1.6.0#installing-phantomjs


### Cache store

If the file config/redis.yml exists, the application will use Redis as a cache
store.

Example configuration:

```yaml
# config/redis.yml
development:
  host: <%= ENV['REDIS_HOST'] || 'localhost' %>
  port: <%= ENV['REDIS_PORT'] || 6379 %>
  name: <%= ENV['REDIS_NAME'] || 'redis' %>

test:
  host: <%= ENV['REDIS_HOST'] || 'localhost' %>
  port: <%= ENV['REDIS_PORT'] || 6379 %>
  name: <%= ENV['REDIS_NAME'] || 'redis' %>

production:
  host: <%= JSON.parse( ENV['VCAP_SERVICES'] )['redis-2.2'].first['credentials']['hostname'] rescue 'localhost' %>
  port: <%= JSON.parse( ENV['VCAP_SERVICES'] )['redis-2.2'].first['credentials']['port'] rescue 6379 %>
  password:  <%= JSON.parse( ENV['VCAP_SERVICES'] )['redis-2.2'].first['credentials']['password'] rescue '' %>
  name: <%= JSON.parse( ENV['VCAP_SERVICES'] )['redis-2.2'].first['credentials']['name'] rescue 'redis' %>
```

## Usage

Run the app with the Puma web server: `bundle exec puma -C config/puma.rb`

By default, Puma will listen on the port defined in the `PORT` environment
variable, or 3000 by default.

## Contributing

Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide),
checking your code for compliance with [Rubocop](https://github.com/bbatsov/rubocop).

A quick summary of coding conventions:
* Use two spaces for indentation
* Do not leave trailing white space at the end of any line
* Underscore variable names
* Use Ruby 1.9 Hash keys
