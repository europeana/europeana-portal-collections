# frozen_string_literal: true

YAML.load_file(File.expand_path('topics.yml', __dir__)).each do |attrs|
  ActiveRecord::Base.transaction do
    print %(Seeding topic with label "#{attrs[:label].to_s.bold}": )
    if topic = Topic.find_by(label: attrs[:label])
      topic.update_attributes(attrs)
      puts 'topic exists; updated OK'.green
    else
      Topic.create!(attrs)
      puts 'topic created OK'.green
    end
  end
end
