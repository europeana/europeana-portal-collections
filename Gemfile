source 'https://rubygems.org'

ruby '2.2.1'
gem 'rails', '4.2.1'

# Use Europeana's REST API as the Blacklight catalog data source
gem 'europeana-blacklight',
  require: 'europeana/blacklight',
  github: 'europeana/europeana-blacklight',
  ref: '52f7ab4'

gem 'europeana-api',
  require: 'europeana/api',
  github: 'rwd/europeana-api-client-ruby',
  ref: '102e7dc'

# Use the Europeana styleguide for UI components (templates)
gem 'europeana-styleguide',
  git: 'https://github.com/europeana/europeana-styleguide-ruby.git',
  ref: '0241e1ce97'

# Use a forked version of stache with a downstream fix, until merged upstream
# @see https://github.com/agoragames/stache/pull/53
gem 'stache', github: 'rwd/stache', ref: 'd1408f1'

# pending merge of https://github.com/projectblacklight/blacklight/pull/1210
gem 'blacklight',
  github: 'rwd/blacklight', ref: '5132db4'
gem 'eventmachine', '~> 1.0.6' # Ruby 2.2 compatible version
gem 'feedjira', '~> 2.0'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mysql2'
gem 'puma', '~> 2.11.0'
gem 'redis-rails', '~> 4.0'
gem 'sass-rails', '~> 4.0.3'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'capybara', '~> 2.4.0'
  gem 'dotenv-rails', '~> 1.0.2'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'rails_best_practices', require: false
  gem 'rspec-rails', '~> 3.0'
  gem 'rubocop', '~> 0.29.1', require: false
end

group :development do
  gem 'spring', '~> 1.3.6'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'simplecov', require: false
  gem 'webmock', '~> 1.21.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :localeapp do
  gem 'localeapp', '~> 0.9.0'
end
