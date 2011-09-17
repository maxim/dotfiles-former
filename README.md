# Self-generating dotfiles

### Goals

- Depend easily on other packages (single-command update)
- Keep everything under version control
- Have idempotent yet flexible script that sets everything up

I want to be able to easily depend on other packages for my dotfiles, such as [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), or [janus](https://github.com/carlhuda/janus). When I say "easily depend" I mean being able to run a single command to get the latest package updates without having to redo my customizations. That's the main goal. The second goal is to keep everything under _public_ version control (meaning, private stuff is consolidated and easily gitignored). The third goal is to have a consistent and idempotent, yet flexible bootstrap script. I decided to go the rake route, since I'm a rubyist, and rake is packaged with ruby by default, thus available on every mac.

### Design

The default rake task runs the following chain.

    [ :prepare_directories,
      :prepare_submodules,
      :pre_process,
      :copy,
      :compile,
      :symlink,
      :post_process ]

The main idea here is that the files and directories in the root of git repo are not the ones being used, they are only the source files. You can modify them and run rake to update your actual dotfiles, which reside in `compiled` dir. This separation enables a couple of important possibilities.

- it's possible to run erb on config files
- it's possible to patch dependencies while preserving the clean state for updates

Essentially, the rake task creates `compiled` directory, initializes submodules (oh-my-zsh, janus), copies everything to `compiled` dir, compiles every `foo.erb` replacing it with `foo`, then symlinks the specified files and directories to your home dir.

However, that's not all. There is also pre- and post-processing. The pre-processor is running before anything is copied. For example, it caches Janus into `tmp` dir, patches it there, then temporarily symlinks `~/.vim` to that Janus cached dir, runs Janus's rake command to install it. This way Janus can be integrated with everything else, and yet be an easily updateable submodule.

A post-processor is run after everything else is done. For example, it symlinks a custom zsh directory into `oh-my-zsh` (inside `compiled` dir), and adds my theme to `oh-my-zsh`, because they don't have a customization hook for that.


### Install

    cd ~
    git clone git://github.com/maxim/dotfiles.git Dotfiles
    cd Dotfiles
    rake

### OS X Customizations

    cd ~/Dotfiles
    rake osx

### Make changes

    cd ~/Dotfiles
    # make changes
    rake

### Update dependencies

    cd ~/Dotfiles
    rake update

### Remove everything generated

Removes symlinks too, be careful

    cd ~/Dotfiles
    rake cleanup
