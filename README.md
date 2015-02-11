# Europeana Channels

Europeana Channels as a Rails + [Blacklight](https://github.com/projectblacklight/blacklight)
application.

## Requirements

* Ruby 2.2
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
You can use `bunde exec rake secret` to generate a secure secret key.

#### EUROPEANA_API_KEY

This is the API key used by the application to authenticate requests to the
Europeana REST API. One can be obtained at: http://labs.europeana.eu/api/registration/

### Database

1. Configure the database in config/database.yml (see
  http://guides.rubyonrails.org/configuring.html#configuring-a-database)
2. Initialize the database: `bundle exec rake db:setup`

### Channels

For each Channel, create a YAML file in config/channels/. See the bundled 
files in that directory for example configuration settings.
