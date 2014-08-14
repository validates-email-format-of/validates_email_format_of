require 'validates_email_format_of'

class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    err = ValidatesEmailFormatOf::validate_email_format(value, options)
    unless err.nil?
      record.errors[attribute] << err
      record.errors[attribute].flatten!
    end
  end
end

module ActiveModel::Validations::HelperMethods
  def validates_email_format_of(*attr_names)
    validates_with EmailFormatValidator, _merge_attributes(attr_names)
  end
end
