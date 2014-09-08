require 'validates_email_format_of'
require 'active_model'

if ActiveModel::VERSION::MAJOR < 2 || (2 == ActiveModel::VERSION::MAJOR && ActiveModel::VERSION::MINOR < 1)
  puts "WARNING: ActiveModel validation helper methods in validates_email_format_of gem are not compatible with ActiveModel < 2.1.0.  Please use ValidatesEmailFormatOf::validate_email_format(email, options) or upgrade ActiveModel"
end

module ActiveModel
  module Validations
    class EmailFormatValidator < EachValidator
      def validate_each(record, attribute, value)
        (ValidatesEmailFormatOf::validate_email_format(value, options.merge(:generate_message => true)) || []).each do |error|
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
