module Roast
  class Host
    IP_PATTERN       = /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z/
    HOST_PATTERN     = /\A[a-z0-9\-\.]+\z/

    attr_reader   :ip_address
    attr_reader   :hostname
    attr_accessor :alias

    def initialize(ip_address, hostname)
      # TODO: use options here, all this logic sucks
      if ip_address !~ IP_PATTERN
        @alias = ip_address.chomp
        resolve_alias
      else
        @ip_address = ip_address.chomp
      end
      @hostname   = hostname.chomp.downcase
      @state      = 'enabled'
      validate!
    end

    def validate!
      raise ArgumentError, "`#{ip_address}' is an invalid ip address" unless ip_address =~ IP_PATTERN
      raise ArgumentError, "`#{hostname}' is an invalid hostname" unless hostname =~ HOST_PATTERN
    end

    def resolve_alias
      @ip_address = IPSocket.getaddress(@alias)
    rescue SocketError
      raise ArgumentError, "unable to determine the IP of #{@alias}"
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
