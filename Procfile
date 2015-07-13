web: bundle exec rake db:migrate && bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work
scheduler: bundle exec clockwork lib/clock.rb
