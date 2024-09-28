module Tools
  class AbstractAdapter
    attr_accessor :configuration, :ar_config

    def initialize(configuration, ar_config)
      @configuration = configuration
      @ar_config = ar_config
    end

    def dump(debug: false)
      raise NotImplementedError, 'Subclasses must implement the dump method'
    end

    def restore(file_name, debug: false)
      raise NotImplementedError, 'Subclasses must implement the restore method'
    end

    def backup_folder
      @backup_folder ||= begin
        File.join(Rails.root, configuration.backup_folder).tap do |folder|
          FileUtils.mkdir_p(folder)
        end
      end
    end

    private
    def host
      @host ||= ar_config.configuration_hash[:host]
    end

    def port
      @port ||= ar_config.configuration_hash[:port]
    end

    def database
      @database ||= ar_config.configuration_hash[:database]
    end

    def user
      ar_config.configuration_hash[:username]
    end

    def password
      @password ||= ar_config.configuration_hash[:password]
    end

    def file_suffix
      return if configuration.file_suffix.empty?
      @file_suffix ||= "_#{configuration.file_suffix}"
    end

    def file_name
      @file_name ||= [
        Time.current.strftime('%d.%m.%Y_%H:%M:%S'),
        ar_config.name
      ].join("-")
    end

    def hooks
      @hooks ||= configuration.hooks
    end
  end
end
