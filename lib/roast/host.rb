module Roast
  class Host
    IP_PATTERN       = /\A([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}\z/
    HOST_PATTERN     = /\A[a-z0-9\-\.]+\z/

    attr_reader   :ip_address
    attr_reader   :hostname
    attr_accessor :alias

    def initialize(source, hostname)
      if source !~ IP_PATTERN
        @alias = source.chomp
        resolve_source
      else
        @ip_address = source.chomp
      end
      @hostname   = hostname.chomp.downcase
      @state      = 'enabled'
      validate!
    end

    def validate!
      raise ArgumentError, "`#{hostname}' is an invalid hostname" unless hostname =~ HOST_PATTERN
    end

    def resolve_source
      @ip_address = IPSocket.getaddress(@alias)
    rescue SocketError
      raise ArgumentError, "unable to determine the ip address of `#{@alias}'"
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
