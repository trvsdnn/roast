module Roast
  class Host
    IP_PATTERN       = /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
    HOST_PATTERN     = /\A[a-z0-9\-\.]+\z/

    attr_reader :ip_address
    attr_reader :hostname

    def initialize(ip_address, hostname)
      @ip_address = ip_address.chomp
      @hostname   = hostname.chomp.downcase
      @state      = 'enabled'
      validate!
    end

    def validate!
      raise ArgumentError, "`#{ip_address}' is an invalid ip address" unless ip_address =~ IP_PATTERN
      raise ArgumentError, "`#{hostname}' is an invalid hostname" unless hostname =~ HOST_PATTERN
    end

    def disable!
      @state = 'disabled'
    end

    def enable!
      @state = 'enabled'
    end

    def disabled?
      @state == 'disabled'
    end

    def enabled?
      @state == 'enabled'
    end
  end
end
