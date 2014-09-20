
module TargetFilter
  def add_targets(targets)
    targets.each do |path|
      add_target(path)
    end
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
    exclude_exceeded_size_limitation!
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
end
