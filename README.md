# Europeana Channels

Europeana Channels as a Rails + Blacklight application.

## Requirements

* Ruby >= 1.9
* An key for the Europeana REST API, available from:
  http://labs.europeana.eu/api/registration/

## Installation

* Download the source code
* Run `bundle install`

## Configuration

### Database

1. Configure the database in config/database.yml
2. Initialize the database: `bundle exec rake db:setup`

### Secrets

Create config/secrets.yml containing:
* `:secret_key_base`: generated with `bundle exec rake secret`
* `:europeana_api_key`: your Europeana API key

