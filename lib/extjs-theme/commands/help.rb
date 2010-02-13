module ExtJS::Theme::Command
	class Help < Base
		class HelpGroup < Array
			attr_reader :title

			def initialize(title)
				@title = title
			end

			def command(name, description)
				self << [name, description]
			end

			def space
				self << ['', '']
			end
		end

		def self.groups
			@groups ||= []
		end

		def self.group(title, &block)
			groups << begin
				group = HelpGroup.new(title)
				group.instance_eval(&block)
				group
			end
		end

		def self.create_default_groups!
			group('General Commands') do
				command 'help',                         'show this usage'
				#command 'version',                      'show the gem version'
				space
				#command 'list',                         'list your themes'
				command 'create [<name>]',              'create a new theme'
				space
				#command 'config',                       'display the theme\'s config vars (environment)'
				#command 'config:add key=val [...]',     'add one or more config vars'
				#space
				#command 'destroy [<name>]',             'destroy a theme permanently'
			end

			group('Effects') do
				command 'effects:modulate [<theme> <hue> <saturation> <lightness>]', 'Apply hue, saturation, lightness to a themes\'s images.  Specify as Floats, where 1.0 means 100%'
				space
			end
		end

		def index
			display usage
		end

		def version
			#display ExtJS::Theme.version
		end

		def usage
			longest_command_length = self.class.groups.map do |group|
				group.map { |g| g.first.length }
			end.flatten.max

			self.class.groups.inject(StringIO.new) do |output, group|
				output.puts "=== %s" % group.title
				output.puts

				group.each do |command, description|
					if command.empty?
						output.puts
					else
						output.puts "%-*s # %s" % [longest_command_length, command, description]
					end
				end

				output.puts
				output
			end.string
		end
	end
end

ExtJS::Theme::Command::Help.create_default_groups!
