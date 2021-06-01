class HostFile
  def initialize(directory, filename)
    @directory = directory
    @filename = filename
    @groups = []
    @hosts = {}
  end

  def check_config()
    # Check configuration dir and file
    if not Dir.exists?(@directory)
      puts "Configuration folder #{@directory} does NOT exist!"
      exit 1
    elsif not File.exists?(@filename)
      puts "Hosts file #{@filename} does NOT exist!"
      exit 1
    end
  end

  def read()
    self.check_config()
    File.readlines(@filename).map(&:chomp).each do |line|
      if line[0, 1] == "-" # Group creation
        @last_group = line[1..-1]
        @groups.push(@last_group)
        @hosts[@last_group] = []
      elsif line[0, 1] == "+" # Group reference
        group = line[1..-1]
        @hosts[group].each do |host|
          # TODO Compare to existing in group before adding
          @hosts[@last_group].push(host)
        end
      else # Host
        @hosts[@last_group].push(line)
      end
    end
  end

  def include?(name)
    if @hosts.has_key? name
      # First return if group exists
      return true
    else
      @hosts.each do |group|
        if group[1].include? name
          return true
        end
      end
      return false
    end
  end
end
