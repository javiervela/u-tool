require "net/ping/tcp"
require_relative "ussh"

=begin 
  Ping host via TCP
=end
class UPing
  def initialize(port: "ssh", timeout: 0.1)
    @port = port
    @timeout = timeout
    @host_default = nil
    @ping = Net::Ping::TCP.new(@host_default, @port, @timeout)
  end

=begin 
  Exec ping to host
=end
  def exec_ping(host, repeat: true)
    print "#{host}: "
    if @ping.ping(host)
      ms = (@ping.duration * 1000).to_i
      puts "#{$COLOR_GREEN}FUNCIONA#{$COLOR_NONE} (#{ms} ms.)"
    elsif repeat
      # If it fails, lookup in ssh/config file and repeat ping
      host = USSH.new().find_ip(host)
      if host
        exec_ping(host, :repeat => false)
      else
        puts "#{$COLOR_RED}FALLA#{$COLOR_NONE}"
      end
    else
      puts "#{$COLOR_RED}FALLA#{$COLOR_NONE}"
    end
  end
end
