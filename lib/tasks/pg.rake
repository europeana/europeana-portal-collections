##
# Rake tasks to backup PostgreSQL db
#
# @see http://sebastien.saunier.me/blog/2015/01/07/dump-a-postgresql-production-database-and-mount-it-locally.html
# @see https://gist.github.com/hopsoft/56ba6f55fe48ad7f8b90
namespace :pg do
  desc 'Dumps the PostgreSQL database to db/backups'
  task dump: :environment do
    backup_dir = backup_directory(true)

    with_config do |app, host, port, db, user, pass|
      file_name = Time.now.strftime("%Y%m%d%H%M%S") + "_" + db + '.sql'

      sh "export PGPASSWORD='#{pass}'"
      sh "pg_dump -h #{host} -p #{port} -U #{user} -d #{db} -f #{backup_dir}/#{file_name}"
      sh 'unset PGPASSWORD'
    end
  end

  private

  def backup_directory(create = false)
    File.expand_path("../../../db/backups", __FILE__).tap do |backup_dir|
      FileUtils.mkdir_p(backup_dir) if create && !Dir.exists?(backup_dir)
    end
  end

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host] || '127.0.0.1',
      ActiveRecord::Base.connection_config[:port] || 5432,
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username],
      ActiveRecord::Base.connection_config[:password]
  end
end
