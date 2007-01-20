require 'labelled_form'
ActionView::Base.class_eval do
	include ActionView::Helpers::LabelHelper
	include ActionView::Helpers::LabelledFormHelper
	include ActionView::Helpers::FormSectionHelper
end