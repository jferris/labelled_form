module ActionView #:nodoc:
	module Helpers #:nodoc:
		
		# Pass this class to <tt>form_for</tt> or <tt>fields_for</tt>, or simply
		# call <tt>labelled_form_for</tt> instead.
		# 
		# Wraps each of the built-in Rails helper methods with a call to
		# <tt>labelled_field</tt>, which adds a label and wraps the field
		# in a div tag.
		# 
		# All <tt>labelled_*</tt> methods from <tt>FormBuilder</tt> are aliased
		# without the <tt>labelled_</tt> prefix, so you can call, for example,
		# <tt>LabelledFormBuilder#check_box</tt> instead of
		# <tt>FormBuilder#labelled_check_box</tt>.
		class LabelledFormBuilder < FormBuilder
			
			# wrap standard helpers
			# (arguments are method and options)
			(field_helpers - %w(check_box radio_button) +
			%w(date_select datetime_select)
			).each do |selector|
				if %w(date_select datetime_select).include?(selector)
					src = <<-end_src
		        		def #{selector}(method, options = {})
							without_error_wrapping { wrap_input(method, options.delete(:label), options.delete(:field_options), @template.send(#{selector.inspect}, @object_name, method, options.merge(:object => @object)), true) }
						end
			        end_src
				else
					if %w(text_field password_field).include?(selector)
						css_class_setter = <<-end_src
							options = options.symbolize_keys
							options[:class] = options[:class] ? "\#{options[:class]} text" : 'text'
						end_src
					else
						css_class_setter = ''
					end
					src = <<-end_src
		        		def #{selector}(method, options = {})
		        			#{css_class_setter}
		        			without_error_wrapping { wrap_input(method, options.delete(:label), options.delete(:field_options), @template.send(#{selector.inspect}, @object_name, method, options.merge(:object => @object)), false) }
						end
			        end_src
				end
				class_eval src, __FILE__, __LINE__
			end
			
			private
			
			def wrap_input (method, caption, field_options, content, is_multi) #:nodoc:
				field_options ||= {}
				field_options.stringify_keys!
				field_options['label'] ||= caption
				is_multi ?
				labelled_field([method], caption, content, field_options) :
				labelled_field_for(method, content, field_options)
			end
			
			def without_error_wrapping
				old_error_wrapping_enabled = InstanceTag.error_wrapping_enabled
				InstanceTag.error_wrapping_enabled = false
				result = yield
				InstanceTag.error_wrapping_enabled = old_error_wrapping_enabled
				result
			end
			
			alias_method :field_for, :labelled_field_for
			alias_method :field, :labelled_field
			alias_method :check_box, :labelled_check_box
			
		end

  end

end
