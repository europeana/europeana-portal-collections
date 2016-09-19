# frozen_string_literal: true
YAML.load_file(File.expand_path('../data_providers.yml', __FILE__)).each do |data_provider|
  puts 'Seeding data provider "' + data_provider[:name].bold + '": '
  if DataProvider.find_by_name(data_provider[:name]).present?
    puts "  data provider name exists; skipping".yellow
  else
    ActiveRecord::Base.transaction do
      DataProvider.create!(data_provider)
    end
    puts "  data_provider created OK".green
  end
end
