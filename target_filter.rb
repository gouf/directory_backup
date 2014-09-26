class String
  def not_include?(condition)
    !include?(condition)
  end
end

module TargetFilter
  def add_targets(targets)
    targets.each do |path|
      add_target(path)
    end
  end

  def add_target(path)
    full_path = File.expand_path(path)

    @targets ||= []
    if File.directory?(full_path)
      @targets += Dir.glob(full_path + '/**/**').flatten
    else
      @targets << full_path
    end
  end

  def exclude_targets!
    proc_object =
      proc do |target, condition|
        target.not_include?(condition) && file?(target)
      end
    select_to(@targets, @exclude_targets, proc_object)
    exclude_exceeded_size_limitation!
  end

  def exclude_exceeded_size_limitation!
    proc_object =
      proc do |target, _condition|
        within_size_limit?(target) if File.size?(target)
      end

    select_to(@targets, @exclude_targets, proc_object)
  end

  private

  def select_to(targets, conditions, proc_object)
    conditions.each do |condition|
      targets.select! do |target|
        proc_object.call(target, condition)
      end
    end
    @targets = targets
  end

  def within_size_limit?(full_path)
    # convert @limit_size to bytes
    match_data = @limit_size.delete(' ,').match(/(\d+)(.+)/).captures
    numeric, unit = match_data[0], match_data[1]

    limit_size = Filesize.from("#{numeric} #{unit}").to_i
    file_size = File.size(full_path)

    limit_size > file_size
  end

  def file?(path)
    !File.directory?(path)
  end
end
