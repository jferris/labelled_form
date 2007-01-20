module ActiveRecord #:nodoc:
	module RequiredAttributes #:nodoc:
	
		def self.included (base)
			base.class_eval do
				include InstanceMethods
				
				class_inheritable_accessor :required_attributes_by_on
			
				class << self
					include ClassMethods
					alias_method_chain :validates_presence_of, :require_attributes
				end
			
			end
		end

		module ClassMethods #:nodoc:

			def validates_presence_of_with_require_attributes (*attr_names)
				validates_presence_of_without_require_attributes(*attr_names.dup)
				require_attributes(*attr_names)
			end
			
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
		
		# Keeps track of attributes that are required (as specified by
		# validates_presence_of), and provides an interface for determining
		# whether an attribute is required or not.
		module InstanceMethods

			# Returns true if the specified <tt>attr_named</tt> is required for
			# this object, and false otherwise.
			def attribute_required? (attr_name)
				attribute_required_on?(attr_name, :save) || attribute_required_on?(attr_name, new_record? ? :create : :update)
			end
			
			def attribute_required_on? (attr_name, on) #:nodoc:
				required_attributes_by_on[on] && required_attributes_by_on[on].include?(attr_name)
			end
	
			# Returns an array of attributes that are required for this object.
			def required_attributes
				(required_attributes_on(:save) + required_attributes_on(new_record? ? :create : :update)).uniq
			end
			
			def required_attributes_on (on) #:nodoc:
				required_attributes_by_on[on] || [] 
			end

		end
		
	end
end