# Europeana Portal with Collections

[![Build Status](https://travis-ci.org/europeana/europeana-portal-collections.svg?branch=develop)](https://travis-ci.org/europeana/europeana-portal-collections) [![Security](https://hakiri.io/github/europeana/europeana-portal-collections/develop.svg)](https://hakiri.io/github/europeana/europeana-portal-collections/develop) [![Maintainability](https://api.codeclimate.com/v1/badges/8510097c5de246ac62f9/maintainability)](https://codeclimate.com/github/europeana/europeana-portal-collections/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/8510097c5de246ac62f9/test_coverage)](https://codeclimate.com/github/europeana/europeana-portal-collections/test_coverage)

Europeana Portal with Collections as a Rails + 
[Blacklight](https://github.com/projectblacklight/blacklight) application.

## Requirements

* Ruby 2.5
* PostgreSQL 9.4+
* Redis
* S3-compatible object storage
* ImageMagick
* A key for the Europeana REST API, available from:
  http://labs.europeana.eu/api/registration/

## Installation

* Download the source code
* Run `bundle install`

## Quick Start with Docker

1. Install the gem bundle: `bundle install`
2. Generate Docker configuration files: `bundle exec bin/portal dockerize development`
   You will be prompted to enter your Europeana API key. For another environment
   than `development`, e.g. `profiling`, use its name in this command.
3. Bring it up: `docker-compose up`
4. Setup the database: `bundle exec rake db:setup`
5. Start the app: `bundle exec foreman start`
6. Open the app: http://localhost:3000/

### Test environment

To add a test environment to Docker:

1. Generate Docker configuration files: `bundle exec bin/portal dockerize test`
   You will be prompted to enter your Europeana API key.
2. Setup the database: `RAILS_ENV=test bundle exec rake db:setup`


## Configuration

### Environment variables

Most configuration settings are read from environment variables, described in
detail in [.env.example](.env.example).

In development and test environments, these can be placed in a 
[.env](https://github.com/bkeepers/dotenv) file in your application root.

### Database

1. Create a PostgreSQL database, and set its URL in the environment variable
  `DATABASE_URL`.
2. Initialize the database: `bundle exec rake db:setup`

### Testing

Create a test database and initialise with `bundle exec rake db:test:prepare`

Use the command `bundle exec rspec` from the project root to run the RSpec
tests.

The integration tests use Firefox in headless mode.

### Benchmarking

A script is included to run various benchmarks from
[derailed_benchmarks](https://github.com/schneems/derailed_benchmarks):
* Size of bundled gems in production environment
* Memory allocation and IPS of search results and record pages

First ensure that you have initialised a `profiling` environment, and have
services running, e.g. by following the "Quick Start with Docker" instructions
above.

Run benchmarks with: `bin/benchmark`

### File storage

Files are stored using Paperclip. To configure it, create config/paperclip.yml
with any options required to configure your file storage system, e.g. fog.

In a development environment, copy the provided sample from
[deploy/development/config/paperclip.yml](deploy/development/config/paperclip.yml).

### Cache store

If the file config/redis.yml exists, the application will use Redis as a cache
store.

### Site Administration/Users

Site content and some other "configuration" is managed through the cms.
The cms by default is available at `[hostname]/portal/en/cms/`

To login and perform certain actions, an admin user account is required.
To set up an admin user, run:

`bundle exec rake user:create EMAIL=you@example.com PASSWORD=REPLACE ROLE=admin`

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

Follow the [Europeana Ruby development guide](https://github.com/europeana/europeana-dev-guides/blob/develop/ruby.md).

## License

Licensed under the EUPL V.1.2.

For full details, see [LICENSE.md](LICENSE.md).
