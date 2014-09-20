require 'aws-sdk'
require 'yaml'
require 'pp'
require 'filesize'
require_relative 'target_filter'

class S3Backup
  attr_reader :targets
  attr_reader :include_targets, :targets

  def initialize
    load_config
    @targets = []
    @include_targets.each do |path|
      add_target(path)
    end
    @targets.uniq!
  end

  def load_config
    @config = YAML.load_file('config.yml')
    load_backup_target_config
    load_s3_config
  end

  def load_backup_target_config
    c = @config['backup_directories']
    @include_targets = c['include']
    @exclude_targets = c['exclude']
    @limit_size      = c['file_size_limit']
  end

  def load_s3_config
    c = @config['aws_s3']
    @access_key_id     = c['access_key_id']
    @secret_access_key = c['secret_access_key']
    @bucket_name       = c['bucket_name']
    @directory_prefix  = c['directory_prefix']
  end
end
