module Roast
  class Hostsfile
    GROUP_PATTERN     = /^## ROAST \[([\w-]+)\]$/
    END_GROUP_PATTERN = /^## TSAOR$/

    attr_reader :path
    attr_reader :groups

    def initialize(path)
      @path   = path
      @groups = {
        :base => []
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
            groups[sgroup] ||= []
            groups[sgroup] << Host.parse_and_create(sgroup, line)
          end
        end
      end

      self
    end

  end
end
