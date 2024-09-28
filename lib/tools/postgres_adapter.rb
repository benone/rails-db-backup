module Tools
  class PostgresAdapter < AbstractAdapter
    def dump(debug: false)
      file_path = File.join(backup_folder, "#{file_name}#{file_suffix}.sql")

      cmd = "PGPASSWORD='#{password}' pg_dump -F p -v -O -U '#{user}' -h '#{host}' -d '#{database}' -f '#{file_path}' -p '#{port}' "
      debug ? system(cmd) : system(cmd, err: File::NULL)
      file_path
    end

    def restore(file_name, debug: false)
      file_path = File.join(backup_folder, file_name)
      output_redirection = debug ? '': ' > /dev/null'
      cmd = "PGPASSWORD='#{password}' psql -U '#{user}' -h '#{host}' -d '#{database}' -f '#{file_path}' -p '#{port}' #{output_redirection}"
      system(cmd)
      file_path
    end

  end
end
