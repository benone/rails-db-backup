Gem::Specification.new do |s|
  s.name        = 'rails-db-backup'
  s.version     = '0.0.11'
  s.summary     = "Automate Rails backup and restore"
  s.description = "This gem automates database backup and restore in your Rails project. It will inject two rake tasks that you can use to manage your data, either by using the local system or AWS S3 storage."
  s.authors     = [""]
  s.email       = ''
  s.homepage    = 'https://github.com/benone/rails-db-backup'
  s.files       = `git ls-files -- lib/*`.split("\n")
  s.files       += %w[README.md CHANGELOG.md]
  s.license     = 'MIT'

  # Development dependencies
  s.add_development_dependency 'bump', '~> 0.8.0'
  s.add_development_dependency 'rspec', '~> 3.10.0'
  s.add_development_dependency 'simplecov', '~> 0.21.2'

  # Dependencies:
  s.add_dependency 'fog-aws', '~> 3.13.0'
  s.add_dependency 'pastel', '~> 0.8.0'
  s.add_dependency 'tty-prompt', '~> 0.23.0'
  s.add_dependency 'tty-spinner', '~> 0.9.3'
  s.add_dependency 'rubyzip', "~> 2.3"
end
