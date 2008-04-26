require File.dirname(__FILE__) + '/../test_helper'

describe "labelled form helpers" do
	
  describe "creating a labelled form for a record" do

    before do
      template = <<-end_template
        <% labelled_form_for :var, :nodivs => true do |f| %>
        <%= f.text_field :name %>
        <% end %>
      end_template
      render(template, :name => 'test')
    end

    it "should generate a form tag" do
      assert_tag({
        :tag => 'form',
        :child => {
          :tag => 'div',
          :attributes => {:class => 'value_field field'},
          :child => {
            :tag => 'label',
            :attributes => {:for => 'var_name'},
            :content => 'Name:'
          }
        }
      })
    end

  end

  describe "creating labelled fields for a record" do

    before do
      template = <<-end_template
        <% labelled_fields_for :var do |f| %>
        <%= f.text_field :name %>
        <% end %>
      end_template
      render(template, :name => 'test')
    end

    it "should generate a field wrapper" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'value_field field'},
        :child => {
          :tag => 'label',
          :attributes => {:for => 'var_name'},
          :content => 'Name:'
        }
      })
    end

  end

  describe "creating a labelled field" do

    before do
      template = <<-end_template
        <%= labelled_field 'Test:', '<span>content</span>' %>
      end_template
      render(template)
    end

    it "should generate a div for the field" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'field'},
        :child => {
          :tag => 'label',
          :attributes => {:for => nil},
          :content => 'Test:'
        }
      })
    end

    it "should generate a span around the input" do
      assert_tag(:tag => 'span', :content => 'content')
    end

	end
	
  describe "generating a field with multiple inputs" do

    before do
      template = <<-end_template
        <% labelled_form_for :var do |f| %>
        <% f.field [:name], 'Test:' do |field| %>
        <%= field.text_field :name %>
        <% end %>
        <% end %>
      end_template
      render(template, :name => 'test')
    end
		
    it "should generate a div with a multi_field class" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'multi_field field'},
        :child => {
          :tag => 'label',
          :attributes => {:for => nil},
          :content => 'Test:'
        }
      })
    end

    it "should generate a span with a multi_input class" do
      assert_tag({
        :tag => 'div',
        :child => {
          :tag => 'span',
          :attributes => {:class => 'multi_input'},
        }
      })
    end

    it "should generate the text input tag" do
      assert_tag({
        :tag => 'div',
        :child => {
          :tag => 'span',
          :child => {:tag => 'input'}
        }
      })
    end

	end
	
  # this crap should be rewritten
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
						field_class = %w(date_select datetime_select).include?(helper) ?
						'multi_field' : 'value_field'
						assert_tag({
							:tag => 'div',
							:attributes => {:class => "#{field_class} field"},
							:descendant => {:tag => tag}
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
	
  describe "a text input field" do

    before do
      template = <<-end_template
        <% labelled_form_for :var do |f| %>
        <%= f.text_field :name %>
        <% end %>
      end_template
      render(template, :name => 'test')
    end

    it "should have the text class" do
      assert_tag({
        :tag => 'input',
        :attributes => {:class => 'text'}
      })
    end

	end
	
  describe "generating a labelled check box" do

    before do
      render(%{<%= labelled_check_box(:var, :name) %>}, :name => '1')
    end
		
    it "should surround the check box with a boolean_field div" do
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
    end

    it "should create a label for the check box" do
      assert_tag({
        :tag => 'div',
        :child => {
          :tag => 'label',
          :attributes => {:for => 'var_name'},
          :content => 'Name?'
        }
      })
    end

	end
	
  describe "generating a labelled check box" do

    before do
      template = <<-end_template
        <% fields_for :var do |f| %>
        <%= f.labelled_check_box :name %>
        <% end %>
      end_template
      render(template, :name => '1')
    end
		
    it "should use the boolean_field class" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'boolean_field'}
      })
    end

	end
	
  describe "generating a labelled check box tag" do

    before do
      render(%{<%= labelled_check_box_tag('var_name', '1', true) %>})
    end
		
    it "should generate the input tag" do
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
    end

    it "should generate the label tag" do
      assert_tag({
        :tag => 'div',
        :child => {
          :tag => 'label',
          :attributes => {:for => 'var_name'},
          :content => 'Var name:'
        }
      })
    end

	end
	
  describe "generating a labelled check box using a form builder" do

    before do
      template = <<-end_template
        <% labelled_form_for :var do |f| %>
        <%= f.check_box :name %>
        <% end %>
      end_template
      render(template, :name => '1')
    end
		
    it "should use the boolean_field class" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'boolean_field'}
      })
    end

	end
	
  describe "a value field with errors" do

    before do
      template = <<-end_template
        <% labelled_fields_for :var, @var do |f| %>
        <%= f.text_field :name %>
        <% end %>
      end_template
      render(template, :name => '1', :errors => Errors.new(:name))
    end
		
    it "should have an error class" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'value_field field_with_errors field'}
      })
    end
	end
	
  describe "a multiple field with errors" do

    before do
      template = <<-end_template
        <% labelled_fields_for :var, @var do |f| %>
        <% f.field :name do |field| %>
        Field
        <% end %>
        <% end %>
      end_template
      render(template, :name => '1', :errors => Errors.new(:name))
    end
		
    it "should have an error class" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'multi_field field_with_errors field'}
      })
    end

	end
	
	class Errors
	
		def initialize (*vars)
			@vars = vars.collect(&:to_sym)
		end
		
		def on (var)
			@vars.include?(var.to_sym)
		end
		
	end	
	
end
