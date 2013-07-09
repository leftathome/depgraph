require 'node'

module DepGraph
  module NodeFinders
    class CookbookNodeFinder
      def initialize
        @spec_directories = [File::expand_path(".")]
      end

      def location=(loc)
        @spec_directories = loc
      end

      def get_nodes

        fail 'The cookbook directory was not set' unless @spec_directories and @spec_directories.size > 0

        nodes = {}
        @spec_directories.each do |spec_directory|
	  #puts "sd: #{spec_directory}"
          Dir["#{spec_directory}/**/metadata.rb"].each do |metadata_file_name|
	    #puts "Filename: #{metadata_file_name}"
            add_nodes_from_metadata(nodes, metadata_file_name)
          end
        end

        return nodes.values.sort
      end

      private
      def add_nodes_from_metadata(nodes, metadata_file_name)
        cb_dependencies = get_cb_dependencies(metadata_file_name)
        cb_name = get_cb_name(metadata_file_name)

	#puts "cbd: #{cb_dependencies} and cbn: #{cb_name}"

        nodes[cb_name] ||= Node.new(cb_name)
        cb_dependencies.each do |cb_dependency|
          nodes[cb_dependency] ||= Node.new(cb_dependency)
          nodes[cb_name].depends_on(nodes[cb_dependency])
        end
      end

      def get_cb_dependencies(cb_file_name)
        cb_dependencies = []
        content = File.read(cb_file_name)
        content.scan(/^depends\s+['"]([\w,\d,_,-]+)['"]/) do |matches|
          matches.each do |match|
            cb_dependencies << match
          end
        end

        return cb_dependencies
      end

      def get_cb_name(cb_file_name)
        cb_name = nil
        content = File.read(cb_file_name)
        content.scan(/^name\s+['"]([\w,\d,_,-]+)['"]/) do |matches|
          matches.each do |match|
            cb_name = match
          end
	end
	if cb_name.nil?
	  cb_name = File.dirname(cb_file_name).split(File::SEPARATOR)[-1]
        end
	return cb_name
      end
    end
  end
end
