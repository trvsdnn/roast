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
        command    = (ALIASES[command] || command).tr('-', '_')

        if respond_to? command
          @hosts_file = HostsFile.new.read
          send(command, *ARGV)
        else
          puts "`#{command}' is an unknown command, use --help to see available commands"
          exit
        end
      rescue ArgumentError => e
        puts e.message
        exit 1
      end

      def add(*args)
        if args.length < 2
          raise ArgumentError, "You must provide an ip address and a hostname to point it to: `roast add 127.0.0.1 something.dev'"
        elsif args.length == 3
          group = args.shift
        else
          group = 'base'
        end

        ip_address, hostname = args

        if @hosts_file.add(group, ip_address, hostname)
          @hosts_file.write
          puts "added host entry for `#{ip_address}  \033[4m#{hostname}\033[0m'"
        end
      end

      def enable(*args)
        entry   = args.first
        results = @hosts_file.enable(entry)
        if results.empty?
          puts "no entries found matching `#{entry}'"
        else
          @hosts_file.write
          puts "enabled entry#{results.length > 1 ? 's' : ''} matching `#{entry}'"
        end
      end

      def disable(*args)
        entry   = args.first
        results = @hosts_file.disable(entry)
        if results.empty?
          puts "no entries found matching `#{entry}'"
        else
          @hosts_file.write
          puts "disabled entry#{results.length > 1 ? 's' : ''} matching `#{entry}'"
        end
      end

      def delete(*args)
        entry   = args.first
        results = @hosts_file.delete(entry)
        if results.empty?
          puts "no entries found matching `#{entry}'"
        else
          @hosts_file.write
          puts "deleted entry#{results.length > 1 ? 's' : ''} matching `#{entry}'"
        end
      end

      def enable_group(*args)
        group = args.first

        if @hosts_file.enable_group(group)
          @hosts_file.write
          puts "enabled group `#{group}'"
        else
          puts "Unable to enable the group `#{group}', it doesn't exist yet."
        end
      end

      def disable_group(*args)
        group = args.first

        if @hosts_file.disable_group(group)
          @hosts_file.write
          puts "disabled group `#{group}'"
        else
          puts "Unable to disable the group `#{group}', it doesn't exist yet."
        end
      end

      def delete_group(*args)
        group = args.first

        if @hosts_file.delete_group(group)
          @hosts_file.write
          puts "deleted group `#{group}'"
        else
          puts "Unable to delete the group `#{group}', it doesn't exist yet."
        end
      end

      def list(*args)
        # TODO: a bit awkward, use a class var?
        path, groups = @hosts_file.list

        if groups.empty?
          puts "there are no roast entries in `#{path}'\n"
        else
          entries = ''
          groups.each { |group| entries << group.to_cli }
          puts entries.chomp
        end
      end

    end
  end
end
