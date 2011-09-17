CONFIG_PATH = 'config.yml'

# Do not copy these
IGNORED_FILES = [ 'config.sample.yml',
                  'config.yml',
                  'compiled',
                  'Rakefile',
                  'tmp',
                  'janus',
                  'README.md' ]

SUBMODULES = ['oh-my-zsh', 'janus']

require 'yaml'
require 'erb'
require 'fileutils'

desc 'Setup everything first time or update things upon change'
task :default => [ :prepare_directories,
                   :prepare_submodules,
                   :pre_process,
                   :copy,
                   :compile,
                   :post_process,
                   :symlink ]

# desc 'Prepare ignored directories'
task :prepare_directories do
  decorate('Preparing directories...') do
    prepare_compiled_dir
    prepare_tmp_dir
  end
end

# desc 'Initialize/pull git submodules if necessary'
task :prepare_submodules do
  need_to_prepare = SUBMODULES.any? do |name|
    !File.exists?("#{dotfiles_path}/#{name}/.git")
  end

  if need_to_prepare
    decorate('Preparing submodules...') do
      show_action 'Initialize', 'git submodules'
      system 'git submodule init > /dev/null 2>&1'
      system 'git submodule update > /dev/null 2>&1'
    end
  end
end

# desc 'Preprocess packages before copying/compiling'
task :pre_process do
  decorate('Pre-processing...') do
    unless File.exists?("#{dotfiles_path}/tmp/janus")
      # Install Janus to tmp so we don't have to reinstall it all the time
      copy("#{dotfiles_path}/janus", "#{tmp_path}/janus")
      show_transition('Install', 'Janus', "#{tmp_path}/janus")
      system "cd #{tmp_path}/janus && rake > /dev/null 2>&1 && cd #{dotfiles_path}"
    end
  end
end

# desc 'Copy files to compiled dir'
task :copy do
  decorate('Copying...') do
    Dir["#{dotfiles_path}/*"].each do |path|
      path_filename = File.basename(path)

      unless IGNORED_FILES.include?(path_filename)
        target_path = "#{compiled_path}/#{path_filename}"
        copy(path, target_path)
      end
    end

    Dir["#{tmp_path}/*"].each do |path|
      path_filename = File.basename(path)
      target_path = "#{compiled_path}/#{path_filename}"
      copy(path, target_path)
    end
  end
end

# desc 'Run erb in all files'
task :compile do
  decorate 'Compiling...' do
    Dir["#{compiled_path}/**/*.erb"].each do |path|
      compile_with_accessors(path, :config => config)
    end
  end
end

# desc 'Wire things up in compiled dir after copying and compiling'
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

    # apply patches
    apply_patches
  end
end

# desc 'Install symlinks from user\'s HOME to compiled dir'
task :symlink do
  decorate 'Symlinking...' do

    config['symlinks'].each_pair do |source, symlink|
      target_path = "#{compiled_path}/#{source}"
      symlink_path = "#{config['symlinks_path']}/#{symlink}"
      symlink(target_path, symlink_path)
    end
  end
end

desc 'Reconfigure OSX settings'
task :osx => :compile do
  log 'Configuring osx...'
  system('chmod', '+x', "#{compiled_path}/osx")
  `cd #{compiled_path} && ./osx`
  `cd #{dotfiles_path}`
end


desc 'Update dependencies to latest versions, compile, and symlink'
task :update => ['update:oh_my_zsh', 'update:janus', :default]

namespace :update do
  # desc 'Update oh-my-zsh to latest'
  task :oh_my_zsh do
    update_submodule 'oh-my-zsh'
  end

  # desc 'Update Janus to latest'
  task :janus do
    update_submodule 'janus'
    show_action 'Delete', "#{tmp_path}/janus"
    FileUtils.rm_rf("#{tmp_path}/janus")
  end
end

desc 'Remove symlinks, wipe cloned submodules, compiled, and tmp dirs'
task :cleanup do
  decorate('Cleaning up...') do
    config['symlinks'].each_pair do |source, symlink|
      symlink_path = "#{config['symlinks_path']}/#{symlink}"
      show_action 'Delete', symlink_path
      FileUtils.rm_f(symlink_path)
    end

    SUBMODULES.each do |name|
      submodule_path = "#{dotfiles_path}/#{name}/*"
      show_action 'Delete', submodule_path
      FileUtils.rm_rf(submodule_path)
    end

    show_action 'Delete', compiled_path
    FileUtils.rm_rf(compiled_path)

    show_action 'Delete', tmp_path
    FileUtils.rm_rf(tmp_path)
  end
end

def update_submodule(name)
  path = "#{dotfiles_path}/#{name}"
  system('cd', path)
  system('git', 'pull')
  system('cd', dotfiles_path)
end

def prepare_compiled_dir
  show_action 'Delete', compiled_path
  FileUtils.rm_rf(compiled_path)

  show_action 'Create', compiled_path
  FileUtils.mkdir_p(compiled_path)

  compiled_path
end

def prepare_tmp_dir
  unless File.exists?(tmp_path)
    show_action('Create', tmp_path)
    FileUtils.mkdir_p(tmp_path)
  end

  tmp_path
end

def compiled_path
  "#{dotfiles_path}/compiled"
end

def dotfiles_path
  config['dotfiles_path']
end

def tmp_path
  "#{dotfiles_path}/tmp"
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

def patch(target_path, patch_path)
  show_transition "Patch", patch_path, target_path
  unless system('patch', target_path, '-i', patch_path, '-s')
    $stderr.puts 'Patch failed!'
    exit(1)
  end
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

def apply_patches
  Dir["#{compiled_path}/patches/*.patch"].each do |patch_path|
    patch = File.read(patch_path)
    if data = patch.match(/APPLY-TO\s+(\S+)/)
      target_path = "#{compiled_path}/#{data[1]}"
      patch(target_path, patch_path)
    else
      next
    end
  end
end

def decorate(title)
  log title
  yield
  log "\n"
end

def action_message(verb, target, options = {})
  ljust = options[:ljust] || 7
  verb = green(verb.ljust(ljust))
  "#{verb} #{target}"
end

def show_action(verb, target, options = {})
  log(action_message(verb, target, options))
end

def show_transition(verb, origin, destination, options = {})
  log "#{action_message(verb, origin, options)} => #{destination}"
end

def green(text)
  "\e[32m#{text}\e[0m"
end

def log(text)
  puts text if ENV['DEBUG']
end