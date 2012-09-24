CONFIG_PATH = 'support/config.yml'

require 'yaml'
require 'erb'
require 'fileutils'

%w(registry manager worker logger).each do |dep|
  require "./support/lib/#{dep}"
end

registry = Registry.new(CONFIG_PATH)
logger   = Logger.new(:silent => !ENV['DEBUG'])
manager  = Manager.new(registry)
worker   = Worker.new(logger, :dry => ENV['DRY'])

desc 'Setup everything first time or update things upon change'
task :default => [ :download,
                   :build,
                   :install ]

task :download do
  if manager.any_submodules_missing?
    worker.fetch_submodules
  end
end

task :build do
  logger.denote('Preparing workspace...') do
    worker.delete(registry.build_path)
    worker.mkdir(registry.build_path)
  end

  logger.denote('Building...') do
    manager.each_copy_job do |src, dst|
      worker.copy(src, dst)
    end

    erbs = []

    manager.each_erb_job do |src, dst, payload|
      worker.parse_erb(src, dst, payload)
      erbs << src
    end

    erbs.each do |path|
      worker.delete(path)
    end

    manager.invoke_post_build_tasks
  end
end

task :install do
  logger.denote('Installing...') do
    manager.each_symlink_job do |existing_path, symlink_path|
      worker.symlink(existing_path, symlink_path)
    end
  end
end

desc 'Update dependencies to latest versions, build, and symlink'
task :update do
  logger.denote 'Updating...' do
    manager.invoke_update_tasks
  end

  manager.invoke_task('default')
end

desc 'Reconfigure OSX settings'
task :osx => :build do
  logger.denote 'Configuring osx...' do
    worker.chmod(0755, registry.osx_path)
    worker.go_and_run(registry.osx_path)
  end
end

namespace :vim do
  namespace :solarized do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/solarized"
      )
    end
  end

  namespace :ctrlp do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/ctrlp"
      )
    end
  end

  namespace :irblack do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/irblack"
      )
    end
  end

  namespace :vividchalk do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/vividchalk"
      )
    end
  end

  namespace :getafe do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/getafe"
      )
    end
  end

  namespace :powerline do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/powerline"
      )
    end
  end

  namespace :ruby do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/ruby"
      )
    end
  end

  namespace :nerdcommenter do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/nerdcommenter"
      )
    end
  end

  namespace :ack do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/ack"
      )
    end
  end

  namespace :fugitive do
    task :update do
      worker.update_submodule(
        "#{registry.dotfiles_path}/vim/bundle/fugitive"
      )
    end
  end
end

namespace :oh_my_zsh do
  task :post_build do
    # symlink oh-my-zsh/custom to zsh/
    worker.symlink "#{registry.build_path}/zsh",
                   "#{registry.build_path}/oh-my-zsh/custom"

    # symlink all themes under zsh/themes from oh-my-zsh/themes
    dst_theme_dir = "#{registry.build_path}/oh-my-zsh/themes"
    themes_src_glob = "#{registry.build_path}/zsh/themes/*.zsh-theme"

    Dir[themes_src_glob].each do |src_theme_path|
      worker.symlink src_theme_path,
        "#{dst_theme_dir}/#{File.basename(src_theme_path)}"
    end
  end

  # desc 'Update oh-my-zsh to latest'
  task :update do
    worker.update_submodule "#{registry.vendor_path}/oh-my-zsh"
  end
end

desc 'Remove symlinks, wipe cloned submodules, build dir'
task :cleanup do
  logger.denote('Cleaning up...') do
    manager.each_symlink_path do |path|
      worker.delete(path)
    end

    manager.each_vendor_path do |path|
      worker.delete("#{path}/*")
    end

    worker.delete(registry.build_path)
  end
end
