=begin 
  Reads and parses hosts file for U
=end
class HostFile
  def initialize(directory, filename)
    @directory = directory
    @filename = filename
    #@groups = []
    @hosts = { "default" => [] }
    @all = []
    @last_group = "default"
  end

  #def groups
  #  @groups
  #end

  def hosts
    @hosts
  end

  def all
    @all
  end

=begin 
  Check if file and directory exists
=end
  def check_config()
    if not Dir.exists?(@directory)
      puts "#{$COLOR_RED}ERROR:#{$COLOR_NONE} Configuration folder #{@directory} does NOT exist!"
      exit 1
    elsif not File.exists?(@filename)
      puts "#{$COLOR_RED}ERROR:#{$COLOR_NONE} Hosts file #{@filename} does NOT exist!"
      exit 1
    end
  end

=begin 
  Reads in @host a map (group => [list of hosts])
=end
  def read()
    self.check_config()
    File.readlines(@filename).map(&:chomp).each do |line|
      if line == ""
        puts "#{$COLOR_RED}WARNING:#{$COLOR_NONE} empty line in .u/hosts"
      elsif line[0, 1] == "-" # Group creation
        @last_group = line[1..-1]
        #@groups.push(@last_group)
        @hosts[@last_group] = []
      elsif line[0, 1] == "+" # Group reference
        group = line[1..-1]
        # Adds every hosts in referenced group
        @hosts[group].each do |host|
          @hosts[@last_group].push(host)
        end
      else # Host
        @all.push(line)
        @hosts[@last_group].push(line)
      end
    end
  end

=begin 
  Returns:
    :group if name is a group
    :host if name is a host
    false if name is neither
  Returns group instead of host if both exist
=end
  def include?(name)
    if @hosts.has_key? name
      # It is a group
      return :group
    else
      @hosts.each do |group|
        if group[1].include? name
          # It is a host
          return :host
        end
      end
      # It does not exist
      return false
    end
  end

=begin 
  Returns array of host based on ARGS
    if ARGS[:group]
      hosts in group
    if ARGS[:host]
      host
    else
      all hosts
=end
  def hostlist(args)
    if args[:group]
      return @hosts[args[:group]].uniq
    elsif args[:host]
      return [args[:host]]
    else
      return @all.uniq
    end
  end
end
