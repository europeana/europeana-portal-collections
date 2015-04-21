source 'https://rubygems.org'

ruby '2.2.1'
gem 'rails', '4.2.1'

# Use Europeana's REST API as the Blacklight catalog data source
gem 'europeana-blacklight',
  require: 'europeana/blacklight',
  git: 'https://github.com/europeana/europeana-blacklight.git',
  ref: 'eff5ed4'

# Use the Europeana styleguide for UI components (templates)
gem 'europeana-styleguide',
  git: 'https://github.com/europeana/europeana-styleguide-ruby.git',
  ref: '3da7329fe9'

# Use a forked version of stache with a downstream fix, until merged upstream
# @see https://github.com/agoragames/stache/pull/53
gem 'stache',
  git: 'https://github.com/rwd/stache.git',
  ref: 'd1408f1'

gem 'blacklight', '~> 5.13.1'
gem 'coffee-rails', '~> 4.0.0'
gem 'eventmachine', '~> 1.0.6' # Ruby 2.2 compatible version
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
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'simplecov', require: false
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :localeapp do
  gem 'localeapp', '~> 0.9.0'
end
