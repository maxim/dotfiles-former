class Manager
  IGNORED_FILES = [ 'support',
                    'Rakefile',
                    'README.md' ]

  def initialize(registry)
    @registry = registry
  end

  def any_submodules_missing?
    Dir["#{@registry.vendor_path}/*"].any? do |path|
      !File.exists?("#{path}/.git")
    end
  end

  def each_vendor_path(&block)
    Dir["#{@registry.vendor_path}/*"].each do |path|
      block.call(path)
    end
  end

  def each_symlink_path(&block)
    @registry.symlinks.each_pair do |source, symlink|
      block.call("#{@registry.symlinks_path}/#{symlink}")
    end
  end

  def each_copy_job(&block)
    paths = (Dir["#{@registry.dotfiles_path}/*"] + Dir["#{@registry.vendor_path}/*"])

    paths.each do |path|
      path_filename = File.basename(path)

      unless IGNORED_FILES.include?(path_filename)
        target_path = "#{@registry.build_path}/#{path_filename}"
        block.call(path, target_path)
      end
    end
  end

  def each_erb_job(&block)
    vendor_dirs = Dir["#"]

    Dir["#{@registry.build_path}/**/*.erb"].each do |src|
      dst = src.chomp('.erb')

      vendor_dirs = Dir["#{@registry.vendor_path}/*"].map{|p| File.basename(p)}
      build_vendor_paths = vendor_dirs.map{|d| "#{@registry.build_path}/#{d}" }

      # Exclude vendor dirs from erb parsing
      if build_vendor_paths.none?{|path| src.include?(path) }
        block.call(src, dst, { :config        => @registry.config,
                               :build_path    => @registry.build_path,
                               :dotfiles_path => @registry.dotfiles_path,
                               :symlinks_path => @registry.symlinks_path,
                               :osx_path      => @registry.osx_path,
                               :vendor_path   => @registry.vendor_path })
      end
    end
  end

  def each_symlink_job(&block)
    @registry.symlinks.each_pair do |source, symlink|
      existing_path = "#{@registry.build_path}/#{source}"
      symlink_path = "#{@registry.symlinks_path}/#{symlink}"
      block.call(existing_path, symlink_path)
    end
  end

  def invoke_post_build_tasks
    @registry.namespaces.each do |namespace|
      invoke_task("#{namespace}:post_build")
    end
  end

  def invoke_update_tasks
    @registry.namespaces.each do |namespace|
      invoke_task("#{namespace}:update")
    end
  end

  def invoke_task(task_name)
    if @registry.task_defined?(task_name)
      @registry.task(task_name).invoke
      true
    else
      false
    end
  end
end