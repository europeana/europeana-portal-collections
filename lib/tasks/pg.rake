##
# Rake tasks to backup PostgreSQL db
#
# Ensure that wherever the dump is run, e.g. on a cloud-based worker instance,
# there is enough disk space to store the dump until it is uploaded to cloud
# storage.
#
# @see http://sebastien.saunier.me/blog/2015/01/07/dump-a-postgresql-production-database-and-mount-it-locally.html
# @see https://gist.github.com/hopsoft/56ba6f55fe48ad7f8b90
namespace :pg do
  desc 'Dumps the PostgreSQL database to db/backups'
  task dump: :environment do
    backup_dir = backup_directory(true)

    with_config do |app, host, port, db, user, pass|
      file_name = Time.now.strftime('%Y%m%d%H%M%S') + "_" + db + '.sql'

      sh "export PGPASSWORD='#{pass}'"
      sh "pg_dump -h #{host} -p #{port} -U #{user} -d #{db} -f #{backup_dir}/#{file_name}"
      sh 'unset PGPASSWORD'

      save_to_fog(backup_dir, file_name)
      File.delete("#{backup_dir}/#{file_name}")
    end
  end

  private

  def save_to_fog(backup_dir, file_name)
    # @todo read this from paperclip.yml?
    fog_config = Rails.application.config_for(:fog).symbolize_keys

    storage = Fog::Storage.new(fog_config)

    dir = storage.directories.create(key: 'backups')

    file = dir.files.create(
      key: file_name,
      body: File.open("#{backup_dir}/#{file_name}"),
      public: false
    )
  end

  def backup_directory(create = false)
    File.expand_path('../../../db/backups', __FILE__).tap do |backup_dir|
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
