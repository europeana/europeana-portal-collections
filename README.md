# Europeana Portal with Collections

[![Build Status](https://travis-ci.org/europeana/europeana-portal-collections.svg?branch=develop)](https://travis-ci.org/europeana/europeana-portal-collections) [![Coverage Status](https://coveralls.io/repos/github/europeana/europeana-portal-collections/badge.svg?branch=develop)](https://coveralls.io/github/europeana/europeana-portal-collections?branch=develop) [![security](https://hakiri.io/github/europeana/europeana-portal-collections/develop.svg)](https://hakiri.io/github/europeana/europeana-portal-collections/develop) [![Dependency Status](https://gemnasium.com/europeana/europeana-portal-collections.svg)](https://gemnasium.com/europeana/europeana-portal-collections)

Europeana Portal with Collections as a Rails + 
[Blacklight](https://github.com/projectblacklight/blacklight) application.

## License

Licensed under the EUPL V.1.1.

For full details, see [LICENSE.md](LICENSE.md).

## Requirements

* Ruby 2 (latest stable version recommended)
* ImageMagick
* A key for the Europeana REST API, available from:
  http://labs.europeana.eu/api/registration/
* PostgreSQL

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

#### EUROPEANA_STYLEGUIDE_ASSET_HOST

The base URL of the Europeana styleguide from which images, stylesheets and
javascripts will be loaded.

#### EUROPEANA_MEDIA_PROXY

The HTTP address of a proxy capabable of receiving Europeana record IDs as URL
paths, looking up web resources for that record, and downloading the target to
the user agent. See [Europeana::Proxy::Media](https://github.com/europeana/europeana-proxy-ruby).

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

1. Create a PostgreSQL database, and configure in config/database.yml (see
  http://guides.rubyonrails.org/configuring.html#configuring-a-database)
2. Include a "test" section in the database configuration if you 
  plan on running the unit and integration tests
3. Initialize the database: `bundle exec rake db:setup`

### Testing

Use the command `bundle exec rspec` from the project root to run the RSpec
tests.

The integration tests use the poltergeist gem which has an external dependency
on phantomjs. See here for installation instructions:
https://github.com/teampoltergeist/poltergeist/tree/v1.6.0#installing-phantomjs

### File storage

Files are stored using Paperclip. To configure it, create config/paperclip.yml
with any options required to configure your file storage system, e.g. fog.

In a development environment, the following will suffice:

```yaml
# config/paperclip.yml
development:
  storage: :filesystem
```

### Cache store

If the file config/redis.yml exists, the application will use Redis as a cache
store.

Example configurations for different environments are in [deploy/](deploy/).

## Usage

The application consists of three components:

1. Web: `bundle exec puma -C config/puma.rb`

  By default, Puma will listen on the port defined in the `PORT` environment
  variable, or 3000 by default.
2. Worker: `bundle exec rake jobs:work`
3. Scheduler: `bundle exec clockwork lib/clock.rb`

The commands for these components are declared in the [Procfile](Procfile).

In production, if your environment supports it you can use this Procfile.
Otherwise, you will need to configure deployment scripts to run each process.

In development, you can launch the application with all processes using foreman:
`foreman start`

## Contributing

Follow the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide),
checking your code for compliance with [Rubocop](https://github.com/bbatsov/rubocop).

A quick summary of coding conventions:
* Use two spaces for indentation
* Do not leave trailing white space at the end of any line
* Underscore variable names
* Use Ruby 1.9 Hash keys
