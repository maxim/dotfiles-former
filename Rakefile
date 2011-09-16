CONFIG_PATH = 'config.yml'

# Do not copy these
IGNORED_FILES = ['config.sample.yml', 'config.yml', 'compiled', 'Rakefile']

require 'yaml'
require 'erb'
require 'fileutils'

'show me the page'

task :default => [:copy, :compile, :post_process, :symlink]

desc 'Copy files to compiled dir'
task :copy do
  decorate('Copying...') do

    dotfiles_dir = config['dotfiles_path']
    prepare_compiled_dir

    Dir["#{dotfiles_dir}/*"].each do |path|
      path_filename = File.basename(path)

      unless IGNORED_FILES.include?(path_filename)
        target_path = "#{compiled_path}/#{path_filename}"
        copy(path, target_path)
      end
    end

  end
end

desc 'Running erb in all files'
task :compile do
  decorate 'Compiling...' do

    dotfiles_dir = config['dotfiles_path']

    Dir["#{compiled_path}/**/*.erb"].each do |path|
      compile_with_accessors(path, :config => config)
    end
  end
end

desc 'Install symlinks from user\'s HOME to compiled dir'
task :symlink do
  decorate 'Symlinking...' do

    config['symlinks'].each_pair do |source, symlink|
      target_path = "#{compiled_path}/#{source}"
      symlink_path = "#{config['symlinks_path']}/#{symlink}"
      symlink(target_path, symlink_path)
    end
  end
end

desc 'Wire things up in compiled dir after copying and compiling'
task :post_process do
  decorate 'Post-processing...' do

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
end

desc 'Reconfigure OSX settings'
task :osx => :compile do
  log 'Configuring osx...'
  system('chmod', '+x', "#{compiled_path}/osx")
  `cd #{compiled_path} && ./osx`
  `cd #{config['dotfiles_path']}`
end


desc 'Update dependencies to latest versions, compile, and symlink'
task :update => ['update:oh_my_zsh', :default]

namespace :update do
  desc 'Update oh-my-zsh to latest'
  task :oh_my_zsh do
    update_submodule 'oh-my-zsh'
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
  show_transition "Copy", origin, destination, :ljust => 0
  FileUtils.rm_rf destination
  FileUtils.cp_r(origin, destination, :remove_destination => true)
end

def compile_with_accessors(origin, accessors = {})
  destination = origin.chomp('.erb')
  show_transition "Compile", origin, destination
  template = ERB.new(File.read(origin))
  binding_with_accessors = build_binding_with_accessors(accessors)

  result = template.result(binding_with_accessors).strip

  unless result.empty?
    File.open(destination, 'w') do |file|
      file.write(result) 
    end
  end

  File.delete(origin)
end

def symlink(existing_path, symlink_path)
  show_transition "Symlink", symlink_path, existing_path
  FileUtils.rm_rf symlink_path
  FileUtils.ln_sf existing_path, symlink_path
end

def chmod(bits, path)
  show_transition "Chmod", bits.to_s(8), path
  FileUtils.chmod bits, path
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

def decorate(title)
  log title
  yield
  log "\n"
end

def show_transition(verb, origin, destination, options = {})
  ljust = options[:ljust] || 7
  verb = green(verb.ljust(ljust))

  log "#{verb.rjust(7)} #{origin} => #{destination}"
end

def green(text)
  "\e[32m#{text}\e[0m"
end

def log(text)
  puts text if ENV['DEBUG']
end