module Roast
  class Host
    IP_HOST_PATTERN = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\s]+)/

    attr_reader :ip_address
    attr_reader :hostname

    def initialize(ip_address, hostname)
      @ip_address = ip_address
      @hostname   = hostname
    end

    def self.parse_and_create(line)
      ip_address, hostname = line.match(IP_HOST_PATTERN)[1..2]
      Host.new(ip_address, hostname)
    end
  end
end
