# encoding: utf-8
module ValidatesEmailFormatOf
  require 'resolv'

  MessageScope = defined?(ActiveModel) ? :activemodel : :activerecord

  LocalPartSpecialChars = Regexp.escape('!#$%&\'*-/=?+-^_`{|}~')
  LocalPartUnquoted = '([[:alnum:]' + LocalPartSpecialChars + ']+[\.]+)*[[:alnum:]' + LocalPartSpecialChars + '+]+'
  LocalPartQuoted = '\"([[:alnum:]' + LocalPartSpecialChars + '\.]|\\\\[\x00-\xFF])*\"'
  Regex = Regexp.new('\A(' + LocalPartUnquoted + '|' + LocalPartQuoted + '+)@(((\w+\-+[^_])|(\w+\.[a-z0-9-]*))*([a-z0-9-]{1,63})\.[a-z]{2,6}(?:\.[a-z]{2,6})?\Z)', Regexp::EXTENDED | Regexp::IGNORECASE, 'n')

  def self.validate_email_domain(email)
    domain = email.match(/\@(.+)/)[1]
    Resolv::DNS.open do |dns|
      @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX) + dns.getresources(domain, Resolv::DNS::Resource::IN::A)
    end
    @mx.size > 0 ? true : false
  end

  # Validates whether the specified value is a valid email address.  Returns nil if the value is valid, otherwise returns an array
  # containing one or more validation error messages.
  #
  # Configuration options:
  # * <tt>message</tt> - A custom error message (default is: "does not appear to be a valid e-mail address")
  # * <tt>check_mx</tt> - Check for MX records (default is false)
  # * <tt>mx_message</tt> - A custom error message when an MX record validation fails (default is: "is not routable.")
  # * <tt>with</tt> The regex to use for validating the format of the email address (default is ValidatesEmailFormatOf::Regex)</tt>
  # * <tt>local_length</tt> Maximum number of characters allowed in the local part (default is 64)
  # * <tt>domain_length</tt> Maximum number of characters allowed in the domain part (default is 255)
  def self.validate_email_format(email, options={})
      default_options = { :message => I18n.t(:invalid_email_address, :scope => [MessageScope, :errors, :messages], :default => 'does not appear to be valid'),
                          :check_mx => false,
                          :mx_message => I18n.t(:email_address_not_routable, :scope => [MessageScope, :errors, :messages], :default => 'is not routable'),
                          :with => ValidatesEmailFormatOf::Regex ,
                          :domain_length => 255,
                          :local_length => 64
                          }
      options.merge!(default_options) {|key, old, new| old}  # merge the default options into the specified options, retaining all specified options

      email.strip!

      # local part max is 64 chars, domain part max is 255 chars
      # TODO: should this decode escaped entities before counting?
      begin
        domain, local = email.reverse.split('@', 2)
      rescue
        return [ options[:message] ]
      end

      unless email =~ options[:with] and not email =~ /\.\./ and domain.length <= options[:domain_length] and local.length <= options[:local_length]
        return [ options[:message] ]
      end

      if options[:check_mx] and !ValidatesEmailFormatOf::validate_email_domain(email)
        return [ options[:mx_message] ]
      end

      return nil    # represents no validation errors
  end

  module Validations
    # Validates whether the value of the specified attribute is a valid email address
    #
    #   class User < ActiveRecord::Base
    #     validates_email_format_of :email, :on => :create
    #   end
    #
    # Configuration options:
    # * <tt>message</tt> - A custom error message (default is: "does not appear to be a valid e-mail address")
    # * <tt>on</tt> - Specifies when this validation is active (default is :save, other options :create, :update)
    # * <tt>allow_nil</tt> - Allow nil values (default is false)
    # * <tt>allow_blank</tt> - Allow blank values (default is false)
    # * <tt>check_mx</tt> - Check for MX records (default is false)
    # * <tt>mx_message</tt> - A custom error message when an MX record validation fails (default is: "is not routable.")
    # * <tt>if</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   occur (e.g. :if => :allow_validation, or :if => Proc.new { |user| user.signup_step > 2 }).  The
    #   method, proc or string should return or evaluate to a true or false value.
    # * <tt>unless</tt> - See <tt>:if</tt>
    def validates_email_format_of(*attr_names)
      options = { :on => :save,
        :allow_nil => false,
        :allow_blank => false }
      options.update(attr_names.pop) if attr_names.last.is_a?(Hash)

      validates_each(attr_names, options) do |record, attr_name, value|
        v = value.to_s
        errors = ValidatesEmailFormatOf::validate_email_format(v, options)
        errors.each do |error|
          record.errors.add(attr_name, error)
        end unless errors.nil?
      end
    end
  end
end

if defined?(ActiveModel)
  module ActiveModel::Validations::HelperMethods
    include ValidatesEmailFormatOf::Validations
  end
else
  class ActiveRecord::Base
    extend ValidatesEmailFormatOf::Validations
  end
end
