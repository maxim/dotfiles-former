CONFIG_PATH = 'config.yml'

desc 'Run files through erb and install symlinks'
task :install do
  require 'yaml'
  require 'erb'
  require 'fileutils'

  config = YAML.load(ERB.new(File.read(CONFIG_PATH)).result(binding))

  compiled_dir = "#{config['dotfiles_path']}/compiled"
  FileUtils.mkdir_p(compiled_dir)

  puts "Will generate: #{config['symlinks'].values.join(', ')}\n\n"
  config['symlinks'].each_pair do |source, symlink|
    source_path = "#{config['dotfiles_path']}/#{source}"
    compiled_path = "#{compiled_dir}/#{source}"
    symlink_path = "#{config['symlinks_path']}/#{symlink}"

    compile_with_locals(source_path, compiled_path, :config => config)
    symlink(compiled_path, symlink_path)
    puts "\n"
  end
end

def compile_with_locals(origin, destination, locals = {})
  puts "Compile #{origin} => #{destination}"
  template = ERB.new(File.read(origin))
  binding_with_locals = build_binding_with_locals(locals)

  File.open(destination, 'w') do |file|
    file.write(template.result(binding_with_locals))
  end
end

def symlink(existing_path, symlink_path)
  puts "Symlink #{symlink_path} => #{existing_path}"
  system 'ln', '-sf', existing_path, symlink_path
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