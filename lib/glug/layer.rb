# frozen_string_literal: true

module Glug # :nodoc:
  # -----	Layer
  #       a layer in a GL style
  #       this is where most of the hard work happens, including 'method_missing' and 'on' calls to provide the grammar
  class Layer
    # Upstream spec name => glug method name, for expressions we can't use verbatim
    EXPRESSION_METHODS = Condition::SUBSTITUTIONS.invert.freeze

    # Upstream expressions written as Ruby operators on a Condition, e.g. (height + 1)
    OPERATOR_EXPRESSIONS = %w[== != < > <= >= + * %].freeze

    # Expressions supported by Mapbox GL but not MapLibre
    MAPBOX_EXPRESSIONS = %i[distance_from_center pitch].freeze

    def self.property_method(name)
      name.tr('-', '_').to_sym
    end

    def self.expression_method(name)
      EXPRESSION_METHODS.fetch(name) { property_method(name) }
    end

    # GL properties (as distinct from OSM keys), from the MapLibre style spec
    LAYOUT    = StyleSpec::LAYOUT.values.flatten.uniq.map { |name| property_method(name) }.freeze
    PAINT     = StyleSpec::PAINT.values.flatten.uniq.map { |name| property_method(name) }.freeze
    TOP_LEVEL = %i[metadata zoom interactive].freeze
    HIDDEN    = %i[source source_layer id type filter layout paint].freeze	# top level, not settable by commands
    EXPRESSIONS = ((StyleSpec::EXPRESSIONS - OPERATOR_EXPRESSIONS).map { |name| expression_method(name) } +
                   MAPBOX_EXPRESSIONS).freeze

    # Shared properties that can be recalled by using a 'ref'
    REF_PROPERTIES = %w[type source source-layer minzoom maxzoom filter layout].freeze

    # key-value pairs for layout, paint, and top level
    # filter condition
    # parent stylesheet object
    attr_accessor :kv, :condition, :stylesheet

    def initialize(stylesheet, args = {})
      @stylesheet = stylesheet
      @condition = args[:condition]
      @kv = args[:kv] || {}
      @kv[:id] = args[:id]
      @kv[:zoom] = args[:zoom] if args[:zoom]

      @type = nil	# auto-detected layer type
      @write = true	# write this layer out, or has it been suppressed?
      @cascade_cond = nil	# are we currently evaluating a cascade directive?
      @cascades = args[:cascades] || []	# cascade list to apply to all subsequent layers
      @uncascaded = nil	# condition to add to non-cascaded layers

      @kv[:source] ||= stylesheet.sources.find { |_k, v| v[:default] }[0]
      @kv[:source_layer] ||= args[:id] if stylesheet.sources[@kv[:source]][:type] == 'vector'
      @child_num = 0	# incremented sublayer suffix
      @dsl = LayerDSL.new(self)
    end

    def dsl_eval(&block)
      # Copy ivars from stylesheet DSL to layer DSL (before eval)
      style_dsl = @stylesheet.dsl
      style_dsl.instance_variables.each do |ivar|
        next if ivar.to_s.start_with?('@__') # skip internal ivars

        @dsl.instance_variable_set(ivar, style_dsl.instance_variable_get(ivar))
      end

      # Run the layer evaluation
      @dsl.instance_eval(&block)

      # Copy ivars back to stylesheet DSL (after eval)
      @dsl.instance_variables.each do |ivar|
        next if ivar.to_s.start_with?('@__') # skip internal ivars

        style_dsl.instance_variable_set(ivar, @dsl.instance_variable_get(ivar))
      end
    end

    # Handle all missing 'method' calls
    # If we can match it to a GL property, it's an assignment:
    # otherwise it's an OSM key
    def add_property(method_sym, *arguments)
      if EXPRESSIONS.include?(method_sym)
        Condition.new.from_list(method_sym, arguments)
      elsif LAYOUT.include?(method_sym) || PAINT.include?(method_sym) || TOP_LEVEL.include?(method_sym)
        v = arguments.length == 1 ? arguments[0] : arguments
        v = v.call(@kv[method_sym]) if v.is_a?(Proc)
        if @cascade_cond.nil?
          @kv[method_sym] = v
        else
          _add_cascade_condition(method_sym, v)
        end
      else
        Condition.new.from_list('get', [method_sym])
      end
    end

    # Convenience so we can write literal(1,2,3) rather than literal([1,2,3])
    def literal(*args)
      if args.length == 1 && args[0].is_a?(Hash)
        # Hashes - literal(frog: 1, bill: 2)
        Condition.new.from_list(:literal, [args[0]])
      else
        # Arrays - literal(1,2,3)
        Condition.new.from_list(:literal, [args])
      end
    end

    # Return a current value from @kv
    # This allows us to do: line_width current_value(:line_width)/2.0
    def current_value(key)
      @kv[key]
    end

    # Add a sublayer with an additional filter
    def on(*args, &block)
      @child_num += 1
      r = Layer.new(@stylesheet,
                    id: "#{@kv[:id]}__#{@child_num}".to_sym,
                    kv: @kv.dup, cascades: @cascades.dup)

      # Set zoom level
      r.kv[:zoom] = args.shift if args[0].is_a?(Range) || args[0].is_a?(Integer)

      # Set condition
      sub_cond = nil
      if args.empty?
        sub_cond = @condition	# just inherit parent layer's condition
      else
        sub_cond = args.length == 1 ? args[0] : Condition.new.from_list(:any, args)
        sub_cond = nilsafe_merge(sub_cond, @condition)
      end
      r._set_filter(nilsafe_merge(sub_cond, @uncascaded))
      r.dsl_eval(&block)
      @stylesheet._add_layer(r)

      # Create cascaded layers
      child_chr = 'a'
      @cascades.each do |c|
        c_cond, c_kv = c
        l = Layer.new(@stylesheet, id: "#{r.kv[:id]}__#{child_chr}", kv: r.kv.dup)
        l._set_filter(nilsafe_merge(sub_cond, c_cond))
        l.kv.merge!(c_kv)
        @stylesheet._add_layer(l)
        child_chr.next!
      end
    end

    # Nil-safe merge
    def nilsafe_merge(a, b) # rubocop:disable Naming/MethodParameterName
      a.nil? ? b : (a & b)
    end

    # Add a cascading condition
    def cascade(*args, &block)
      cond = args.length == 1 ? args[0] : Condition.new.from_list(:any, args)
      @cascade_cond = cond
      dsl_eval(&block)
      @cascade_cond = nil
    end

    def _add_cascade_condition(property, value)
      if @cascades.length.positive? && @cascades[-1][0].to_s == @cascade_cond.to_s
        @cascades[-1][1][property] = value
      else
        @cascades << [@cascade_cond, { property => value }]
      end
    end

    def uncascaded(*args)
      cond = case args.length
             when 0 then nil
             when 1 then args[0]
             else; Condition.new.from_list(:any, args)
             end
      @uncascaded = cond
    end

    # Setters for @condition (making sure we copy when inheriting)
    def filter(*args)
      _set_filter(args.length == 1 ? args[0] : Condition.new.from_list(:any, args))
    end

    def _set_filter(condition)
      @condition = condition&.dup
    end

    # Set layer name
    def id(name)
      @kv[:id] = name
    end

    # Suppress output of this layer
    def suppress
      @write = false
    end

    def write?
      @write
    end

    # Square-bracket filters (any[...], all[...])
    def any
      Subscriptable.new(:any)
    end

    def all
      Subscriptable.new(:all)
    end

    # Deduce 'type' attribute from style attributes
    def set_type_from(property)
      return unless property.include?('-')

      new_type = (/^fill-extrusion/.match?(property) ? 'fill-extrusion' : 
                  /^color-relief/.match?(property) ? 'color-relief' : 
                  property.split('-')[0]).to_sym
      new_type = :symbol if %i[icon text].include?(new_type)
      if @type && @type != new_type
        raise "Attribute #{property} conflicts with deduced type #{@type} in layer #{@kv[:id]}"
      end

      @type = new_type
    end

    # Create a GL-format hash from a layer definition
    def to_hash
      hash = { layout: {}, paint: {} }

      # Assign key/values to correct place
      @kv.each do |k, v|
        s = k.to_s.tr('_', '-')
        v = '#%06x' % v if s.include?('-color') && v.is_a?(Integer)
        v = v.encode if v.respond_to?(:encode)

        if LAYOUT.include?(k)
          hash[:layout][s] = v
          set_type_from s
        elsif PAINT.include?(k)
          hash[:paint][s] = v
          set_type_from s
        elsif TOP_LEVEL.include?(k) || HIDDEN.include?(k)
          hash[s] = v
        else
          raise "#{s} isn't a recognised layer attribute"
        end
      end

      hash['type'] = @type
      hash['filter'] = @condition.encode if @condition

      # Convert zoom level
      if (v = hash['zoom'])
        if v.is_a?(Range)
          hash['minzoom'] = v.first unless v.begin.nil?
          hash['maxzoom'] = v.last unless v.end.nil?
        else
          hash['minzoom'] = hash['maxzoom'] = v
        end
        hash.delete('zoom')
      end

      if hash[:layout].empty? && hash[:paint].empty?
        nil
      else
        hash.delete(:layout) if hash[:layout].empty?
        hash.delete(:paint) if hash[:paint].empty?
        hash
      end
    end
  end
end
