module ActionView #:nodoc:
	module Helpers #:nodoc:
		module LabelHelper
			
			# Returns a label tag designed to be used with a field for the specified
			# attribute (identified by <tt>method</tt>). A caption for the label is
			# guessed using the attribute name, but you can specify one in the third
			# <tt>caption</tt> parameter. Additional options can be passed as a hash
			# with <tt>options</tt>.
			def label (object_name, method, caption = nil, options = {})
				InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag(caption, options)
			end
			
			# Creates a label tag.
			# 
			# Parameters:
			# <tt>element_id</tt>:: the <tt>for</tt> attribute of the label tag.
			# <tt>caption</tt>::
			#   the contents of the label tag. If <tt>nil</tt>, the contents
			#   will be guessed from <tt>element_id</tt>.
			# <tt>options</tt>:: Any additional HTML attributes.
			def label_tag (element_id, caption = nil, options = {})
				caption = caption.respond_to?(:to_str) ? caption.to_s : (element_id.to_s.humanize + ":")
				options["for"] ||= element_id.to_s unless element_id.nil?
				content_tag("label", caption, options)
			end
		end
		
		class InstanceTag #:nodoc:
			
			def to_label_tag (caption = nil, options = {})
				options = options.stringify_keys
				
				caption = @method_name.humanize + ":" unless caption.is_a? String
				
				options["for"] = @object_name + "_" + @method_name
				
				content_tag("label", caption, options)
			end
			
		end
		
		# Extends the build-in Rails <tt>FormBuilder</tt>
		class FormBuilder
			
			# Creates a label tag.
			# 
			# See LabelHelper#label
			def label (method, caption = nil, options = {})
				@template.label(@object_name, method, caption, options.merge(:object => @object))
			end
			
		end
		
	end
	
end
