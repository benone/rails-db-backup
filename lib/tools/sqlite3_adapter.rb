module Tools
  class Sqlite3Adapter < AbstractAdapter
    def dump(debug: false)
      file_path = File.join(backup_folder, "#{file_name}#{file_suffix}.sql")
      cmd = "sqlite3 #{ar_config.database} .dump > #{file_path}"
      debug ? system(cmd) : system(cmd, err: File::NULL)

      file_path
    end

    def restore(file_name, debug: false)
      file_path = File.join(backup_folder, file_name)
      output_redirection = debug ? '': ' > /dev/null'
      cmd = "sqlite3 #{ar_config.database} < #{file_path} #{output_redirection}"
      system(cmd)

      file_path
    end

  end
end
