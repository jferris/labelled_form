module ActionView #:nodoc:
	module Helpers #:nodoc:
		
		# Pass this class to <tt>form_for</tt> or <tt>fields_for</tt>, or simply
		# call <tt>labelled_form_for</tt> instead.
		# 
		# Wraps each of the built-in Rails helper methods with a call to
		# <tt>labelled_field_tag</tt>, which adds a label and wraps the field
		# in a div tag.
		# 
		# All <tt>labelled_*</tt> methods from <tt>FormBuilder</tt> are aliased
		# without the <tt>labelled_</tt> prefix, so you can call, for example,
		# <tt>LabelledFormBuilder#check_box</tt> instead of
		# <tt>FormBuilder#labelled_check_box</tt>.
		class LabelledFormBuilder < FormBuilder
			
			# Creates a labelled field for the propery referenced by <tt>method</tt>.
			# 
			# See <tt>LabelledFormHelper#labelled_field_tag</tt>.
			def labelled_field_for (method, content = nil, options = {}, &proc)
				options = options.stringify_keys
				options['id'] ||= "#{@object_name}_#{method}_field"
				caption = options.delete('label') || method.to_s.humanize + ":"
				options['class'] = options['class'] ? "#{options['class']} value_field" : 'value_field'
				options['class'] << ' field_with_errors' if @object.respond_to?(:errors) && @object.errors.on(method)
				@template.send(:labelled_field_tag, caption, content, "#{@object_name}_#{method}", options, &proc)
			end
			
			# Wraps a call to <tt>fields_for</tt> in a div tag, passing the standard
			# (non-labelling) <tt>FormBuilder</tt> to a block. This allows for labelled
			# fields with more than one input tag.
			# 
			# <tt>methods</tt> is an array of properties to be checked for errors,
			# and <tt>label</tt> is the caption of the label tag. If <tt>label</tt>
			# is omitted, it will be guessed from the first method passed.
			# 
			# Like <tt>fields_for</tt>, <tt>labelled_field</tt> must be called in a
			# ERb evaluation block, not a ERb output block. So that's <% %>, not <%= %>.
			def labelled_field (methods = [], label = nil, content = nil, options = {}, &proc)
				methods = [methods] if methods.respond_to?(:to_sym)
				label ||= methods.first.to_s.humanize + ":"
				
				options = options.stringify_keys
				options['params'] = FormBuilder.new(@object_name, @object, @template, {}, proc)
				options['wrap'] = [%{<span class="multi_input">}, "</span>"]
				options['class'] = options['class'] ? "#{options['class']} multi_field" : 'multi_field'
				options['class'] << ' field_with_errors' if @object.respond_to?(:errors) && methods.find {|method| @object.errors.on(method) }
				@template.send(:labelled_field_tag, label, content, nil, options, &proc)
			end
			
			# Creates a labelled check box.
			# 
			# See <tt>LabelledFormHelper#labelled_check_box</tt>.
			def labelled_check_box (method, options = {}, checked_value = "1", unchecked_value = "0")
				@template.send(:labelled_check_box, @object_name, method, options.merge(:object => @object), checked_value, unchecked_value)
			end

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
