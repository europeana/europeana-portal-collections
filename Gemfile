source 'https://rubygems.org'

ruby '2.2.2'
gem 'rails', '4.2.3'

gem 'europeana-styleguide',
  git: 'https://github.com/europeana/europeana-styleguide-ruby.git',
  ref: '2eb1f49084'


# Use a forked version of stache with downstream changes, until merged upstream
# @see https://github.com/agoragames/stache/pulls/rwd
gem 'stache', github: 'rwd/stache', ref: '819ff88'

# pending merge of https://github.com/projectblacklight/blacklight/pull/1210
gem 'blacklight', '~> 5.14.0'
gem 'clockwork', '~> 1.2'
gem 'delayed_job_active_record', '~> 4.0.3'
gem 'europeana-api', '~> 0.3.4'
gem 'europeana-blacklight', '0.2.5'
gem 'feedjira', '~> 2.0'
gem 'fog'
gem 'htmlcompressor'
gem 'mysql2'
gem 'paperclip', '~> 4.3'
gem 'puma', '~> 2.11.0'
gem 'redis-rails', '~> 4.0'

group :production do
  gem 'rails_12factor', '~> 0.0.3'
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
end

group :development, :test do
  # gem 'brakeman', require: false # @todo add to CI suite
  gem 'dotenv-rails', '~> 1.0.2'
  # gem 'rails_best_practices', require: false # @todo add to CI suite
  gem 'rspec-rails', '~> 3.0'
  gem 'rubocop', '0.29.1', require: false
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
  gem 'selenium-webdriver'
  gem 'webmock', '~> 1.21.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :localeapp do
  gem 'localeapp', '~> 0.9.0'
end
