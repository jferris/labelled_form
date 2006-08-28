module ActionView #:nodoc:
	module Helpers #:nodoc:

		# Stores a list of class names, which can be iterated over as an array,
		# or views as a string by calling <tt>to_str</tt>. When behaving as a string,
		# a space-seperated list of CSS class names will be returned.
		class CssClassList
		
			include Enumerable
			
			# <tt>class_names</tt> can be any of the following objects:
			# * responds to <tt>to_str</tt> and returns a space-separated
			#   list of class names
			# * responds to <tt>to_ary</tt> and returns an array of class names
			# * <tt>nil</tt> (initializes with no class_names)
			def initialize (class_names = nil)
				@class_names = CssClassList.parse_class_names(class_names)
			end
			
			# Adds <tt>class_name</tt> to the list of class names.
			def << (class_name)
				@class_names << class_name if CssClassList.class_name_valid?(class_name)
			end
			
			# Appends a list of class names.
			def + (class_names)
				@class_names += CssClassList.parse_class_names(class_names)
			end
			
			def each (&block) # :nodoc:
				@class_names.each(&block)
			end
			
			def [] (index) #:nodoc:
				@class_names[index]
			end
			
			def delete (object) #:nodoc:
				@class_names.delete(object)
			end
			
			def delete_at (index) #:nodoc:
				@class_names.delete_at(index)
			end
			
			# Returns the list of class names as an array.
			def to_a
				@class_names.dup
			end
			
			# Returns the list of class names as a space-separated string,
			# usable in a CSS class attribute.
			def to_s
				@class_names.join(' ')
			end
			
			alias_method :to_str, :to_s
			
			# Parses a string for CSS class names, and returns them as an array.
			def self.parse_class_names(class_names)
				if class_names.respond_to?(:to_str)
					class_names = class_names.to_str.split(' ') 
				elsif class_names.respond_to?(:to_ary)
					class_names = class_names.to_ary
				elsif class_names.nil?
					class_names = []
				else
					raise ArgumentError, "Invalid class_names argument: #{class_names.to_s}"
				end
				
				class_names.reject {|class_name| !class_name_valid?(class_name) }
			end
			
			# Returns true if <tt>class_name</tt> contains a valid CSS class name.
			def self.class_name_valid? (class_name)
				class_name =~ /^[a-zA-Z]\w*$/
			end
			
		end

	end
end