module ActionView #:nodoc:
	module Helpers #:nodoc:
		module LabelledFormHelper #:nodoc:
		
			def labelled_form_for_with_record_identification(name_or_object, *args, &proc)
				form_method_with_record_identification :labelled_form_for, name_or_object, *args, &proc
			end
			
			alias_method_chain :labelled_form_for, :record_identification
			
		end
	end
end