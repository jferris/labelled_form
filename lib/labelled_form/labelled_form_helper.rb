module ActionView #:nodoc:
	module Helpers #:nodoc:
		
		module LabelledFormHelper
			
			# Calls <tt>form_for</tt> with <tt>LabelledFormBuilder</tt> as a builder.
			# This wraps each of the built-in Rails helper methods with a call to
			# <tt>labelled_field</tt>, which adds a label and wraps the field
			# in a div tag.
			# 
			# The last argument is an options hash, which accepts the following:
			# 
			# title::
			#   the title of this form, presented in an h1 tag. If omitted,
			#   the title will be guessed from the names of the controller and action.
			# no_title:: if set to true, no title will be added to this form.
			# nodivs::
			#   if set to true, div tags (for easier styling) will not be added
			#   to the form.
			# 
			# Like <tt>form_for</tt>, <tt>labelled_form_for</tt> must be called in a
			# ERb evaluation block, not a ERb output block. So that's <% %>, not <%= %>.
			def labelled_form_for (object_name, *args, &proc)
				raise ArgumentError, "Missing block" unless block_given?
				
				options = args.last.is_a?(Hash) ? args.pop : {}
				nodivs = options.delete(:nodivs)
				
				html_options = (options.delete(:html) || {}).stringify_keys
				html_options['class'] = html_options['class'] ? "#{html_options['class']} labelled" : 'labelled'
				
				concat(form_tag(options.delete(:url) || {}, html_options) + "\n", proc.binding)
				object = instance_variable_get("@#{object_name}")
				fields_for(object_name, *(args << {:builder => LabelledFormBuilder}), &proc)
				concat('</form>', proc.binding)
			end
			
			# Calls <tt>fields_for</tt> with <tt>LabelledFormBuilder</tt> as a builder.
			# This wraps each of the built-in Rails helper methods with a call to
			# <tt>labelled_field</tt>, which adds a label and wraps the field
			# in a div tag.
			def labelled_fields_for (object_name, *args, &proc)
				raise ArgumentError, "Missing block" unless block_given?
				fields_for(object_name, *(args << {:builder => LabelledFormBuilder}), &proc)
			end
			
			# Wraps <tt>content</tt> with a div tag and adds a label.
			# Parameters:
			# 
			# caption:: The caption for the field's label (contents of the label tag)
			# element_id::
			#   The ID attribute of the HTML element this label is linked to.
			#   If <tt>nil</tt>, no element will be linked.
			# 
			# Options:
			# 
			# label_options::
			#   extra HTML attributes (such as a custom <tt>for</tt> attribute) for
			#   the label tag
			# Other options will be used as HTML attributes for the div tag.
			# 
			# If <tt>content</tt> is omitted, a block must be provided. In this case,
			# <tt>content</tt> will be set to the result of the block, and
			# <tt>labelled_field</tt> must be called in a ERb evaluation block,
			# not a ERb output block. So that's <% %>, not <%= %>.
			def labelled_field (caption, content = nil, element_id = nil, options = {}, &proc)
				raise ArgumentError, "You mast pass either content or a block" if content.nil? and !block_given?
				
				options.stringify_keys!
				options['class'] = options['class'] ? "#{options['class']} field" : 'field'
				
				label = label_tag(element_id, caption, options.delete('label_options') || {})
				params = options.delete('params') || []
				before_input, after_input = options.delete("wrap") || ["", ""]
				
				field_start = tag('div', options, true) + label + "\n" + before_input
				field_end = after_input + '</div>'
				
				if block_given?
					concat(field_start, proc.binding)
					yield(*params)
					concat(field_end, proc.binding)
				else
					field_start + content + field_end
				end
			end
			
			# Creates a labelled check box for the specified <tt>object_name</tt> and
			# <tt>method</tt>.
			# 
			# See <tt>labelled_check_box_tag</tt>.
			def labelled_check_box (object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
				caption = options.delete(:label) || (method.to_s.humanize + "?")
				label_options = options.delete(:label_options) || {}
				input_options = options.delete(:input) || {}
				InstanceTag.new(object_name, method, self, nil,
								options.delete(:object)).to_labelled_check_box_tag(caption, label_options, input_options, options, checked_value, unchecked_value)
			end
			
			# Creates a labelled check box (a boolean input field). Works like <tt>check_box</tt>,
			# except that a label tag will be added after the input tag, and the entire field
			# is wrapped in a div tag.
			# 
			# Options:
			# 
			# label:: the caption for the label. If omitted, the label will be guessed from the method name.
			def labelled_check_box_tag (name, value = "1", checked = false, options = {})
				options = options.stringify_keys
				caption = options.delete('label')
				label_options = options.delete('label_options') || {}
				input_options = options.delete('input') || {}
				
				check_box = check_box_tag(name, value, checked, input_options)
				label = label_tag(input_options['id'] || name || nil, caption, label_options)
				
				options['class'] = options['class'] ? "#{options['class']} boolean_field" : 'boolean_field'
				
				content_tag('div', check_box + label, options)
			end
			
		end
		
		class InstanceTag #:nodoc:
			
			def to_labelled_check_box_tag (caption = nil, label_options = {}, input_options = {}, div_options = {}, checked_value = "1", unchecked_value = "0")
				check_box = to_check_box_tag(input_options, checked_value, unchecked_value)
				label = to_label_tag(caption, label_options)
				
				div_options = div_options.stringify_keys
				div_options['class'] = div_options['class'] ? "#{div_options['class']} boolean_field" : 'boolean_field'
				
				content_tag('div', check_box + label, div_options)
			end
			
			# Allows disabling the built-in Rails forms error-handling
			
			@@error_wrapping_enabled = true
			cattr_accessor :error_wrapping_enabled
			
			def error_wrapping_with_toggle (html_tag, has_error)
				error_wrapping_enabled ? error_wrapping_without_toggle(html_tag, has_error) : html_tag
			end

			alias_method_chain :error_wrapping, :toggle
			
		end
		
		# Extends the build-in Rails <tt>FormBuilder</tt>
		class FormBuilder
			# Creates a labelled field for the propery referenced by <tt>method</tt>.
			# 
			# See <tt>LabelledFormHelper#labelled_field</tt>.
			def labelled_field_for (method, content = nil, options = {}, &proc)
				options = options.stringify_keys
				options['id'] ||= "#{@object_name}_#{method}_field"
				caption = options.delete('label') || method.to_s.humanize + ":"
				options['class'] = options['class'] ? "#{options['class']} value_field" : 'value_field'
				options['class'] << ' field_with_errors' if @object.respond_to?(:errors) && @object.errors.on(method)
				@template.send(:labelled_field, caption, content, "#{@object_name}_#{method}", options, &proc)
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
				@template.send(:labelled_field, label, content, nil, options, &proc)
			end
			
			# Creates a labelled check box.
			# 
			# See <tt>LabelledFormHelper#labelled_check_box</tt>.
			def labelled_check_box (method, options = {}, checked_value = "1", unchecked_value = "0")
				@template.send(:labelled_check_box, @object_name, method, options.merge(:object => @object), checked_value, unchecked_value)
			end
			
		end
		
	end
end
