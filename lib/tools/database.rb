require_relative 'abstract_adapter'
require_relative 'postgres_adapter'
require_relative 'sqlite3_adapter'

module Tools
  class Database

    attr_accessor :adapter
    attr_reader :configuration
    attr_accessor :ar_config

    def initialize(configuration, database_name = nil)

      database_name ||= ::ActiveRecord::Base.connection_db_config.name
      self.ar_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env.to_s, name: database_name)

      # debugger
      @configuration = configuration

      @adapter = case ar_config.configuration_hash[:adapter]
      when 'postgresql'
        Tools::PostgresAdapter.new(configuration, ar_config)
      when 'sqlite3'
        Tools::Sqlite3Adapter.new(configuration, ar_config)
      else
        raise "Unsupported adapter: #{configuration.adapter}"
      end
    end

    def reset
      system("DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop:#{ar_config.name} db:create:#{ar_config.name}")
    end

    def dump
      hooks&.before_dump
      path = adapter.dump
      hooks&.after_dump
      path
    end

    def restore(file_name)
      hooks&.before_restore
      path = adapter.restore(file_name)
      hooks&.after_restore
      path
    end

    def list_files
      Dir.glob("#{adapter.backup_folder}/*.sql")
        .reject { |f| File.directory?(f) }
        .map { |f| Pathname.new(f).basename }
    end

    private

    def hooks
      @hooks ||= configuration.hooks
    end

  end

end
