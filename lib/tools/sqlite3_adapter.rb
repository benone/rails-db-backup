module Tools
  class Sqlite3Adapter < AbstractAdapter
    def dump(debug: false)
      file_path = File.join(backup_folder, "#{file_name}#{file_suffix}.sql")
      cmd = "sqlite3 #{ar_config.database} .dump > #{file_path}"
      Tools::Terminal.info(cmd)
      debug ? system(cmd) : system(cmd, err: File::NULL)

      file_path
    end

    def restore(file_name, debug: false)
      file_path = File.join(backup_folder, file_name)
      output_redirection = debug ? '': ' > /dev/null'

      File.delete(ar_config.database) if File.exist?(ar_config.database)

      cmd = "sqlite3 #{ar_config.database} < #{file_path} #{output_redirection}"
      Tools::Terminal.info(cmd)
      system(cmd)

      file_path
    end

  end
end
