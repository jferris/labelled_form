module ActionView #:nodoc:
	module Helpers #:nodoc:
		module LabelledFormHelper #:nodoc:
		
			def labelled_form_for_with_record_identification(name_or_object, *args, &proc)
				if self.respond_to?(:form_method_with_record_identification)
					form_method_with_record_identification :labelled_form_for, name_or_object, *args, &proc
				else
					labelled_form_for_without_record_identification(name_or_object, *args, &proc)
				end
			end
			
			alias_method_chain :labelled_form_for, :record_identification
			
		end
	end
end