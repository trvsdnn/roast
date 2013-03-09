module Roast
  class Group
    attr_reader :name
    attr_reader :hosts

    def initialize(name)
      @name     = name
      @hosts    = {}
      @disabled = false
    end

    def disabled!
      @disabled = true
    end

    def disabled?
      @disabled
    end

    def <<(host)
      hosts[host.hostname.to_sym] = host
    end

    def entries_to_s(reversed = false)
      string = ''
      return string if hosts.empty?

      # TODO: not happy with this reversed junk
      if reversed
        max = hosts.values.map { |h| h.hostname.size }.max
      else
        max = hosts.values.map { |h| h.ip_address.size }.max
      end

      hosts.values.each do |host|
        pieces = [ host.ip_address, host.hostname ]
        pieces.reverse! if reversed

        padding = ' ' * (max - pieces.first.size + 4)
        string << "#{pieces.first}#{padding}#{pieces.last}\n"
      end

      string
    end

    def section(&block)
      result = disabled? ? '###' : '##'
      result << " ROAST [#{name}]\n"
      result << yield
      result << (disabled? ? '###' : '##')
      result << " TSAOR\n"

      result
    end

    def to_s
      section do
        if disabled?
          entries_to_s.gsub(/^/, '# ')
        else
          entries_to_s
        end
      end
    end
  end
end