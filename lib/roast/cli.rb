module Roast
  class CLI
    include Roast::CLI::Commands

    BANNER = <<-BANNER
    Usage: roast [GROUP] IP HOSTNAME

    Description:

    Examples:

      > roast testing 127.0.0.1 exampleapp.dev

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
