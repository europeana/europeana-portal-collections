# frozen_string_literal: true

YAML.load_file(File.expand_path('data_providers.yml', __dir__)).each do |data_provider|
  puts 'Seeding data provider "' + data_provider[:name].bold + '": '
  if DataProvider.find_by_uri(data_provider[:uri]).present?
    puts '  data provider URI exists; skipping'.yellow
  else
    provider = DataProvider.new(data_provider)

    ActiveRecord::Base.transaction do
      provider.save
    end

    if provider.new_record?
      puts '  data_provider failed to save; continuing'.red
    else
      puts '  data_provider created OK'.green
    end
  end
end
