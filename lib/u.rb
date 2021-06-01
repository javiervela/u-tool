require_relative "u/version"
require_relative "hostfile"
require_relative "uparams"
require_relative "uping"
require_relative "uconfig"
require_relative "ussh"

module U
  class Error < StandardError; end

  #$HOST_FILE = "./.u/hosts"

  # Screen colors
  $COLOR_NONE = "\e[0m"
  $COLOR_RED = "\e[0;31m"
  $COLOR_GREEN = "\e[0;32m"

  # MAIN procedure
  def self.main()
    begin
      # Parse hostfile
      file = HostFile.new("./.u", "./.u/hosts")
      file.read()

      # Parse comand arguments
      @ARGS = UParams.parse(file)

      # Get hostlist
      @hostlist = file.hostlist(@ARGS)

      # Execute command
      if @ARGS[:ping]
        if @ARGS[:timeout]
          @uping = UPing.new(timeout: @ARGS[:timeout].to_f)
        else
          @uping = UPing.new()
        end
        @hostlist.each do |host|
          @uping.exec_ping(host)
        end
      elsif @ARGS[:ssh]
        if @ARGS[:timeout]
          @ussh = USSH.new(command: @ARGS[:ssh], timeout: @ARGS[:timeout].to_f)
        else
          @ussh = USSH.new(command: @ARGS[:ssh])
        end
        @hostlist.each do |host|
          @ussh.exec_ssh(host)
        end
      elsif @ARGS[:config]
        manifests = @ARGS[:config]
        @uconfig = UConfig.new(manifests: manifests)
        @hostlist.each do |host|
          @uconfig.exec_config(host)
        end
      end
    rescue Interrupt
      puts "\n#{$COLOR_RED}ERROR: #{$COLOR_NONE}Interrupt by user\n"
    end
  end
end
