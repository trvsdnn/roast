module Roast
  class CLI
    include Roast::CLI::Commands

    BANNER = <<-BANNER
    Usage: roast COMMAND [ARGS]

    Description:
      The roast command manages groups/entries in your /etc/hosts file. It
      has a few different commands available:

        list            list the entries in the hosts file          alias: l
        add             adds a new entry to the hosts file          alias: a
        enable          enables a disabled (commented out) entry    alias: e
        enable-group    enables an entire group                     alias: eg
        disable         disables an entry (comments it out)         alias: d
        disable-group   disables an entire group                    alias: dg
        delete          deletes an entry entirely
        delete-group    deletes an enitre group

    Examples:
      # list all entires
      > roast list

      # add an entry to the base group
      > roast add 10.0.1.1 something.dev

      # add an entry to the "testing" group
      > roast add testing 127.0.0.1 exampleapp.dev

      # disable all entries with the ip "10.0.1.1"
      > roast disable 10.0.1.1
    BANNER

    # Use OptionParser to parse options, then we remove them from ARGV
    def parse_options
      @opts = OptionParser.new do |opts|
        opts.banner = BANNER.gsub(/^ {4}/, '')

        opts.separator ''
        opts.separator 'Options:'

        opts.on('-v', 'Print the version') do
          puts Roast::VERSION
          exit
        end

        opts.on( '-h', '--help', 'Display this help.' ) do
          puts opts
          exit
        end
      end

      @opts.parse!
    end

    def print_usage_and_exit!
      puts @opts
      exit
    end

    # Called from the executable. Parses the command line arguments
    def run
      parse_options
      print_usage_and_exit! if ARGV.empty?
      dispatch
    end
  end
end
