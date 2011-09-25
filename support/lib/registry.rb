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

  def vendor_rake_namespaces
    @namespaces ||= Dir["#{vendor_path}/*"].map do |path|
      File.basename(path).gsub('-', '_')
    end
  end

  def vendor_path
    "#{dotfiles_path}/support/vendor"
  end

  def config
    @config
  end
end