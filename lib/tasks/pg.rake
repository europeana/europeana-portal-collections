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
    check_fog_configured!
    dumped_tmp_file do |tmp_file|
      save_to_fog(tmp_file)
    end
  end

  private

  def check_fog_configured!
    unless fog_configured?
      puts "ERROR: Fog is not configured. Aborting.".red.bold
      exit 1
    end
  end

  def fog_configured?
    Rails.application.config_for(:fog)
    true
  rescue StandardError => e
    raise e unless e.message =~ /Could not load configuration\./
    false
  end

  def dump_file_name
    @dump_file_name ||= begin
      with_config do |_app, _host, _port, db, _user, _pass|
        Time.now.strftime('%Y%m%d%H%M%S') + "_" + db + '.sql'
      end
    end
  end

  def dumped_tmp_file
    tmp_file = Tempfile.new(dump_file_name)
    tmp_file.close

    with_config do |app, host, port, db, user, pass|
      sh "export PGPASSWORD='#{pass}'"
      sh "pg_dump -h #{host} -p #{port} -U #{user} -d #{db} -f #{tmp_file.path}"
      sh 'unset PGPASSWORD'
    end

    yield tmp_file

    tmp_file.unlink
  end

  def save_to_fog(tmp_file)
    fog_config = Rails.application.config_for(:fog).symbolize_keys

    storage = Fog::Storage.new(fog_config[:credentials].symbolize_keys)

    dir = storage.directories.create(key: fog_config[:directory] + '/backups')

    file = dir.files.create(
      key: dump_file_name,
      body: File.open(tmp_file),
      public: false
    )
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
