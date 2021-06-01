require "net/ssh"

=begin 
  Execute SSH command in host
=end
class USSH
  def initialize(command: "", timeout: 20, verbose: true)
    @command = command
    @timeout = timeout
    @verbose = verbose
    #@ssh_config = "/home/" + ENV["USERNAME"] + "/.ssh/config"
    @ssh_config = "./.u/ssh/config"
    if not File.exists?(@ssh_config)
      puts "#{$COLOR_RED}WARNING:#{$COLOR_NONE} file #{@ssh_config} does not exist"
    end
  end

  def ssh_config
    @ssh_config
  end

=begin 
  Find host IP in ssh/config 
=end
  def find_ip(host)
    return Net::SSH.configuration_for(host, @ssh_config)[:host_name]
  end

=begin 
  Exec command with SSH
=end
   def exec_ssh(host)
    begin
      if @verbose
        print "#{host} (#{@command}): "
      end
      # Start SSH conection
      Net::SSH.start(host, nil, :non_interactive => true, :timeout => @timeout, :config => @ssh_config) do |ssh|
        # Esxecute command
        result = ssh.exec!(@command)
        if @verbose
          puts "#{$COLOR_GREEN}ÉXITO#{$COLOR_NONE}"
          puts result
        end
      end
    # Handle possible errors
    rescue Net::SSH::AuthenticationFailed
      puts "#{$COLOR_RED}ERROR: #{$COLOR_NONE}Authentication failed"
    rescue Net::SSH::ConnectionTimeout
      puts "#{$COLOR_RED}ERROR: #{$COLOR_NONE}Conexion timeout"
    rescue Errno::EHOSTUNREACH
      puts "#{$COLOR_RED}ERROR: #{$COLOR_NONE}No route to host"
    rescue Errno::ENETUNREACH
      puts "#{$COLOR_RED}ERROR: #{$COLOR_NONE}Network unreachable"
    rescue Errno::ECONNREFUSED
      puts "#{$COLOR_RED}ERROR: #{$COLOR_NONE}Connection refused"
    rescue SocketError
      puts "#{$COLOR_RED}ERROR: #{$COLOR_NONE}No address associated with hostname"
    rescue => error
      puts "#{$COLOR_RED}ERROR*: #{$COLOR_NONE}#{error}"
    end
  end
end
