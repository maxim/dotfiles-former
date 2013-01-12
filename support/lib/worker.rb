class Worker
  def initialize(logger, options = {})
    @logger = logger
    @dry = options[:dry]
  end

  def copy(origin, destination)
    @logger.report('Copy', origin, :to => destination, :ljust => 0)

    unless @dry
      FileUtils.rm_rf destination
      FileUtils.cp_r(origin, destination, :remove_destination => true)
    end
  end

  def delete(path)
    @logger.report('Delete', path)

    unless @dry
      FileUtils.rm_rf(path)
    end
  end

  def mkdir(path)
    @logger.report('Create', path)

    unless @dry
      FileUtils.mkdir_p(path)
    end
  end

  def symlink(existing_path, symlink_path)
    @logger.report('Symlink', symlink_path, :to => existing_path)

    unless @dry
      FileUtils.rm_rf symlink_path
      FileUtils.ln_sf existing_path, symlink_path
    end
  end

  def chmod(bits, path)
    @logger.report('Chmod', bits.to_s(8), :to => path)

    unless @dry
      FileUtils.chmod bits, path
    end
  end

  def patch(target_path, patch_path)
    @logger.report('Patch', patch_path, :to => target_path)

    unless @dry
      unless system('patch', target_path, '-i', patch_path, '-s')
        @logger.state 'Patch failed!', :error => true
        exit(1)
      end
    end
  end

  def goto_path(path, &block)
    back = Dir.pwd
    Dir.chdir(path)
    output = block.call
    Dir.chdir(back)
    output
  end

  def run(executable_path)
    @logger.report('Run', executable_path)
    `#{executable_path}` unless @dry
  end

  def go_and_run(executable_path)
    executable_dir = File.dirname(executable_path)
    executable_name = File.basename(executable_path)
    @logger.report('Run', executable_path)

    unless @dry
      goto_path(executable_dir) { `./#{executable_name}` }
    end
  end

  def fetch_submodules(path = nil)
    if path
      @logger.report('Download', "#{File.basename(path)} dependencies")

      unless @dry
        goto_path(path) do
          system 'git submodule update --init --recursive > /dev/null 2>&1'
        end
      end
    else
      @logger.report('Download', 'dependencies')

      unless @dry
        system 'git submodule update --init --recursive > /dev/null 2>&1'
      end
    end
  end

  def update_submodule(path)
    unless @dry
      out = goto_path(path) { `git pull` }

      updated = out !~ /Already up/
      @logger.report('Update', File.basename(path), :to => (updated ? 'got new updates' : 'already up to date'))
      updated
    end
  end

  def recursive_update_submodule(path)
    update_submodule(path)
    fetch_submodules(path)
  end

  def parse_erb(origin, destination, accessors = {})
    @logger.report "Parse", origin, :to => destination

    unless @dry
      template = ERB.new(File.read(origin))
      binding_with_accessors = build_binding_with_accessors(accessors)
      result = template.result(binding_with_accessors).strip

      unless result.empty?
        File.open(destination, 'w') do |file|
          file.write(result + "\n")
        end
      end
    end
  end

  private
  def build_binding_with_accessors(accessors = {})
    wrapper = Class.new do
      attr_accessor *accessors.keys.map(&:to_sym)

      def get_binding
        binding
      end
    end

    wrapper_instance = wrapper.new

    accessors.each_pair do |name, value|
      wrapper_instance.send(:"#{name}=", value)
    end

    wrapper_instance.get_binding
  end
end
