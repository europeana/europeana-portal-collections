##
# Rake tasks to backup/restore Rails PostgreSQL db to/from Fog storage
#
# Ensure that wherever the dump is run, e.g. on a cloud-based worker instance,
# there is enough disk space to store the dump until it is uploaded to cloud
# storage.
#
# Configure Fog in config/fog.yml. Sample config files are included for
# development environments and Anynines in the deploy/ directory.
namespace :pg do
  desc 'Backs up the PostgreSQL database to Fog storage'
  task backup: :environment do
    check_configuration!

    dump_to_tmp_file do |tmp_file|
      save_dump_to_fog(tmp_file)
    end
  end

  desc 'Restores the PostgreSQL database from Fog storage'
  task restore: :environment do
    check_configuration!

    exit_with_error!('Specify the timestamp to restore in DUMP') unless ENV['DUMP']

    download_dump_from_fog(ENV['DUMP']) do |tmp_file|
      restore_dump_to_pg(tmp_file)
    end
  end

  private

  def check_configuration!
    ensure_db_adapter_is_pg!
    ensure_fog_configured!
  end

  def ensure_db_adapter_is_pg!
    unless ActiveRecord::Base.connection_config[:adapter] =~ /^postgres/
      exit_with_error!('Database adapter is not PostgreSQL. Aborting.')
    end
  end

  def ensure_fog_configured!
    exit_with_error!('Fog is not configured. Aborting.') unless fog_configured?
  end

  def exit_with_error!(msg)
    puts "ERROR: #{msg}".red.bold
    exit 1
  end

  def fog_configured?
    Rails.application.config_for(:fog)
    true
  rescue StandardError => e
    raise e unless e.message =~ /Could not load configuration\./
    false
  end

  def restore_dump_to_pg(tmp_file)
    %w(db:drop db:create).each do |task|
      Rake::Task[task].invoke
    end

    sh "export PGPASSWORD='#{password}'"
    sh "pg_restore -h #{host} -p #{port} -U #{username} -d #{database} #{tmp_file.path}"
    sh 'unset PGPASSWORD'
  end

  def download_dump_from_fog(dump_timestamp)
    file_name = dump_file_name(dump_timestamp)
    exit_with_error!('Dump file not found in backups directory.') if fog_storage_dir.files.head(file_name).nil?

    tmp_file = Tempfile.new('pg-dump')
    tmp_file.binmode

    fog_storage_dir.files.get(file_name) do |chunk|
      tmp_file.write chunk
    end
    tmp_file.close

    yield tmp_file

    tmp_file.unlink
  end

  def dump_file_name(timestamp = nil)
    timestamp ||= Time.now.strftime('%Y%m%d%H%M%S')
    "#{timestamp}_#{database}.psql"
  end

  def dump_to_tmp_file
    tmp_file = Tempfile.new('pg-dump')
    tmp_file.close

    sh "export PGPASSWORD='#{password}'"
    sh "pg_dump -Fc -h #{host} -p #{port} -U #{username} -d #{database} -f #{tmp_file.path}"
    sh 'unset PGPASSWORD'

    yield tmp_file

    tmp_file.unlink
  end

  def save_dump_to_fog(file)
    fog_storage_dir.files.create(
      key: dump_file_name,
      body: File.open(file),
      public: false
    )
  end

  def fog_storage_dir
    @fog_storage_dir ||= begin
      fog_config = Rails.application.config_for(:fog).symbolize_keys
      storage = Fog::Storage.new(fog_config[:credentials].symbolize_keys)
      storage.directories.create(key: fog_config[:directory])
      storage.directories.create(key: fog_config[:directory] + '/backups')
    end
  end

  def host
    @pg_host ||= ActiveRecord::Base.connection_config[:host] || '127.0.0.1'
  end

  def port
    @pg_port ||= ActiveRecord::Base.connection_config[:port] || 5432
  end

  def database
    @pg_database ||= ActiveRecord::Base.connection_config[:database]
  end

  def username
    @pg_username ||= ActiveRecord::Base.connection_config[:username]
  end

  def password
    @pg_password ||= ActiveRecord::Base.connection_config[:password]
  end
end
