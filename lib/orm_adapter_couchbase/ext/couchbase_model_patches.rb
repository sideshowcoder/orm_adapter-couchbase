module Couchbase
  class Model

    # Current master (072262e) version of belongs to
    #
    # support passing a class which is not supported in the current 0.5.3 but
    # already in master
    #
    # - added suppport for assigning to belongs_to
    #
    def self.belongs_to(name, options = {})
      ref = "#{name}_id"
      attribute(ref)
      assoc = (options[:class_name] || name).to_s.camelize.constantize
      define_method(name) do
        assoc.find(self.send(ref))
      end
      define_method("#{name}=") do |other|
        raise TypeError unless other.is_a? assoc
        self.send("#{ref}=", other.id)
      end
    end


  end
end
