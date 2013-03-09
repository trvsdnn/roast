module Roast
  class Group
    attr_reader :name
    attr_reader :hosts

    def initialize(name, hosts = [])
      @name = name
      @hosts = hosts
    end

    def <<(host)
      @hosts << host
    end

    def entries_to_s(indent = 0)
      string = ''
      return string if hosts.empty?

      max = hosts.map{ |h| h.ip_address.size }.max
      hosts.each do |host|
        padding = ' ' * (max - host.ip_address.size + 4)
        string << ' ' * indent
        string << "#{host.ip_address}#{padding}#{host.hostname}\n"
      end

      string
    end

    def to_s
      <<-GROUP.gsub /^\s+/, ""
        ## ROAST [#{name}]
        #{entries_to_s}
        ## TSAOR
      GROUP
    end
  end
end