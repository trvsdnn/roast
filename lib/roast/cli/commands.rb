module Roast
  class CLI
    module Commands
      ALIASES = {
        'a'   => 'add',
        'e'   => 'enable',
        'eg'  => 'enable-group',
        'd'   => 'disable',
        'dg'  => 'disable-group',
        'l'   => 'list'
      }

      def dispatch
        command    = ARGV.shift
        command    = ALIASES[command] || command

        hosts_file = HostsFile.new

        if respond_to? command
          send(command.tr('-', '_'), *ARGV)
        else
          puts "`#{command}' is an unknown command, use --help to see available commands"
          exit
        end
      end

      def add(*args)
        if args.length < 2
          raise ArgumentError, "You must provide an ip address and a hostname to point it too"
        elsif args.length == 3
          group = args.shift
        else
          group = 'base'
        end

        args.reverse! if args.last =~ Host::IP_PATTERN
        ip_address, hostname = args

        if HostsFile.add(group, ip_address, hostname)
          puts "added host entry for `#{ip_address}  \033[4m#{hostname}\033[0m'"
        end
      end

      def enable(*args)
        entry   = args.first
        results = HostsFile.enable(entry)
        if results.empty?
          puts "no entries found matching `#{entry}'"
        else
          puts "enabled entry#{results.length > 1 ? 's' : ''} matching `#{entry}'"
        end
      end

      def disable(*args)
        entry   = args.first
        results = HostsFile.disable(entry)
        if results.empty?
          puts "no entries found matching `#{entry}'"
        else
          puts "disabled entry#{results.length > 1 ? 's' : ''} matching `#{entry}'"
        end
      end

      def enable_group(*args)
        group = args.first

        if HostsFile.enable_group(group)
          puts "enabled group `#{group}'"
        else
          puts "Unable to enable the group `#{group}', it doesn't exist yet."
        end
      end

      def disable_group(*args)
        group = args.first

        if HostsFile.delete_group(group)
          puts "disabled group `#{group}'"
        else
          puts "Unable to disable the group `#{group}', it doesn't exist yet."
        end
      end

      def list(*args)
        # TODO: a bit awkward, use a class var?
        path, groups = HostsFile.list

        if groups.empty?
          puts "there are no roast entries in `#{path}'\n"
        else
          entries = ''
          groups.values.each { |group| entries << group.to_cli }
          puts entries.chomp
        end
      end

    end
  end
end
