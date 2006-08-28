require File.dirname(__FILE__) + '/../test_helper'

class FormSectionHelperTest < Test::Unit::TestCase
	
	def test_form_section_builder_module
		template = <<-end_template
			<%
				s = Object.new
				class << s
					include Helpers::FormSectionBuilder
				end
				s.section_title = 'Section Title'
			%>
			<% s.info do %>
				<p>I am the info</p>
			<% end %>
			<% s.body do %>
				<p>I am the body</p>
			<% end %>
			<%= s.output %>
		end_template
		render(template)
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'section_info'},
			:child => {
				:tag => 'h2',
				:content => 'Section Title'
			}
		})
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'section_info'},
			:child => {
				:tag => 'p',
				:content => 'I am the info'
			}
		})
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'section_body'},
			:child => {
				:tag => 'p',
				:content => 'I am the body'
			}
		})
	end
	
	def test_form_section
		template = <<-end_template
			<% form_section(:title => 'Section Title') do |s| %>
				<% s.info do %>
					<p>I am the info</p>
				<% end %>
				<% s.body do %>
					<p>I am the body</p>
				<% end %>
			<% end %>
		end_template
		render(template)
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'section'},
			:child => {:tag => 'div'}
		})
	end
	
	def test_form_section_for
		template = <<-end_template
			<% form_section_for(:var, @var, :title => 'Section Title') do |s| %>
				<% s.info do %>
					<p>I am the info</p>
				<% end %>
				<% s.body do %>
					<%= s.text_field :name %>
				<% end %>
			<% end %>
		end_template
		render(template, :name => 'test')
		
		assert_tag({
			:tag => 'div',
			:attributes => {:class => 'section_body'},
			:child => {
				:tag => 'input',
				:attributes => {
					:id => 'var_name',
					:value => 'test'
				}
			}
		})
	end
	
	def test_form_builder_section
		template = <<-end_template
			<% form_for(:var, @var) do |f| %>
				<% f.section :title => 'Section Title' do |s| %>
					<% s.info do %>
						<p>I am the info</p>
					<% end %>
					<% s.body do %>
						<%= s.text_field :name %>
					<% end %>
				<% end %>
			<% end %>
		end_template
		render(template, :name => 'test')
		
		assert_tag({
			:tag => 'form',
			:child => {
				:tag => 'div',
				:attributes => {:class => 'section'},
				:child => {
					:tag => 'div',
					:attributes => {:class => 'section_body'},
					:child => {
						:tag => 'input',
						:attributes => {
							:id => 'var_name',
							:value => 'test'
						}
					}
				}
			}
		})
	end
	
	def test_labelled_form_builder_section
		template = <<-end_template
			<% labelled_form_for(:var, @var) do |f| %>
				<% f.section :title => 'Section Title' do |s| %>
					<% s.info do %>
						<p>I am the info</p>
					<% end %>
					<% s.body do %>
						<%= s.text_field :name %>
					<% end %>
				<% end %>
			<% end %>
		end_template
		render(template, :name => 'test')

		assert_tag({
			:tag => 'form',
			:attributes => {:class => 'labelled'},
			:descendant => {
				:tag => 'div',
				:attributes => {
					:class => 'field',
					:id => 'var_name_field'
				}
			}
		})
	end
	
end