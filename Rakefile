CONFIG_PATH = 'config.yml'

require 'yaml'
require 'erb'
require 'fileutils'

IGNORED_FILES = ['config.sample.yml', 'config.yml', 'compiled', 'Rakefile']

task :default => [:compile, :symlink]

desc 'Copy files and folders into compiled directory, running erb in all files'
task :compile do
  dotfiles_dir = config['dotfiles_path']
  prepare_compiled_dir

  Dir["#{dotfiles_dir}/*"].each do |path|
    path_filename = File.basename(path)

    unless IGNORED_FILES.include?(path_filename)
      target_path = "#{compiled_path}/#{path_filename}"

      if File.directory?(path)
        copy(path, target_path)
      else
        compile_with_accessors(path, target_path, :config => config)
      end
    end
  end
end

desc 'Install symlinks from user HOME to compiled dir'
task :symlink do
  log "Will generate: #{config['symlinks'].values.join(', ')}\n\n"

  config['symlinks'].each_pair do |source, symlink|
    target_path = "#{compiled_path}/#{source}"
    symlink_path = "#{config['symlinks_path']}/#{symlink}"
    symlink(target_path, symlink_path)
    log "\n"
  end
end

def prepare_compiled_dir 
  FileUtils.rm_rf(compiled_path)
  FileUtils.mkdir_p(compiled_path)
  compiled_path
end

def compiled_path
  "#{config['dotfiles_path']}/compiled"
end

def config
  @config ||= YAML.load(ERB.new(File.read(CONFIG_PATH)).result(binding))
end

def copy(origin, destination)
  show_transition "Copy", origin, destination
  FileUtils.rm_rf destination
  FileUtils.cp_r(origin, destination, :remove_destination => true)
end

def compile_with_accessors(origin, destination, accessors = {})
  show_transition "Compile", origin, destination
  template = ERB.new(File.read(origin))
  binding_with_accessors = build_binding_with_accessors(accessors)

  File.open(destination, 'w') do |file|
    file.write(template.result(binding_with_accessors))
  end
end

def symlink(existing_path, symlink_path)
  show_transition "Symlink", symlink_path, existing_path
  FileUtils.rm_f symlink_path
  FileUtils.ln_sf existing_path, symlink_path
end

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

def show_transition(verb, origin, destination)
  log "#{verb} #{origin} => #{destination}"
end

def log(text)
  puts text if ENV['DEBUG']
end