class Registry
  def initialize(config_path)
    @config = YAML.load(ERB.new(File.read(config_path)).result(binding))    
  end

  def dotfiles_path
    config['dotfiles_path']
  end

  def build_path
    "#{dotfiles_path}/support/build"
  end

  def symlinks_path
    config['symlinks_path']
  end

  def symlinks
    config['symlinks']
  end

  def osx_path
    "#{build_path}/osx"
  end

  def namespaces
    ::Rake.application.tasks.map(&:name).select{|t| t.include?(':')}.map{|t| t.split(':').first}.uniq
  end

  def task(name)
    ::Rake::Task[name]
  end

  def task_defined?(name)
    ::Rake::Task.task_defined?(name)
  end

  def vendor_path
    "#{dotfiles_path}/support/vendor"
  end

  def config
    @config
  end
end