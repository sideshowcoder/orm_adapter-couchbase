require 'active_support/inflector'

module Couchbase
  class Model

    # define a has_many relationship, this is comprise of a view and and array
    # with referential keys
    def self.has_many(name, options = {})
      assoc_name = name.to_s.singularize
      ref = "#{assoc_name}_ids"
      attribute(ref, :default => [])
      assoc = (options[:wrapper_class] || assoc_name).to_s.camelize.constantize

      define_method("#{name}=") do |others|
        raise TypeError unless others.all? { |o| o.is_a? assoc }
        self.send("#{ref}=", others.map(&:id))
      end
      define_method(name) do
        assoc.find(self.send(ref))
      end
    end

  end
end
