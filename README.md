# Europeana Channels

Europeana Channels as a Rails + 
[Blacklight](https://github.com/projectblacklight/blacklight) application.

## License

Licensed under the EUPL V.1.1.

For full details, see [LICENSE.md](LICENSE.md).

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
You can use `bundle exec rake secret` to generate a secure secret key.

#### EUROPEANA_API_KEY

This is the API key used by the application to authenticate requests to the
Europeana REST API. One can be obtained at:
http://labs.europeana.eu/api/registration/

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

### Database

1. Create a MySQL database, and configure in config/database.yml (see
  http://guides.rubyonrails.org/configuring.html#configuring-a-database)
2. Include a "development" section in the database configuration if you 
  plan on running the unit and integration tests
3. Initialize the database: `bundle exec rake db:setup`

### Channels

For each Channel, create a YAML file in config/channels/. See the bundled 
files in that directory for example configuration settings.


### Testing

Use the command `rpec` from the project root to run the unit tests.

Use the command `rspec spec/features` from the project root to run the integration tests.

The integration tests use the poltergeist gem which has an external dependency on phantomjs.  This can be installed on Linux with the following commands:


```shell

# dependecies

sudo apt-get update
sudo apt-get install build-essential chrpath libssl-dev libxft-dev
sudo apt-get install libfreetype6 libfreetype6-dev
sudo apt-get install libfontconfig1 libfontconfig1-dev


# download & unpack

cd ~
export PHANTOM_JS="phantomjs-1.9.8-linux-x86_64"
wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
sudo tar xvjf $PHANTOM_JS.tar.bz2


# add to path

sudo mv $PHANTOM_JS /usr/local/share
sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

# test it works

phantomjs --version

```

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
