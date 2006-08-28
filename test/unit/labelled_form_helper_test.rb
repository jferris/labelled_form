require File.dirname(__FILE__) + '/../test_helper'

class LabelledFormBuilderTest < Test::Unit::TestCase
	
	def test_labelled_form_for
		template = <<-end_template
			<% labelled_form_for :var, :nodivs => true do |f| %>
			<%= f.text_field :name %>
			<% end %>
		end_template
		render(template, :name => 'test')
		assert_tag({
			:tag => 'form',
			:child => {
				:tag => 'div',
				:attributes => {:class => 'field'},
				:child => {
					:tag => 'label',
					:attributes => {:for => 'var_name'},
					:content => 'Name:'
				}
			}
		})
	end
	
	def test_labelled_field
		template = <<-end_template
			<%= labelled_field 'Test:', '<span>content</span>' %>
		end_template
		render(template)
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'field'},
			:child => {
				:tag => 'label',
				:attributes => {:for => nil},
				:content => 'Test:'
			}
		})
		assert_tag(:tag => 'span', :content => 'content')
	end
	
	def test_labelled_field_multi
		template = <<-end_template
			<% labelled_form_for :var do |f| %>
			<% f.field [:name], 'Test:' do |field| %>
			<%= field.text_field :name %>
			<% end %>
			<% end %>
		end_template
		render(template, :name => 'test')
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'field'},
			:child => {
				:tag => 'label',
				:attributes => {:for => nil},
				:content => 'Test:'
			}
		})
		assert_tag({
			:tag => 'div',
			:child => {
				:tag => 'span',
				:attributes => {:class => 'multi_input'},
			}
		})
		assert_tag({
			:tag => 'div',
			:child => {
				:tag => 'span',
				:child => {:tag => 'input'}
			}
		})
	end
	
	# tests wrapping for all built-in Rails helpers
	def test_builder_methods
		# helpers to test
		helpers = {
			# standard helpers for input tags
			'input' => %w{ hidden_field password_field text_field },
			# helpers for select tags
			'select' => [
			['date_select', "<%= f.date_select :name %>", Date.parse('2000-01-01')],
			['datetime_select', "<%= f.datetime_select :name %>", Time.parse('2000-01-01 00:00:00')]
			],
			# other helpers
			'textarea' => %w{ text_area }
		}
		
		field_partials = []
		assertions = []
		
		# build a collection of partials and assertions
		helpers.each do |tag, tag_helpers|
			tag_helpers.each do |helper|
				if helper.respond_to?(:to_ary)
					# custom partial
					helper, partial, value = helper
					field_partials << [partial, value]
				else
					# standard
					field_partials << "<%= f.#{helper} :name %>"
				end
				
				# this assertion checks for a wrapped tag of the correct type
				# and also replaces the long, useless error from assert_tag
				assertions << lambda do
					begin
						assert_tag({
							:tag => 'div',
							:attributes => {:class => 'field'},
							:child => {:tag => tag}
						})
					rescue Test::Unit::AssertionFailedError => e
						if e.message =~ /expected tag/
							flunk("Helper failed: #{helper}\nHelper result: #{@response.body}")
						else
							raise
						end
					end
				end
			end
		end
		
		# render each partial and run its assertion
		field_partials.each do |partial|
			if partial.respond_to?(:to_ary)
				# non-standard helpers provide a partial
				# and a value to test for the variable
				# (because of date_select, etc)
				partial, value = partial
			else
				# standard helpers just use a test string
				value = 'test'
			end
			template = <<-end_template
				<% labelled_form_for :var do |f| %>
				#{partial}
				<% end %>
			end_template
			render(template, :name => value)
			assertions.shift.call
		end
		
	end
	
	def test_text_field_has_text_class
		template = <<-end_template
			<% labelled_form_for :var do |f| %>
			<%= f.text_field :name %>
			<% end %>
		end_template
		render(template, :name => 'test')
		
		assert_tag({
			:tag => 'input',
			:attributes => {:class => 'text'}
		})
	end
	
	def test_submit
		template = <<-end_template
			<% labelled_form_for :var do |f| %>
			<%= f.submit('Submit') %>
			<% end %>
		end_template
		render(template, :name => 'test')
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'submit'},
			:child => {
				:tag => 'input',
				:attributes => {
					:type => 'submit',
					:value => 'Submit'
				},
			}
		})
	end
	
	def test_labelled_check_box
		render(%{<%= labelled_check_box(:var, :name) %>}, :name => '1')
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'boolean_field'},
			:child => {
				:tag => 'input',
				:attributes => {
					:checked => 'checked',
					:id => 'var_name',
					:value => '1'
				}
			}
		})
		assert_tag({
			:tag => 'div',
			:child => {
				:tag => 'label',
				:attributes => {:for => 'var_name'},
				:content => 'Name:'
			}
		})
	end
	
	def test_builder_labelled_check_box
		template = <<-end_template
			<% fields_for :var do |f| %>
			<%= f.labelled_check_box :name %>
			<% end %>
		end_template
		render(template, :name => '1')
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'boolean_field'}
		})
	end
	
	def test_labelled_check_box_tag
		render(%{<%= labelled_check_box_tag('var_name', '1', true) %>})
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'boolean_field'},
			:child => {
				:tag => 'input',
				:attributes => {
					:checked => 'checked',
					:id => 'var_name',
					:value => '1'
				}
			}
		})
		assert_tag({
			:tag => 'div',
			:child => {
				:tag => 'label',
				:attributes => {:for => 'var_name'},
				:content => 'Var name:'
			}
		})
	end
	
	def test_labelled_builder_check_box
		template = <<-end_template
			<% labelled_form_for :var do |f| %>
			<%= f.check_box :name %>
			<% end %>
		end_template
		render(template, :name => '1')
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'boolean_field'}
		})
	end
	
end