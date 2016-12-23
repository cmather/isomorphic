require "parser"
require "ast"
require "set"

module Isomorphic
  module AST
    # Processes a Ruby AST tree to remove symbols not intended for a particular
    # build target.
    #
    # T(n) = O(n) where n is the number of ast nodes. The processing is done in
    # three passes. The first pass grabs the annotations that specify specific
    # methods like server(:some_method). The next pass classifies symbols by the
    # region they're in. The last pass removes nodes that shouldn't be in the
    # final tree for this build target.
    #
    # S(n) = O(x) where x is the number of node identifier symbols we're
    # tracking. All symbols are mapped to their intended build target like this:
    # { "#{node identifier}:#{node index}" => :{browser, server} }. The idx is because methods
    # can be named the same across different build targets. So this
    # distinguishes them by their index in the children array of sibling ast
    # nodes.
    class Processor < Parser::AST::Processor
      TARGETS = %i{server browser anywhere}

      def initialize(build_target)
        # the build target we're compiling for (e.g. browser)
        @build_target = build_target

        # O(1) lookup of possible build targets
        @targets = Hash[TARGETS.map { |target| [target, true] }]
      end

      # Look for annotations in begin blocks which could be top level.
      def on_begin(node)
        filtered_children = filter(node.children)
        node.updated(nil, process_all(filtered_children))
      end

      # Returns an array of nodes filtered by nodes that should belong in this
      # build target. For example, if we're building for "browser" this will
      # remove all nodes marked for "server".
      #
      # T(n) = O(n) where n is nodes.size.
      # S(n) = O(n) hash table mapping node id to build target
      def filter(nodes)
        ids_to_target = find_identifiers(nodes)

        [].tap do |filtered|
          nodes.each_with_index do |node, idx|
            case node.type
            when :send
              # filter out all browser(:method_name) type annotations from the
              # target code.
              filtered << node unless @targets.include?(identifier_for(node))
            when :class, :def, :defs, :casgn, :gvasgn
              # filter out nodes not intended for this build target.

              id = identifier_for(node)
              key = key_for(id, idx)
              target = ids_to_target[id] || ids_to_target[key]

              if target == :anywhere || target == @build_target
                filtered << node
              end
            else
              filtered << node
            end
          end
        end
      end

      # Returns a hash table mapping AST nodes to their build targets.
      def find_identifiers(nodes)
        current_target = :anywhere

        {}.tap do |result|
          # first pass check for annotations with specific arguments like
          # `server(:method_one, :method_two)`. These will take precedence over
          # more general region based annotations so we'll put these methods in
          # the hash table first. The first one in the hash table wins.
          nodes.each do |node|
            if node.type == :send
              receiver_node, target, *arg_nodes = *node
              # see if the target is one of our known targets (e.g. anywhere, server,
              # browser) or if it's some other kernel method perhaps.
              if @targets.include?(target)
                if arg_nodes.size > 0
                  # if there are arguments then add those specific ids to the the hash
                  # for the given target.
                  get_arg_values(arg_nodes).each { |id| result[id] = target }
                end
              end
            end
          end

          # on the second pass group by region. and when adding a node use the
          # identifier and the index of the node so that we can distinguish two
          # methods with the same name intended for different build targets.
          nodes.each_with_index do |node, idx|
            case node.type
            when :send
              receiver_node, target, *arg_nodes = *node
              current_target = target if arg_nodes.size == 0
            when :class, :def, :defs, :casgn, :gvasgn
              key = key_for(identifier_for(node), idx)
              result[key] = current_target
            end
          end
        end
      end

      # Returns an array of argument values given an array of argument ast
      # nodes.
      def get_arg_values(arg_nodes)
        arg_nodes.map { |arg_node| arg_node.to_a.first }
      end

      # Given an identifier name and an index in an array of other nodes returns a
      # hash key for this node. This is so two nodes can have the same identifier
      # but be defined for different locations. Like if you had a method called
      # `run` that is defined for the browser and for the server.
      def key_for(identifier, index)
        "#{identifier.to_s}:#{index}"
      end

      # Returns an identifier symbol for the given AST node, for the nodes we're
      # interested in. This is a convenience method so that we don't have to
      # destructure the nodes all over the place just to get their identifiers.
      # There might be a better way to do this?
      def identifier_for(node)
        case node.type
        when :class
          const_node = node.to_a.first
          # [namespace, id]
          return const_node.to_a[1]
        when :def
          # [id, args, children]
          return node.to_a[0]
        when :defs
          # [receiver, id, args, body]
          return node.to_a[1]
        when :send
          # [receiver, id, args]
          return node.to_a[1]
        when :casgn
          return node.to_a[1]
        when :gvasgn
          return node.to_a[0]
        else
          raise "don't know how to get identifier_for(#{node})"
        end
      end
    end
  end
end
