module ActionView #:nodoc:
	module Helpers #:nodoc:
		module FormSectionHelper
			
			# Creates a form section. The output of the block will be the contents
			# of the section. The output will be wrapped in div tags for this section.
			# 
			# Example:
			# 
			#   <% form_section(:title => 'Login') do |s| %>
			#     <% s.info do %>
			#       Please enter your username and password.
			#     <% end %>
			#     <% s.body do %>
			#       <p>Username: <%= text_field_tag 'username' %></p>
			#       <p>Password: <%= password_field_tag 'password' %></p>
			#     <% end %>
			#   <% end %>
			def form_section (options = {}, &proc) #:yields: FormSectionBuilder
				raise ArgumentError, "form_section needs a block" unless block_given?
				
				options = options.stringify_keys
				options['class'] = options['class'] ? "#{options['class']} section" : 'section'
				
				title = options.delete('title')
				
				builder = options.delete('builder') || Object.new
				class << builder
					include FormSectionBuilder
				end
				builder.section_title = title
				yield(builder)
				
				concat(tag('div', options, true) + builder.output + "</div>", proc.binding)
			end
			
			# Creates a form section. Behaves exactly like <tt>form_section</tt>, except
			# that the <tt>FormSectionBuilder</tt> passed to the block is also a <tt>FormBuilder</tt>.
			# You may specify a custom builder class using the <tt>:builder</tt> option.
			# The <tt>:builder_options</tt> option will be passed to the builder during
			# construction, and the remaining items in <tt>options</tt> are passed to
			# <tt>form_section</tt>.
			# 
			# See <tt>form_section</tt>.
			def form_section_for (object_name, object, options = {}, &proc) #:yields: FormSectionBuilder/FormBuilder
				raise ArgumentError, "form_section_for needs a block" unless block_given?
				
				options = options.symbolize_keys
				options[:builder] = (options.delete(:builder) || FormBuilder).new(object_name, object, self, options.delete(:builder_options), proc)
				form_section(options, &proc)
			end
			
		end
		
		# Extends the build-in Rails <tt>FormBuilder</tt>
		class FormBuilder

			# Creates a section in this form, using this builder's class as the builder.
			# 
			# See <tt>FormSectionHelper#form_section</tt>.
			def section (options = {}, &proc) #:yields: FormSectionBuilder/FormBuilder
				@template.send(:form_section_for, @object_name, @object, :builder => self.class, &proc)
			end

		end
		
		# Facilitates separating forms into sections. See <tt>FormSectionHelper#form_section_for</tt>.
		module FormSectionBuilder
			
			include Helpers::CaptureHelper
			include Helpers::TagHelper
			
			def self.included (base) #:nodoc:
				base.class_eval do
					attr_accessor :section_title
				end
			end
			
			# Creates the info block for a section. 
			def info (&proc)
				@info = capture(&proc)
			end
			
			# Creates the body block for a section.
			def body (&proc)
				@body = capture(&proc)
			end
			
			def output #:nodoc:
				result = ""
				
				unless @info.nil?
					@info = content_tag("h2", @section_title) + "\n" + @info unless @section_title.nil?
					result += content_tag("div", "\n#@info", {"class" => "section_info"}) + "\n"
				end
				
				unless @body.nil?
					result += content_tag("div", "\n#@body", {"class" => "section_body"}) + "\n"
				end
				
				result
			end
			
		end
		
	end
end