##
# Rake tasks for Cloud Foundry deployments
namespace :cf do
  desc 'Only run on the first application instance'
  # Use like `bundle exec rake cf:on_first_instance db:migrate && bundle exec rails s`
  # @see https://docs.cloudfoundry.org/buildpacks/ruby/ruby-tips.html#migrate-ruby-db
  task :on_first_instance do
    instance_index = JSON.parse(ENV['VCAP_APPLICATION'])['instance_index'] rescue nil
    exit 0 unless instance_index == 0
  end
end
