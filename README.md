# PostgreSQL backup

This gem automates PostgreSQL's backup and restore in your Rails project. It will inject two rake tasks that you can use to manage your data, either by using the local system or AWS S3 storage.

The current version supports ruby 3. If you need backward compatibiliy, use [v0.0.6](https://rubygems.org/gems/postgresql-backup/versions/0.0.6) instead.

## How it looks like?

Dump:
![](https://res.cloudinary.com/ongmungazi/image/upload/v1650388791/ruby-gem/dump.gif)

Restore:
![](https://res.cloudinary.com/ongmungazi/image/upload/v1650388791/ruby-gem/restore.gif)

## Getting started

Add the gem to your Rails project:

```ruby
gem 'postgresql-backup'
```

Go to the terminal and update your gems using bundler:

```
bundle install
```

In the Rakefile of your project, add `require 'rails_db_backup'` anywhere **before** this line:

```
Rails.application.load_tasks
```

Right now, your project already has two new rake tasks: `rails_db_backup:dump` and `rails_db_backup:restore`.

## Configuration

If you intend to use the local file system to store the backup files, there is nothing more you need to do. Postgresql-backup has default configuration values and it uses the file system by default.

However, if you want to change the defaul values, like the name of the backup files or the folder where they are going to be stored, or if you prefer to use Amazon S3 service as a storage, you can do it.

Create a file inside the `config/initializers` folder. The name is not important, but it is a good practice to name it after with something related to what it does, like `database_backup.rb` or something like that.

Here is an example with all available options you can change:

```ruby
require 'rails_db_backup'

RailsDbBackup.configure do |config|
  # This gem works with two possible repositories:
  #
  # * S3: use S3 instead of the file system by setting `S3` to the
  #   repository. Make sure you also set `aws_access_key_id` and
  #   `aws_secret_access_key` or an error will be raised when you try
  #   to execute the rake tasks. The `bucket` and `region` attributes
  #   can also be defined, but they have default values and can also
  #   be overriden (or set by the first time) when the rake is
  #   called.
  #
  # * File System: this is the default value. Files will be stored
  #   in the disk, into the folder defined in the `backup_folder`.
  config.repository = 'S3'

  # The folder where files will be stored in the file system.
  # The default is `db/backups` and it will be ignored if you set
  # `repository` to 'S3'.
  config.backup_folder = ''

  # Get your access key and secret key from AWS console:
  # IAM -> Users -> Security Credentials tab -> access keys
  config.aws_access_key_id = ''
  config.aws_secret_access_key = ''

  # The name of the bucket where the backup files will be stored
  # (and from where they will be retrieved). The default value
  # is `postgresql-backups`, but this will be ignored unless the
  # repository is set to S3.
  config.bucket = ''

  # This is the region where your storage is. The default value
  # is `us-east-1`. It will also be ignored unless the repository
  # is set to S3.
  config.region = ''

  # Backup files are created using a pattern made by the current date
  # and time. If you want to add a sufix to the files, change this
  # attribute.
  config.file_suffix = ''

  # If you use S3 to upload the backup files, you need to provide a
  # path where they are going to be stored. The remote path is the
  # place to do that. The default value is `_backups/database/`
  config.remote_path = ''

  # There are cases where we need to run a command before or after the database
  # is restored or a backup is created. To accomplish this, you can set the
  # `hooks` attribute to a class or an instance of a class that
  # responds to the method you need.
  #
  #  Available hook methods are:
  #
  #  * before_restore
  #  * after_restore
  #  * before_dump
  #  * after_dump
  #
  config.hooks = nil
end
```

## Backing up your database

If you followed the steps above, you are ready to go. The simplest way to backup your data is by running the `dump` rake task:

```
bundle exec rake rails_db_backup:dump
```

However, you can set (or override) a few things when executing the rake:

- repository: `BKP_REPOSITORY='File System' bundle exec rake rails_db_backup:dump`
- bucket: `BKP_BUCKET='my-bucket' bundle exec rake rails_db_backup:dump`
- region: `BKP_REGION='us-east-1' bundle exec rake rails_db_backup:dump`
- remote_path: `BKP_REMOTE_PATH='_backups/database' bundle exec rake rails_db_backup:dump`

Be aware that, if the gem is configured to use the file system and you force the task to use S3, AWS related attributes must be set, like the access key and the secret key.

You can combine these variables above any way you want:

```
BKP_REPOSITORY='S3' BKP_BUCKET='my-bucket' BKP_REGION='us-east-1' BKP_REMOTE_PATH='_backups/database' bundle exec rake rails_db_backup:dump
```

Important note: config/database.yml is used for database configuration,
but you may be prompted for the database user's password.

## Restoring data into your database

The basic way of restoring the database is by running the `restore` take task:

```
bundle exec rake rails_db_backup:restore
```

It will respect the configuration set during initialization or use default values when available. Just like in the `dump` task, you can override (or set) configuration values:

```
REPOSITORY='S3' S3_BUCKET_NAME='my-bucket' bundle exec rake db:restore
```

Again, you can use these environment variables:

- repository: `BKP_REPOSITORY='File System' bundle exec rake rails_db_backup:restore`
- bucket: `BKP_BUCKET='my-bucket' bundle exec rake rails_db_backup:restore`
- region: `BKP_REGION='us-east-1' bundle exec rake rails_db_backup:restore`
- remote_path: `BKP_REMOTE_PATH='_backups/database' bundle exec rake rails_db_backup:dump`

Or make any combination you want with them:

```
BKP_REPOSITORY='S3' BKP_BUCKET='my-bucket' BKP_REGION='us-east-1' BKP_REMOTE_PATH='_backups/database' bundle exec rake rails_db_backup:restore
```

This is useful when you are trying to restore a production database into your local machine. Even though you configured the gem to use a development bucket, it is necessary to read the backup file from a production bucket.

When you run the rake task to restore a database, it will list all available files for you to choose.

Important note: if you are trying to locally restore a backup that was created in a production environment, there is a trick you need to know. There is a table called `ar_internal_metadata` that stores the Rails environment the project is using. If you simply restore a production backup in a development database, Rails will think you are in production.

Everything will work just fine, but you may come across some strange warnings, like when you try to drop the database: it will say you are droping a production database to double check if this is your intended purpose.

To prevent this, every time the rake restores a backup file it tries to replace the environment being copied into the ar_internal_metadata table with the current Rails environment. Thus, `environment production` will become `environment development`.

## Database restore hooks

Sometimes we need to run things every time a database restore is about to happen, or maybe after the restore is completed. You may even need to run code before or after a backup is created.

For example, if you use Elasticsearch you may need to reindex it after restoring a database.

To accomplish this, you can use the `hooks` configurations:

Examples:

```ruby
class DatabaseBackupHooks
  def before_restore
    puts 'Backup is going to be restored...'
  end

  def after_restore
    puts 'Backup restored!'
  end

  def before_dump
    puts 'Database backup is about to be created...'
  end

  def after_dump
    puts 'Dump created!'
  end
end
```

Then, you can set the `hooks` in the initializer:

```ruby
RailsDbBackup.configure do |config|
  config.hooks = DatabaseBackupHooks.new
end
```

It also works with classes with class methods:

```ruby
class DatabaseBackupHooks
  def self.before_restore
    puts 'Backup is going to be restored...'
  end

  def self.after_restore
    puts 'Backup restored!'
  end

  def self.before_dump
    puts 'Database backup is about to be created...'
  end

  def self.after_dump
    puts 'Dump created!'
  end
end

```

```ruby
RailsDbBackup.configure do |config|
  config.hooks = DatabaseBackupHooks # Note that here we no longer instantiate the class
end
```

You can even create a class on the fly:

```ruby
RailsDbBackup.configure do |config|
  config.hooks = Class.new do
    def self.after_restore
      puts "after restore hook"
    end
  end
end
```

## I want to contribute

Feel free to open a pull request with the changes you want to make. Remember to update `CHANGELOG.md` with the change you are proposing, because once the PR is merged, it is important to show which changes are being made to the gem.

The first thing to do is to update the dependencies. If you do not have bundle installed, run `gem install bundler`. Then:

```
bundle install
```

To run the tests, we use rspec:

```
rspec
```
