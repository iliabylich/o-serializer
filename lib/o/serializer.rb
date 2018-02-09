require "o/serializer/version"

module O
  module ArefShortcut
    def [](*args)
      new(*args)
    end
  end

  READ = ->(object, key) {
    object.respond_to?(:read_attribute_for_serialization) ?
      object.read_attribute_for_serialization(key) :
      object.public_send(key)
  }

  class Serializer
    extend ArefShortcut

    def initialize(fields)
      @fields = fields
    end

    def call(object)
      return nil if object.nil?
      @fields
        .map { |key, field| [key, field.call(object)] }
        .to_h
    end
  end

  class Field
    extend ArefShortcut

    def initialize(key)
      @key = key
    end

    def call(object)
      return nil if object.nil?
      READ[object, @key]
    end
  end

  class Many
    extend ArefShortcut

    def initialize(serializer)
      @serializer = serializer
    end

    def call(collection)
      collection.map { |item| @serializer.call(item) }
    end
  end

  class PlainFields
    extend ArefShortcut

    def initialize(*keys)
      @keys = keys
    end

    def to_hash
      @keys
        .map { |key| [key, Field[key]] }
        .to_h
    end
  end

  class From
    extend ArefShortcut

    def initialize(key, serializer)
      @key = key
      @serializer = serializer
    end

    def call(object)
      return nil if object.nil?
      @serializer.call(READ[object, @key])
    end
  end
end
