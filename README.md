# Europeana Channels

Europeana Channels as a Rails + Blacklight application.

## Requirements

* Ruby >= 1.9
* A key for the Europeana REST API, available from:
  http://labs.europeana.eu/api/registration/

## Installation

* Download the source code
* Run `bundle install`

## Configuration

### Secrets

Copy config/secrets.yml.example to config/secrets.yml and edit to contain:
* `secret_key_base`: generated with `bundle exec rake secret`
* `europeana_api_key`: your Europeana API key

### Database

1. Configure the database in config/database.yml (see
  http://guides.rubyonrails.org/configuring.html#configuring-a-database)
2. Initialize the database: `bundle exec rake db:setup`

### Channels

For each Channel, create a YAML file in config/channels/. See the bundled 
files in that directory for example configuration settings.
