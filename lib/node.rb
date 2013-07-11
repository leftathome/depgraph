module DepGraph

  #A node knows its dependables
  class Node
    include Comparable
    attr_reader :name
    attr_accessor :version

    def initialize(node_uri, version = nil)
      fail 'Empty uris are not allowed' if node_uri.empty?
      @name = node_uri
      @version = version
      @dependencies = []
    end
      
    def to_str
      if @version
        "#{@name} #{@version}"
      else
        @name
      end
    end
    
    def <=> other_node
      to_str <=> other_node.to_str
    end
    
    def eql? other_node
      (self <=> other_node) == 0
    end
    
    def hash
      @name.hash
    end
    
    def depends_on node
      node = Node.new(node) unless node.respond_to? :name
      
      @dependencies << node
    end
    
    def depends_on? node
      @dependencies.include? node
    end

    def dependencies
      @dependencies
    end
  end
end