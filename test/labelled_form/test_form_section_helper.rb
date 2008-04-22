require File.dirname(__FILE__) + '/../test_helper'

describe "form section helpers" do
	
  context "building a form section" do

    before do
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
    end
		
    it "should create a title section" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'section_info'},
        :child => {
          :tag => 'h2',
          :content => 'Section Title'
        }
      })
    end

    it "should create an info section" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'section_info'},
        :child => {
          :tag => 'p',
          :content => 'I am the info'
        }
      })
    end

    it "should create a body section"do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'section_body'},
        :child => {
          :tag => 'p',
          :content => 'I am the body'
        }
      })
    end

	end
	
  context "creating a form section" do

    before do
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
    end
      
    it "should create a div for the section" do
      assert_tag({
        :tag => 'div',
        :attributes => {:class => 'section'},
        :child => {:tag => 'div'}
      })
    end

  end
	
  context "create a form section for an object" do

    before do
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
    end
		
    it "should create the section body" do
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

	end
	
  context "building a form section from a builder" do

    setup do
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
    end
		
    it "should create the form tag" do
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

	end
	
  context "building a section from a labelled from builder" do

    before do
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
    end

    it "should build a labelled form" do
      assert_tag({
        :tag => 'form',
        :attributes => {:class => 'labelled'},
        :descendant => {
          :tag => 'div',
          :attributes => {
            :class => 'value_field field',
            :id => 'var_name_field'
          }
        }
      })
    end

	end
	
end
