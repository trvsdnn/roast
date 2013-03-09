module Roast
  class Host
    IP_HOST_PATTERN = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\s]+)/

    attr_reader :ip
    attr_reader :host

    def initialize(ip, host)
      @ip    = ip
      @host  = host
    end

    def line
      "#{@ip} #{@host}"
    end

    def self.parse_and_create(line)
      ip, host = line.match(IP_HOST_PATTERN)[1..2]
      Host.new(ip, host)
    end
  end
end