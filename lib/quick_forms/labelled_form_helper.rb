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
				
				options = args.last.is_a?(Hash) ? args.pop.stringify_keys : {}
				options['class'] = options['class'] ? "#{options['class']} labelled" : 'labelled'
				
				title = options.delete("title") || "#{controller.action_name} #{object_name}".titleize
				nodivs = options.delete("nodivs")
				
				concat(form_tag(options.delete("url") || {}, options) + "\n", proc.binding)
				concat(content_tag("h1", title) + "\n", proc.binding) unless options.delete("no_title")
				concat(tag("div", {"class" => "body"}, true), proc.binding) unless nodivs
				object = instance_variable_get("@#{object_name}")
				concat(error_messages_for(object_name), proc.binding) if object.respond_to?(:errors)
				concat(tag("div", {"class" => "fields"}, true), proc.binding) unless nodivs
				fields_for(object_name, *(args << {:builder => LabelledFormBuilder}), &proc)
				unless nodivs
					concat("</div> <!-- /fields -->\n", proc.binding)
					concat("</div> <!-- /body -->\n", proc.binding)
				end
				concat('</form>', proc.binding)
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
				options = options.stringify_keys
				caption = options.delete('label')
				label_options = options.delete('label_options') || {}
				input_options = options.delete('input') || {}
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
			
		end
		
		# Extends the build-in Rails <tt>FormBuilder</tt>
		class FormBuilder
			# Creates a labelled field for the propery referenced by <tt>method</tt>.
			# 
			# See <tt>LabelledFormHelper#labelled_field</tt>.
			def labelled_field_for (method, content = nil, options = {}, &proc)
				# TODO: error checking
				options['id'] ||= "#{@object_name}_#{method}_field"
				caption = options.delete('label') || method.to_s.humanize + ":"
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
			def labelled_field (methods, label = nil, options = {}, &proc)
				# TODO: error checking
				
				methods ||= []
				label ||= methods.first.to_s.humanize + ":"
				
				options[:params] = FormBuilder.new(@object_name, @object, @template, {}, proc)
				options[:wrap] = [%{<span class="multi_input">}, "</span>"]
				@template.send(:labelled_field, label, nil, nil, options, &proc)
			end
			
			# Creates a labelled check box.
			# 
			# See <tt>LabelledFormHelper#labelled_check_box</tt>.
			def labelled_check_box (method, options = {}, checked_value = "1", unchecked_value = "0")
				@template.send(:labelled_check_box, @object_name, method, options.merge(:object => @object), checked_value, unchecked_value)
			end
			
			# Creates a submit tag for this form and wraps it in a div tag
			# so that you can style it properly in CSS
			# <tt>caption</tt> is the caption for the tag. Defaults to 'Save'.
			def submit(caption = 'Save', options = {})
				input = @template.send(:submit_tag, caption, options)
				%{<div class="submit">#{input}</div>}
			end
			
		end
		
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
						wrap_input(method, options.delete(:label), options.delete(:field_options), @template.send(#{selector.inspect}, @object_name, method, options.merge(:object => @object)))
					end
		        end_src
				class_eval src, __FILE__, __LINE__
			end
			
			private
			
			def wrap_input (method, caption, field_options, content) #:nodoc:
				field_options ||= {}
				field_options.stringify_keys!
				field_options['label'] ||= caption
				labelled_field_for(method, content, field_options)
			end
			
			alias_method :field_for, :labelled_field_for
			alias_method :field, :labelled_field
			alias_method :check_box, :labelled_check_box
			
		end
		
	end
end