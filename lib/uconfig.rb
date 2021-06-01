require "net/scp"
require_relative "ussh"

=begin 
  Apply Puppet manifests in host
=end
class UConfig
  def initialize(manifests: [])
    @manifests = manifests
    @directory = "./.u/manifiestos/"
    @timeout = 20
    @remote_dir = "/tmp/"
    @timestamp = Time.now.to_i.to_s
  end

=begin 
  Check if directory exists
=end
  def check_config()
    if not Dir.exists?(@directory)
      puts "#{$COLOR_RED}ERROR:#{$COLOR_NONE} Manifests folder #{@directory} does NOT exist!"
      exit 1
    end
    @manifests.each do |file|
      if not File.exists?(@directory + file)
        puts "#{$COLOR_RED}WARNING:#{$COLOR_NONE} Manifest #{@directory + file} does NOT exist! It won't be applied"
        @manifests.delete(file)
      end
    end
  end


=begin 
  Send Puppet manifest to host via SCP
=end
  def send_manifests(host)
    @manifests.each do |file|
      path = @directory + file
      remote_path = @remote_dir + file + @timestamp
      Net::SCP.start(host, nil, :non_interactive => true, :timeout => @timeout, :config => USSH.new().ssh_config) do |scp|
        scp.upload! path, remote_path
      end
      puts "Manifest #{file} sent to #{host}..."
    end
  end

=begin 
  Apply Puppet manifest via SSH
=end
  def execute_manifest(host)
    @manifests.each do |file|
      remote_path = @remote_dir + file + @timestamp
      ussh = USSH.new(command: "sudo puppet apply #{remote_path}", timeout: @timeout)
      ussh.exec_ssh(host)
    end
  end
  
=begin 
  Remove Puppet manifest from host via SSH
=end
  def remove_manifests(host)
    @manifests.each do |file|
      remote_path = @remote_dir + file + @timestamp
      ussh = USSH.new(command: "rm #{remote_path}", timeout: @timeout, verbose: false)
      ussh.exec_ssh(host)
      puts "Manifest #{file} removed from #{host}..."
    end
  end

=begin 
  Execute the operations for host
=end
  def exec_config(host)
    check_config()
    send_manifests(host)
    execute_manifest(host)
    remove_manifests(host)
  end
end
