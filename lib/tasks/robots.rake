# frozen_string_literal: true

namespace :robots do
  desc 'Disallow robots from crawling this site'
  task disallow: :environment do
    File.write(File.join(Rails.root, 'public', 'robots.txt'), "User-agent: *\nDisallow: /")
    puts 'robots.txt written to ' + 'disallow'.bold + ' crawling.'
  end

  desc 'Allow robots to crawl this site'
  task allow: :environment do
    File.delete(robots_txt_path) if File.exist?(robots_txt_path)
    puts 'robots.txt deleted to ' + 'allow'.bold + ' crawling.'
  end
end

def robots_txt_path
  @robots_txt_path ||= File.join(Rails.root, 'public', 'robots.txt')
end
