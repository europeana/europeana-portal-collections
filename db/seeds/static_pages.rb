YAML.load_file(File.expand_path('../static_pages.yml', __FILE__)).each do |page|
  puts 'Seeding page with slug "' + page[:slug].bold + '": '
  if Page.find_by_slug(page[:slug]).present?
    puts "  slug exists; skipping".yellow
  else
    ActiveRecord::Base.transaction do
      Page.create!(page).publish!
    end
    puts "  page created OK".green
  end
end
