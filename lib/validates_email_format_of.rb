module ValidatesEmailFormatOf
  Local_Part_Special_Chars = Regexp.escape('!#$%&\'*-/=?+-^_`{|}~')
  
  Regex = Regexp.new(
    '^(
        (([[:alnum:]' + Local_Part_Special_Chars + ']|\\\\[\x00-\xFF])+[\.\+]+)
      )*
      ([[:alnum:]' + Local_Part_Special_Chars + '+]|\\\\[\x00-\xFF])+
    @
    (((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$)',
    Regexp::EXTENDED | Regexp::IGNORECASE
  )
end

module ActiveRecord
  module Validations
    module ClassMethods
      # Validates whether the value of the specified attribute is a valid email address
      #
      #   class User < ActiveRecord::Base
      #     validates_email_format_of :email, :on => :create
      #   end
      #
      # Configuration options:
      # * <tt>message</tt> - A custom error message (default is: " does not appear to be a valid e-mail address")
      # * <tt>on</tt> - Specifies when this validation is active (default is :save, other options :create, :update)
      # * <tt>allow_nil</tt> Allow nil values (default is false)
      # * <tt>if</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   occur (e.g. :if => :allow_validation, or :if => Proc.new { |user| user.signup_step > 2 }).  The
      #   method, proc or string should return or evaluate to a true or false value.
      def validates_email_format_of(*attr_names)
        configuration = { :message => ' does not appear to be a valid e-mail address', 
                          :on => :save, 
                          :allow_nil => false,
                          :with => ValidatesEmailFormatOf::Regex }

        # local part must be max 64 chars
        # domain part must be max of 255 chars

        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          next if value.nil? and configuration[:allow_nil]

          v = value.to_s

          unless v =~ configuration[:with] and not v =~ /\.\./
            record.errors.add(attr_name, configuration[:message])
          end
        end
      end
    end   
  end
end
