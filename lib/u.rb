# frozen_string_literal: true

require_relative "u/version"
require_relative "hostfile"
require_relative "uparams"
require "net/ssh"
require "net/ping/tcp"

module U
  class Error < StandardError; end

  #$HOST_FILE = "./.u/hosts"

  # Screen colors
  $COLOR_NONE = "\e[0m"
  $COLOR_RED = "\e[0;31m"
  $COLOR_GREEN = "\e[0;32m"

  # Exec ping to host
  def self.exec_ping(p, host)
    print "#{host}: "
    if p.ping(host)
      ms = (p.duration * 1000).to_i
      puts "#{$COLOR_GREEN}FUNCIONA#{$COLOR_NONE} (#{ms} ms.)"
    else
      puts "#{$COLOR_RED}FALLA#{$COLOR_NONE}"
    end
  end

  # Exec command with SSH
  def self.exec_ssh(host, command, timeout)
    begin
      if host == ""
        puts "#{$COLOR_RED}WARNING: empty line in .u/hosts#{$COLOR_NONE}"
      end
      print "#{host}: "
      Net::SSH.start(host, nil, :non_interactive => true, :timeout => timeout) do |ssh|
        result = ssh.exec!(command)
        puts "#{$COLOR_GREEN}ÉXITO#{$COLOR_NONE}"
        puts result
      end
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

  def self.main()
    # MAIN procedure
    file = HostFile.new("./.u", "./.u/hosts")
    file.read()
    
    @ARGS = UParams.parse(file)

    if @ARGS[:host]
      if !file.include? @ARGS[:host]
        puts "#{$COLOR_RED}Host or group '#{@ARGS[:host]}' does NOT exist!#{$COLOR_NONE}"
        exit 1
      end
    end

    begin
      if @ARGS[:ping]
        port = "ssh" || 22
        host_default = nil
        if @ARGS[:timeout]
          timeout = @ARGS[:timeout].to_i
        else
          timeout = 0.1
        end
        p = Net::Ping::TCP.new(host_default, port, timeout)
        #File.readlines($HOST_FILE).map(&:chomp).each do |host|
        #  exec_ping(p, host)
        #end
      elsif @ARGS[:ssh]
        command = @ARGS[:ssh]
        if @ARGS[:timeout]
          timeout = @ARGS[:timeout].to_i
        else
          timeout = 20
        end
        if not File.exists?("/home/" + ENV["USERNAME"] + "/.ssh/config")
          puts "#{$COLOR_RED}WARNING: file ~/.ssh/config does not exist#{$COLOR_NONE}"
        end
        if not command
          puts HELP
          exit 1
        end
        #File.readlines($HOST_FILE).map(&:chomp).each do |host|
        #  exec_ssh(host, command, timeout)
        #end
      end
    rescue Interrupt
      puts "\n#{$COLOR_RED}Interrupt by user#{$COLOR_NONE}\n"
    end
  end
end
