module Roast
  class Group
    attr_reader :name
    attr_reader :hosts

    def initialize(name)
      @name     = name
      @hosts    = {}
    end

    def disable!
      hosts.values.each { |h| h.disable! }
    end

    def enable!
      hosts.values.each { |h| h.enable! }
    end

    def disabled?
      hosts.values.all? { |h| h.disabled? }
    end

    def enabled?
      hosts.values.all? { |h| h.enabled? }
    end

    def <<(host)
      hosts[host.hostname] = host
    end

    def [](hostname)
      hosts[hostname]
    end

    def to_cli
      string = " - \033[4m#{name}\033[0m\n"
      max    = hosts.values.map { |h| h.hostname.size }.max

      hosts.values.each do |host|
        padding = ' ' * (max - host.hostname.size + 4)
        if host.disabled?
          string << "   \033[31m \u00D7 "
        else
          string << '      '
        end
        string << "#{host.hostname}#{padding}#{host.ip_address}\033[0m\n"
      end

      string
    end

    def to_hosts_file
      max     = hosts.values.map { |h| h.ip_address.size }.max
      section = "## ROAST [#{name}]\n"

      hosts.values.each do |host|
        padding = ' ' * (max - host.ip_address.size + 4)
        section << '# ' if host.disabled?
        section << "#{host.ip_address}#{padding}#{host.hostname}\n"
      end

      section << "## TSAOR"

      section
    end

  end
end
