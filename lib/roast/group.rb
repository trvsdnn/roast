module Roast
  class Group
    attr_reader :name

    def initialize(name)
      @name     = name
      @hosts    = {}
    end

    def disable!
      hosts.each { |h| h.disable! }
    end

    def enable!
      hosts.each { |h| h.enable! }
    end

    def disabled?
      hosts.all? { |h| h.disabled? }
    end

    def enabled?
      hosts.all? { |h| h.enabled? }
    end

    def hosts
      @hosts.values
    end

    def <<(host)
      @hosts[host.hostname] = host
    end

    def [](hostname)
      @hosts[hostname]
    end

    def find_host(entry)
      if entry =~ Host::IP_PATTERN
        hosts.select { |h| h.ip_address == entry }
      else
        hosts.select { |h| h.hostname == entry }
      end
    end

    def delete_host(entry)
      deleted = []
      if entry =~ Host::IP_PATTERN
        @hosts.each { |k, h| deleted << @hosts.delete(k) if h.ip_address == entry }
      else
        @hosts.each { |k, h| deleted << @hosts.delete(k) if h.hostname == entry }
      end

      deleted
    end

    def to_cli
      string = " - \033[4m#{name}\033[0m\n"
      max    = hosts.map { |h| h.hostname.size }.max

      hosts.each do |host|
        padding = ' ' * (max - host.hostname.size + 4)
        if host.disabled?
          string << "   \033[31m #{["00D7".to_i(16)].pack("U*")} "
        else
          string << '      '
        end
        string << "#{host.hostname}#{padding}#{host.ip_address}\033[0m\n"
      end

      string
    end

    def to_hosts_file
      max     = hosts.map { |h| h.ip_address.size }.max
      section = "## [#{name}]\n"

      hosts.each do |host|
        padding = ' ' * (max - host.ip_address.size + 4)
        section << '# ' if host.disabled?
        section << "#{host.ip_address}#{padding}#{host.hostname}\n"
      end

      section
    end

  end
end
