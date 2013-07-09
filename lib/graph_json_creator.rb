require 'rubygems'
require 'json'

module DepGraph
  class GraphJsonCreator < DepGraph::GraphImageCreator
    attr_writer :trans
    
    def create_image(image_file_name)
      begin
        return false if @nodes.size == 0 or @edges.size == 0
        
        set_default_output_generation_unless_is_set
        
        return @output_generation.call(@nodes, @edges, image_file_name)
        
      rescue => e
        puts e.message
        puts e.backtrace
        return false
      end
    end
    
    private
    def quotify(a_string)
      '"' + a_string + '"'
    end
    
    def set_default_output_generation_unless_is_set
      unless @output_generation 
        @output_generation = lambda {|nodes, edges, image_file_name|
          #TODO: Could we catch Graphviz errors that the wrapper couldn't catch?        

          g = {}
          load_nodes(g, nodes)        
          load_edges(g, edges)

          create_output(g, image_file_name)          
          
          return true
        }
      end
    end
    
    def load_nodes(g, nodes)
      nodes.each do |node|
        puts "node: #{quotify(node)}, dependencies: #{node.dependencies}"
        g[quotify(node)] = node.dependencies
      end
    end
    
    def load_edges(g, edges)
      edges.each do |from, to|
        puts "from: #{from} , to: #{to}"
        g[quotify(from)] << quotify(to) unless g[quotify(from)].include?(quotify(to))
      end
    end
    
    def create_output(g, image_file_name)
        puts g.to_json
        File::open(image_file_name) { |f| f.write(g.to_json) }  
    end
    
    def get_output_type(image_file_name)
      # there is no png, there is only json
      return 'json'
    end
  end
end
