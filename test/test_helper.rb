require 'test/unit'
require 'ostruct'
require 'rubygems'
require 'spec'
require 'hpricot'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'
require 'active_record'
require 'active_record/fixtures'

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '../lib'))

ActionController::Base.view_paths = [File.join(File.dirname(__FILE__), 'views')]

require File.join(File.dirname(__FILE__), '../init')

ActionController::Routing::Routes.draw do |map|
	map.connect ':controller/:action/:id'
end

class TestController < ActionController::Base

	attr_accessor :template_string, :var

	def rescue_action (e)
		raise e
	end
	
	def test
		render :inline => template_string
	end

end

class Test::Unit::TestCase

	self.use_transactional_fixtures = true
	self.use_instantiated_fixtures  = false
	self.fixture_path = File.dirname(__FILE__) + '/fixtures'
	
	def render (template, var = nil)
		@controller	= TestController.new
		@request	= ActionController::TestRequest.new
		@response	= ActionController::TestResponse.new
		
		@controller.template_string = template
		@controller.var = var.is_a?(Hash) ? OpenStruct.new(var) : var
		
		get :test
		assert_response :success
		
		@response.body
	end

end

module TagMatchers

  class TagMatcher

    def initialize (expected, text = nil)
      @expected = expected
      @text     = text
    end

    def matches? (target)
      @target = target
      doc = Hpricot(target)
      @elem = doc.at(@expected)
      @elem && (@text.nil? || @elem.inner_html == @text)
    end

    def failure_message
      "Expected #{match_message}"
    end

    def negative_failure_message
      "Did not expect #{match_message}"
    end

    protected

    def match_message
      if @elem
        "#{@elem.to_s.inspect} to have text #{@text.inspect}"
      else
        "#{@target.inspect} to contain element #{@expected.inspect}"
      end
    end

  end

  def have_tag (expression)
    TagMatcher.new(expression)
  end

  def have_text (expression, text)
    TagMatcher.new(expression, text)
  end

end

Spec::Runner.configure do |config|
  config.include TagMatchers
end

require 'labelled_form'
require 'schema'
require 'models'

ActiveRecord::Base.establish_connection(
	:adapter	=> 'sqlite3',
	:database	=> 'test/test.db'
)

DatabaseSchema.verbose = false
begin
	DatabaseSchema.migrate(:down)
rescue
end
DatabaseSchema.migrate(:up)

