require 'aws-sdk'
require 'yaml'
require 'pp'
require 'filesize'

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

  def add_target(path)
    full_path = File.expand_path(path)

    if File.directory?(full_path)
      @targets += Dir.glob(full_path + '/**/**').flatten
    else
      @targets << full_path
    end
  end

  def exclude_targets!
    proc_object =
      proc { |target, condition| !target.include?(condition) && file?(target) }
    exclude_to(proc_object)
    exclude_size_limitation_exceeded!
  end

  def exclude_exceeded_size_limitation!
    proc_object =
      proc do |target, _condition|
        !size_limit_exceeded?(target) if File.size?(target)
      end

    exclude_to(proc_object)
  end

  private

  def exclude_to(proc_object)
    exclude_targets = @exclude_targets
    res = @targets
    exclude_targets.each do |condition|
      res =
        res.select do |target|
          proc_object.call(target, condition)
        end
    end
    @targets = res
  end

  def size_limit_exceeded?(full_path)
    # convert @limit_size to bytes
    match_data = @limit_size.delete(' ,').match(/(\d+)(.+)/).captures
    numeric, unit = match_data[0], match_data[1]
    limit_size = Filesize.from("#{numeric} #{unit}").to_i

    limit_size < File.size(full_path)
  end

  def file?(path)
    !File.directory?(path)
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
