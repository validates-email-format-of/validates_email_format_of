require 'validates_email_format_of'

module ActiveModel
  module Validations
    class EmailFormatValidator < EachValidator
      def validate_each(record, attribute, value)
        (ValidatesEmailFormatOf::validate_email_format(value, options) || []).each do |error|
          record.errors.add(attribute, error)
        end
      end
    end

    module HelperMethods
      def validates_email_format_of(*attr_names)
        validates_with EmailFormatValidator, _merge_attributes(attr_names)
      end
    end
  end
end
