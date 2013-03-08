module Roast
  class Host
    IP_HOST_PATTERN = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\s]+)/

    attr_reader :ip
    attr_reader :host

    def initialize(attributes = {})
      @group = attributes[:group]
      @ip    = attributes[:ip]
      @host  = attributes[:host]
    end

    def line
      "#{@ip} #{@host}"
    end

    def self.parse_and_create(group, line)
      ip, host = line.match(IP_HOST_PATTERN)[1..2]
      Host.new(:group => group, :ip => ip, :host => host)
    end
  end
end