require 'fileutils'

module ExtJS::XTheme::Command
	class Base
		#include Heroku::Helpers

		attr_accessor :args
		attr_reader :config
		
		def initialize(args, config)
			@args = args
			@config = config
		end
    
		def display(msg, newline=true)
			if newline
				puts(msg)
			else
				print(msg)
				STDOUT.flush
			end
		end

		def error(msg)
			ExtJS::XTheme::Command.error(msg)
		end

		def ask
			gets.strip
		end

		def shell(cmd)
			FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
		end

		def heroku
			#@heroku ||= Heroku::Command.run_internal('auth:client', args)
		end

		def extract_app(force=true)
			app = extract_option('--app')
			unless app
				app = extract_app_in_dir(Dir.pwd) ||
				raise(CommandFailed, "No app specified.\nRun this command from app folder or set it adding --app <app name>") if force
				@autodetected_app = true
			end
			app
		end

		def extract_app_in_dir(dir)
			
		end

		def extract_option(options, default=true)
			values = options.is_a?(Array) ? options : [options]
			return unless opt_index = args.select { |a| values.include? a }.first
			opt_position = args.index(opt_index) + 1
			if args.size > opt_position && opt_value = args[opt_position]
				if opt_value.include?('--')
					opt_value = nil
				else
					args.delete_at(opt_position)
				end
			end
			opt_value ||= default
			args.delete(opt_index)
			block_given? ? yield(opt_value) : opt_value
		end

		def escape(value)
			heroku.escape(value)
		end  
	end
end
