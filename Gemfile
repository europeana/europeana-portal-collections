source 'https://rubygems.org'

gem 'rails', '4.2.4'

gem 'europeana-styleguide', github: 'europeana/europeana-styleguide-ruby', ref: '9708dff'

# Use a forked version of stache with downstream changes, until merged upstream
# @see https://github.com/agoragames/stache/pulls/rwd
gem 'stache', github: 'europeana/stache', branch: 'europeana-styleguide'

gem 'rails_admin_globalize_field', github: 'rwd/rails_admin_globalize_field',
  branch: 'globalize-5-rails-4.2'

gem 'aasm', '~> 4.2'
gem 'actionpack-action_caching'
gem 'blacklight', '~> 5.15'
gem 'cancancan', '~> 1.12'
gem 'clockwork', '~> 1.2'
gem 'colorize'
gem 'delayed_job_active_record', '~> 4.0.3'
gem 'devise', '~> 3.5'
gem 'europeana-blacklight', '~> 0.3.1', github: 'europeana/europeana-blacklight', ref: 'fb216cd'
gem 'europeana-api', '~> 0.4.1'
gem 'feedjira', '~> 2.0'
gem 'fog', '~> 1.33'
gem 'globalize', '~> 5.0'
gem 'globalize-versioning', github: 'globalize/globalize-versioning'
gem 'htmlcompressor', '0.2'
gem 'nokogiri', '~> 1.6.6.4'
gem 'pg'
gem 'paperclip', '~> 4.3'
gem 'paper_trail', '~> 4.0'
gem 'puma', '~> 2.13'
gem 'rails_admin', '~> 0.7.0'
gem 'redis-rails', '~> 4.0'
gem 'redis-rails-instrumentation'
gem 'sass-rails'

group :production do
  gem 'rails_12factor', '~> 0.0.3'
  gem 'uglifier', '~> 2.7.2'
end

group :development, :test do
  # gem 'brakeman', require: false # @todo add to CI suite
  gem 'dotenv-rails', '~> 2.0'
  # gem 'rails_best_practices', require: false # @todo add to CI suite
  gem 'rspec-rails', '~> 3.0'
  gem 'rubocop', '0.29.1', require: false # only update when Hound does
end

group :development do
  gem 'foreman'
  gem 'spring', '~> 1.3.6'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'capybara', '~> 2.4.0'
  gem 'coveralls', require: false
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'selenium-webdriver', '~> 2.47'
  gem 'shoulda-matchers', '~> 2.8', require: false
  gem 'simplecov', require: false
  gem 'webmock', '~> 1.21.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :localeapp do
  gem 'localeapp', '~> 0.9.0'
end
