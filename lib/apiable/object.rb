module Apiable
  #
  # Apiable::Object
  # Module responsible for extending regular ruby objects with incoming and
  # outgoing methods for easy backend integration.
  #
  module Object

    #
    # #external
    # Istance method responsible to return an hash of class determined
    # attributes. Attributes should be determined using outgoing class
    # method.
    # - :format determines which attributes will be included in the response
    # if no format provided, all the attributes (that don't have a format
    # assign wil be on the response)
    #
    def external(format = :any)
      Hash[
        self.class.class_variable_get(:@@external).collect do |details|
          add_external_attribute?(details, format) ?
            [ details[:external_key],
              #
              # if the handler is a proc, instead of sending the value informed
              # to send(), tries to execute it at runtime, for now only proc is
              # supported, but this option can be extended to blocks and other
              # ruby suggary.
              # - for proc execution, the :as option is mandatory. or the
              #   execution will not have a valid symbol to attach
              #
              details[:handler].is_a?(Proc) ?
                details[:handler].call(self) :
                send(details[:handler])
            ] :
            nil
        end.compact
      ]
    end

    #
    # #from_outside
    # Instance method responsible for updating object attributes
    # with white-listed attributes from external source
    #
    def from_outside(params)
      #
      # from class white listed attributes, build a new hash containing
      # the local attribute name and the value that should be assigned
      # to it
      #
      attrs = (
        #
        # only attributes that were informed should be parsed again
        # this way, not informed attributes (coming from params) but
        # still declared on incoming are not called.
        #
        self.class.class_variable_get(:@@internal).select { |k|
          params.keys.collect(&:to_sym).include?(k[:external_key])
        }

      ).collect do |details|
        { handler: details[:handler],
          value: params.fetch(
            details[:external_key],
            nil)}
      end

      #
      # from the hash previously created, one by one assign
      # to the object using the setter method
      #
      attrs.each do |attr|
        self.send(:"#{attr[:handler]}=", attr[:value])
      end

      return self
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    #
    # Apiable::Object::ClassMethods
    # Module responsible to add class methods and mechanics to
    # objects where object module is included.
    #
    module ClassMethods

      #
      # .from_outside
      # Class method responsible to generate a new object from
      # hash, but only with white-listed attributes.
      # The white list is determined using incoming class method.
      #
      def from_outside(params)
        #
        # from class variable named internal, comes the list of allowed
        # methods to be used on this new object generated, from that list
        # this snippet should generate a new hash with handler and values
        # to be assigned to the object.
        # it's imperative to allow nil or skip all the white-listed
        # attributes.
        #
        attrs = class_variable_get(:@@internal).collect do |details|
          { handler: details[:handler],
            value: params.fetch(
              details[:external_key],
              nil
            )}
        end

        #
        # from the previous parsed hash, a new object should generated
        # using empty initializer and assigning using the handler and the
        # setter method.
        #
        object = self.new
        attrs.each do |attr|
          object.send(:"#{attr[:handler]}=", attr[:value])
        end

        #
        # returning the generated object
        # nothing more than that, magic isn't it?
        #
        object
      end

      #
      # .outgoing
      # Class method responsible add attribute to the hash list that will be
      # returned using #external method.
      # usage:
      #   outgoing :local_name,
      #     as: :external_name,
      #     if: :condition
      #     when: :format OR when: [ :format, :format, :format ]
      #
      # option "as", allow adding a different name to tbe used than the local
      # getter.
      #
      # option "if", allow adding a condition to be checked to add or not this
      # attribute in the list returned, runtime wise.
      #
      # option "when", allow adding attribute to the external response only if
      # that format is defined when called the external method, if no format
      # provided when declaring outgoing or calling external method, any is
      # the default.
      #
      def outgoing(handler, options = {})
        previous = class_variable_defined?(:@@external) ?
          class_variable_get(:@@external) :
          []

        attr = { handler: handler, external_key: handler }

        attr.store(:external_key, options[:as]) if options.has_key?(:as)
        attr.store(:condition, options[:if]) if options.has_key?(:if)
        attr.store(:when, options[:when]) if options.has_key?(:when)

        class_variable_set(:@@external, previous.push(attr))
      end

      #
      # .incoming
      # Class method responsible to add attributes to the white-list that
      # will be used to generate a new object using .from_outside.
      # usage:
      #   incoming :local_name,
      #     as: :external_name
      #
      # options "as", allow the internal attribute to be used with a different
      # external name, this is particularly handy when dealing with camelcase
      # variables from javascript or other sources.
      #
      def incoming(symbol, options = {})
        previous = class_variable_defined?(:@@internal) ?
          class_variable_get(:@@internal) :
          []

        attr = { handler: symbol, external_key: symbol }

        attr.store(:external_key, options[:as]) if options.has_key?(:as)

        class_variable_set(:@@internal, previous.push(attr))
      end
    end

    protected

      def add_external_attribute?(object, format)
        condition_flag = object.has_key?(:condition) ?
          send(object[:condition]) : true

        format_flag = object.has_key?(:when) ?
          match_format?(object[:when], format) : true

        condition_flag && format_flag
      end

      def match_format?(allowed, called)
        return false if called == :any
        allowed = [ allowed ] if not(allowed.respond_to?(:include?))
        allowed.include?(called)
      end
  end
end
