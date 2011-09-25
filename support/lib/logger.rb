class Logger
  def initialize(options = {})
    @out_stream = options[:out_stream] || $stdout
    @err_stream = options[:err_stream] || $stderr
    @silent = options[:silent]
    @term = options[:term] || ::ENV['TERM']
  end

  def denote(title)
    state title
    yield
    state "\n"
  end

  def report(verb, target, options = {})
    if destination = options[:to]
      state("#{action_message(verb, target, options)} => #{destination}")
    else
      state(action_message(verb, target, options))
    end
  end

  def state(text, options = {})
    if options[:error]
      @err_stream.puts(text)
    else
      @out_stream.puts(text) unless @silent
    end
  end

  private
  def action_message(verb, target, options = {})
    ljust = options[:ljust] || 7
    verb = green(verb.ljust(ljust))
    "#{verb} #{target}"
  end

  def green(text)
    if @term == 'dumb'
      text
    else
      "\e[32m#{text}\e[0m"
    end
  end
end