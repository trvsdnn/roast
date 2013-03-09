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

    def entries_to_s
      string = ''
      return string if hosts.empty?

      max = hosts.map{ |h| h.ip.size }.max
      hosts.each do |host|
        padding = ' ' * (max - host.ip.size + 4)
        string << "#{host.ip}#{padding}#{host.host}\n"
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