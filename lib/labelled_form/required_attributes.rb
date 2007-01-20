module ActiveRecord #:nodoc:
	class Base #:nodoc:
	
		class_inheritable_accessor :required_attributes_by_on
		
		class << self

			def validates_presence_of_with_require_attributes (*attr_names)
				validates_presence_of_without_require_attributes(*attr_names.dup)
				require_attributes(*attr_names)
			end
			
			alias_method_chain :validates_presence_of, :require_attributes
			
			private
			
			def require_attributes (*attr_names)
				options = { :on => :save }
				options.update(attr_names.pop) if attr_names.last.is_a?(Hash)
				
				self.required_attributes_by_on ||= {}
				self.required_attributes_by_on[options[:on]] ||= []
				self.required_attributes_by_on[options[:on]] += attr_names
				
				self
			end
			
		end
		
		def attribute_required? (attr_name)
			attribute_required_on?(attr_name, :save) || attribute_required_on?(attr_name, new_record? ? :create : :update)
		end
		
		def attribute_required_on? (attr_name, on)
			required_attributes_by_on[on] && required_attributes_by_on[on].include?(attr_name)
		end

		def required_attributes
			(required_attributes_on(:save) + required_attributes_on(new_record? ? :create : :update)).uniq
		end
		
		def required_attributes_on (on)
			required_attributes_by_on[on] || [] 
		end
		
	end
end