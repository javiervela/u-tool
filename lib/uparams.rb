require_relative "hostfile"

module UParams
  @ARGS = {}
  @UNFLAGGED_ARGS = [:name] # Inicialmente se espera Host o group

  USAGE = <<ENDUSAGE
Usage: ./u [ GROUP | MACHINE ] COMMAND [ OPTIONS ]
ENDUSAGE

  HELP = <<ENDHELP
CONFIGURATION FILES:
    ./.u/hosts: List of hosts. To work correctly, host must be defined in ~/.ssh/config with Host: IP (same in .u/hosts).
    ./.u/manifiestos: List of Puppet manifests to use "config" command
COMMANDS:
    p, ping                   Ping hosts (timeout 0.1 ms)
    s, ssh <command>          Execute <command> through SSH in hosts
    c, config <manifest list> Configure hosts with Puppet manifests
OPTIONS:
    -h, --help                Show this help
    -t, --timeout             Set COMMAND timeout
ENDHELP

=begin 
  Parse ARGV for commands and arguments
=end  
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
      when "c", "config"
        @next_arg = :config
      when "-t", "--timeout"
        @next_arg = :timeout
      else
        if @next_arg
          if @next_arg == :config
            if !@ARGS[:config]
              @ARGS[:config] = []
            end
            @ARGS[@next_arg].push(arg)
            @UNFLAGGED_ARGS.push(@next_arg)
          else
            @ARGS[@next_arg] = arg
            @UNFLAGGED_ARGS.delete(@next_arg)
          end
          @UNFLAGGED_ARGS.delete(:name)
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

=begin 
  Check arguments and display Help or Usage
=end
  def self.check_args(file)
    # Check empty
    if @ARGS.empty?
      @ARGS[:help] = true
    end

    # If config was not specified
    if @next_arg == :config && !@ARGS[:config]
      puts USAGE
      exit 1
    end

    # If host or group are not specifed, OK
    if @next_arg != nil && @next_arg != :name && @next_arg != :config
      puts USAGE
      exit 1
    end

    # Print help
    if @ARGS[:help]
      puts USAGE
      puts HELP
      exit 0
    end

    # Optional group or host
    if @ARGS[:name]
      type = file.include? @ARGS[:name]
      if !type # It does not exist
        puts "#{$COLOR_RED}ERROR:#{$COLOR_NONE} Host or group '#{@ARGS[:name]}' does NOT exist!"
        exit 1
      end
      @ARGS[type] = @ARGS[:name] # Add :group or :host
    end
  end
end
