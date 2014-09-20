require 'aws-sdk'
require 'yaml'
require 'pp'
require 'filesize'
require './target_filter'

class S3Backup
  include TargetFilter
  attr_reader :targets
  attr_reader :include_targets, :targets

  def initialize
    load_config
    @targets = []
    add_targets(@include_targets)
    @targets.uniq!
    @s3 = AWS::S3.new(
      access_key_id: @access_key_id,
      secret_access_key: @secret_access_key
    )
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

  def upload
    @targets.each do |file_path|
      puts file_path
      bucket.objects[file_path].write(file_path)
    end
  end

  def bucket
    @s3.buckets[@bucket_name]
  end

  def buckets
    @s3.buckets
  end

  alias_method :buckup, :upload
end
