module Roast
  class HostsFile
    GROUP_PATTERN     = /^###? ROAST \[([\w-]+)\]$/
    DISABLED_PATTERN  = /^###/
    END_GROUP_PATTERN = /^###? TSAOR$/

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

    def read
      in_group      = false
      group         = nil

      File.open(path, 'r') do |file|
        file.each_line do |line|
          if _match = line.match(GROUP_PATTERN)
            in_group      = true
            group         = _match[1]
            @groups[group] ||= Group.new(group)
            @groups[group].disable! if line =~ DISABLED_PATTERN
          elsif line.match(END_GROUP_PATTERN)
            in_group = false
          elsif in_group
            @groups[group] << Host.parse_and_create(line)
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
      # TODO: init one if it's not there
      @groups[group] << Host.new(ip_address, hostname)
      write
    end

    def enable(entry)
      results = find_host(entry)

      results.each { |h| h.enable! }
      write

      results
    end

    def disable(entry)
      results = find_host(entry)

      results.each { |h| h.disable! }
      write

      results
    end

    def delete(entry)
      results = delete_host(entry)
      write

      results
    end

    def enable_group(group)
      return false unless @groups.has_key?(group)

      @groups[group].enable!
      write

      true
    end

    def disable_group(group)
      return false unless @groups.has_key?(group)

      @groups[group].disable!
      write

      true
    end

    def delete_group(group)
      return false unless @groups.has_key?(group)

      @groups.delete(group)
      write

      true
    end

    def list
      [path, groups]
    end

  end
end
