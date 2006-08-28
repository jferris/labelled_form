require File.dirname(__FILE__) + '/../test_helper'

class LabelHelperTest < Test::Unit::TestCase
	
	def test_label_tag
		render(%{<%= label_tag(:address) %>})
		assert_tag :tag => 'label',
		:attributes => {:for => 'address'},
		:content => 'Address:'
		
		result = render(%{<%= label_tag(:address, "Mailing Address:") %>})
		assert_tag :tag => 'label',
		:attributes => {:for => 'address'},
		:content => 'Mailing Address:'
		
		result = render(%{<%= label_tag(nil, "Mailing Address:") %>})
		assert_tag :tag => 'label',
		:attributes => {:for => nil},
		:content => 'Address:'
		
		result = render(%{<%= label_tag(:address, "Mailing Address:", :class => 'test') %>})
		assert_tag :tag => 'label',
		:attributes => {:for => 'address', :class => 'test'},
		:content => 'Mailing Address:'
	end
	
	def test_label
		render(%{<%= label(:var, :name) %>}, :name => 'test')
		assert_tag :tag => 'label',
		:attributes => {:for => 'var_name'},
		:content => 'Name:'
	end
	
	def test_label_builder
		template = <<EOF
<% form_for(:var, @var) do |f| %>
<%= f.label(:name) %>
<% end %>
EOF
		render(template, :name => 'test')
		assert_tag :tag => 'label',
		:attributes => {:for => 'var_name'},
		:content => 'Name:'
	end
	
end