module Roast
  class HostsFile
    GROUP_PATTERN = /^## \[([\w\s-]+)\]$/
    HOST_PATTERN  = /^#?\s*(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\s]+)/
    DISABLED_PATTERN = /^# \d+/

    attr_reader :path
    attr_reader :static_lines

    def initialize(path = '/etc/hosts')
      @path         = path
      @static_lines = []
      @groups       = {}
    end

    def groups
      @groups.values
    end

    def hosts
      groups.map { |g| g.hosts }.flatten
    end

    def [](group)
      @groups[group]
    end

    def read
      in_group = false
      group    = nil

      File.open(path, 'r') do |file|
        file.each_line do |line|
          if group_match = line.match(GROUP_PATTERN)
            in_group = true
            group    = Group.new(group_match[1])
            @groups[group.name] ||= group
          elsif group && host_match = line.match(HOST_PATTERN)
            host = Host.new(host_match[1], host_match[2])
            host.disable! if line =~ DISABLED_PATTERN
            group << host
          else
            static_lines << line
          end
        end
      end

      self
    end

    def write(output_path = nil)
      output_path = output_path || path
      temp_file   = Tempfile.new('hosts')

      temp_file << static_lines.join.sub(/\n{3,}\z/, "\n\n")
      temp_file << groups.map { |g| g.to_hosts_file.chomp }.join("\n\n")

      File.chmod(0644, temp_file.path)
      FileUtils.cp(path, path + '.bak') if output_path.eql?(path)
      FileUtils.mv(temp_file.path, output_path, :force => true)
    ensure
      temp_file.close
      temp_file.unlink
    end

    def find_host(entry)
      groups.map { |g| g.find_host(entry) }.flatten
    end

    def delete_host(entry)
      groups.map { |g| g.delete_host(entry) }.flatten
    end

    def add(group, ip_address, hostname)
      @groups[group] ||= Group.new(group)
      @groups[group] << Host.new(ip_address, hostname)
    end

    def enable(entry)
      results = find_host(entry)

      results.each { |h| h.enable! }
      results
    end

    def disable(entry)
      results = find_host(entry)

      results.each { |h| h.disable! }
      results
    end

    def delete(entry)
      results = delete_host(entry)

      results
    end

    def enable_group(group)
      return false unless @groups.has_key?(group)

      @groups[group].enable!

      true
    end

    def disable_group(group)
      return false unless @groups.has_key?(group)

      @groups[group].disable!

      true
    end

    def delete_group(group)
      return false unless @groups.has_key?(group)

      @groups.delete(group)

      true
    end

    def list
      [path, groups]
    end

  end
end
