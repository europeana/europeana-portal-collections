module DynamicAccessorMethods
  extend ActiveSupport::Concern

  class_methods do
    # Dynamic accessor methods for serialized Hash(like) attributes
    def has_dynamic_accessor_methods(methods = {})
      methods.each_pair do |attr, attr_meths|
        attr_meths.each do |meth|
          define_method("#{attr}_#{meth}") do
            self.send(attr.to_sym)[meth.to_sym]
          end
          define_method("#{attr}_#{meth}=") do |value|
            self.send(attr.to_sym)[meth.to_sym] = value
          end
        end
      end
    end
  end
end
