CONFIG_PATH = 'config.yml'

task :default => :symlink

desc 'Run files through erb and install symlinks'
task :symlink do
  require 'yaml'
  require 'erb'
  require 'fileutils'

  compiled_dir = prepare_compiled_dir

  puts "Will generate: #{config['symlinks'].values.join(', ')}\n\n"

  config['symlinks'].each_pair do |source, symlink|
    source_path = "#{config['dotfiles_path']}/#{source}"
    compiled_path = "#{compiled_dir}/#{source}"
    symlink_path = "#{config['symlinks_path']}/#{symlink}"

    if File.directory?(source_path)
      copy(source_path, compiled_path)
    else
      compile_with_locals(source_path, compiled_path, :config => config)
    end

    symlink(compiled_path, symlink_path)
    puts "\n"
  end
end

desc 'Install Janus if it exists in vim subdir.'
task :janus do
  compiled_dir = prepare_compiled_dir

  if janus_detected?
    show_transition 'Install Janus', "#{config['dotfiles_path']}/vim", "#{compiled_dir}/vim"
    system 'sudo rm -rf compiled/vim && cp -rf vim compiled/'
    symlink "#{compiled_dir}/vim", "#{config['symlinks_path']}/.vim"
    puts 'Running Janus rake'
    system 'cd compiled/vim && sudo rake > /dev/null 2>&1'
  else
    puts "Skipping Janus installation."
  end
end

desc 'Run rake symlink and rake janus.'
task :full => [:symlink, :janus]

def prepare_compiled_dir
  compiled_dir = "#{config['dotfiles_path']}/compiled"
  FileUtils.mkdir_p(compiled_dir)
  compiled_dir
end

def config
  @config ||= YAML.load(ERB.new(File.read(CONFIG_PATH)).result(binding))
end

def copy(origin, destination)
  show_transition "Copy", origin, destination
  FileUtils.rm_rf destination
  FileUtils.cp_r(origin, destination, :remove_destination => true)
end

def compile_with_locals(origin, destination, locals = {})
  show_transition "Compile", origin, destination
  template = ERB.new(File.read(origin))
  binding_with_locals = build_binding_with_locals(locals)

  File.open(destination, 'w') do |file|
    file.write(template.result(binding_with_locals))
  end
end

def symlink(existing_path, symlink_path)
  show_transition "Symlink", symlink_path, existing_path
  FileUtils.rm_f symlink_path
  FileUtils.ln_sf existing_path, symlink_path
end

def build_binding_with_locals(locals = {})
  wrapper = Class.new do
    def get_binding
      binding
    end
  end

  binding_with_locals = wrapper.new.get_binding

  locals.each_pair do |name, value|
    eval("#{name} = #{value.inspect}", binding_with_locals)
  end

  binding_with_locals
end

def show_transition(verb, origin, destination)
  puts "#{verb} #{origin} => #{destination}"
end

def janus_detected?
  janus_git_config = 'vim/.git/config'
  File.exist?(janus_git_config) && File.read(janus_git_config) =~ /janus\.git/
end
