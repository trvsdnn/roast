module Roast
  class Hostsfile
    GROUP_PATTERN     = /^## ROAST \[([\w-]+)\]$/
    END_GROUP_PATTERN = /^## TSAOR$/

    attr_reader :path
    attr_reader :static_lines
    attr_reader :groups

    def initialize(path)
      @path         = path
      @static_lines = []
      @groups       = {
        :base => Group.new(:base)
      }
    end

    def read
      in_group = false
      group    = nil

      File.open(path, 'r') do |file|
        file.each_line do |line|

          if _match = line.match(GROUP_PATTERN)
            in_group = true
            group    = _match[1]
          elsif line.match(END_GROUP_PATTERN)
            in_group = false
          elsif in_group
            sgroup = group.to_sym
            groups[sgroup] ||= Group.new(sgroup)
            groups[sgroup] << Host.parse_and_create(line)
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

      static_lines.each { |line| temp_file.puts(line) }
      groups.each_value { |group| temp_file.puts("#{group}\n") }

      FileUtils.cp(path, path + '.bak') if output_path.eql?(path)
      FileUtils.mv(temp_file.path, output_path, :force => true)
    ensure
      temp_file.close
      temp_file.unlink
    end

  end
end
