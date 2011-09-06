CONFIG_PATH = 'config.yml'

require 'yaml'
require 'erb'
require 'fileutils'

IGNORED_FILES = ['config.sample.yml', 'config.yml', 'compiled', 'Rakefile']

task :default => [:compile, :symlink]

desc 'Copy files and folders into compiled directory, running erb in all files'
task :compile do
  log 'Compiling...'
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

  # Wire things up within compile dir
  post_process
end

desc 'Install symlinks from user\'s HOME to compiled dir'
task :symlink do
  log 'Symlinking...'
  log "Will generate: #{config['symlinks'].values.join(', ')}\n\n"

  config['symlinks'].each_pair do |source, symlink|
    target_path = "#{compiled_path}/#{source}"
    symlink_path = "#{config['symlinks_path']}/#{symlink}"
    symlink(target_path, symlink_path)
    log "\n"
  end
end

desc 'Update dependencies to latest versions, compile, and symlink'
task :update => ['update:oh_my_zsh', :compile, :symlink]

namespace :update do
  desc 'Update oh-my-zsh to latest'
  task :oh_my_zsh do
    update_submodule 'oh-my-zsh'
  end
end


def post_process
  log 'Post-processing...'
  # symlink oh-my-zsh/custom to zsh/
  symlink_path = "#{compiled_path}/oh-my-zsh/custom"
  target_path = "#{compiled_path}/zsh"
  symlink(target_path, symlink_path)

  # symlink all themes under zsh/themes from oh-my-zsh/themes
  themes_dir = "#{compiled_path}/oh-my-zsh/themes"
  Dir["#{compiled_path}/zsh/themes/*.zsh-theme"].each do |theme_path|
    symlink_path = "#{themes_dir}/#{File.basename(theme_path)}"
    symlink(theme_path, symlink_path)
  end
end

def update_submodule(name)
  path = "#{config['dotfiles_path']}/#{name}"
  system('cd', path)
  system('git', 'pull')
  system('cd', config['dotfiles_path'])
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
  FileUtils.rm_rf symlink_path
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