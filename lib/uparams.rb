require_relative 'hostfile'

module UParams
  @ARGS = {}
  @UNFLAGGED_ARGS = [:host] # Inicialmente se espera Host o group

  USAGE = <<ENDUSAGE
Usage: ./u [ GROUP | MACHINE ] COMMAND [ OPTIONS ]
ENDUSAGE

  HELP = <<ENDHELP
CONFIGURATION FILE:
    ./.u/hosts: List of hosts (to work correctly, host must be defined in ~/.ssh/config)
COMMANDS:
    p, ping             Ping all hosts (timeout 0.1 ms)
    s, ssh <command>    Execute <command> through SSH in all hosts
OPTIONS:
    -h, --help          Show this help
    -t, --timeout       Set COMMAND timeout
ENDHELP

  def self.parse(file)
    @next_arg = @UNFLAGGED_ARGS.first
    ARGV.each do |arg|
      case arg
      when "-h", "--help"
        @ARGS[:help] = true
      when "p", "ping"
        @ARGS[:ping] = true
      when "s", "ssh"
        @next_arg = :ssh
      when "-t", "--timeout"
        @next_arg = :timeout
      else
        if @next_arg
          @ARGS[@next_arg] = arg
          @UNFLAGGED_ARGS.delete(@next_arg)
        else
          puts USAGE
          exit 1
        end
        @next_arg = @UNFLAGGED_ARGS.first
      end
    end
    check_args(file)
    return @ARGS
  end

  def self.check_args(file)
    # Check arguments
    if @ARGS.empty?
      @ARGS[:help] = true
    end
    # If host or group are not specifed, OK
    if @next_arg != nil && @next_arg != :host
      puts USAGE
      exit 1
    end
    # Print help
    if @ARGS[:help]
      puts USAGE
      puts HELP
      exit 0
    end

    if @ARGS[:host]

      if !file.include? @ARGS[:host]
        puts "#{$COLOR_RED}Host or group '#{@ARGS[:host]}' does NOT exist!#{$COLOR_NONE}"
        exit 1
      end
    end
  end

end
