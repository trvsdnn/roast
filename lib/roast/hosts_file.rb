module Roast
  class HostsFile
    GROUP_PATTERN     = /^###? ROAST \[([\w-]+)\]$/
    DISABLED_PATTERN  = /^###/
    END_GROUP_PATTERN = /^###? TSAOR$/

    attr_reader :path
    attr_reader :static_lines
    attr_reader :groups

    def initialize(path = '/etc/hosts')
      @path         = path
      @static_lines = []
      @groups       = {}
    end

    def read
      in_group      = false
      group         = nil

      File.open(path, 'r') do |file|
        file.each_line do |line|
          if _match = line.match(GROUP_PATTERN)
            in_group      = true
            group         = _match[1]
            groups[group] ||= Group.new(group)
            groups[group].disable! if line =~ DISABLED_PATTERN
          elsif line.match(END_GROUP_PATTERN)
            in_group = false
          elsif in_group
            groups[group] << Host.parse_and_create(line)
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
      temp_file << groups.values.map { |g| g.to_hosts_file.chomp }.join("\n\n")

      FileUtils.cp(path, path + '.bak') if output_path.eql?(path)
      FileUtils.mv(temp_file.path, output_path, :force => true)
    ensure
      temp_file.close
      temp_file.unlink
    end

    def find_host_by_hostname(hostname)
      results  = []

      groups.values.each do |group|
        group.hosts.values.each do |host|
          results << host if host.hostname == hostname
        end
      end

      results
    end

    def find_host_by_ip_address(ip_address)
      results = []

      groups.each do |name, group|
        group.hosts.values.each do |host|
          results << host if host.ip_address == ip_address
        end
      end

      results
    end

    def find_host(finder)
      if finder =~ Host::IP_PATTERN
        find_host_by_ip_address(finder)
      else
        find_host_by_hostname(finder)
      end
    end

    def self.add(group, ip_address, hostname)
      file = HostsFile.new.read

      file.groups[group] << Host.new(ip_address, hostname)
      file.write
    end

    def self.enable(entry)
      file    = HostsFile.new.read
      results = file.find_host(entry)

      results.each { |h| h.enable! }
      file.write

      results
    end

    def self.disable(entry)
      file    = HostsFile.new.read
      results = file.find_host(entry)

      results.each { |h| h.disable! }
      file.write

      results
    end

    def self.disable_group(group)
      file = HostsFile.new.read
      return false unless file.groups.has_key?(group)

      groups[group].disable!
      file.write

      true
    end

    def self.enable_group(group)
      file = HostsFile.new.read
      return false unless file.groups.has_key?(group)

      groups[group].enable!
      file.write

      true
    end

    def self.list
      file = HostsFile.new.read

      [file.path, file.groups]
    end

  end
end
