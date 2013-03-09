module Roast
  class Host
    IP_PATTERN = /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
    HOST_PATTERN = /\A[a-z0-9\-\.]+\z/
    IP_HOST_PATTERN = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+([^\s]+)/

    attr_reader :ip_address
    attr_reader :hostname

    def initialize(ip_address, hostname)
      @ip_address = ip_address.chomp
      @hostname   = hostname.chomp.downcase
      validate!
    end

    def validate!
      raise ArgumentError, "`#{ip_address}' is an invalid ip address" unless ip_address =~ IP_PATTERN
      raise ArgumentError, "`#{hostname}' is an invalid hostname" unless hostname =~ HOST_PATTERN
    end

    def self.parse_and_create(line)
      ip_address, hostname = line.match(IP_HOST_PATTERN)[1..2]
      Host.new(ip_address, hostname)
    end
  end
end
