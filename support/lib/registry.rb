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
    tnames = ::Rake.application.tasks.map(&:name)
    ntnames = tnames.select{|t| t.include?(':')}
    nnames = ntnames.map do |t|
      parts = t.split(':')
      parts.pop
      parts.join(':')
    end.uniq
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
