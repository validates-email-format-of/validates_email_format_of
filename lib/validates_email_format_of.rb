# encoding: utf-8
module ValidatesEmailFormatOf
  require 'resolv'

  VERSION = '1.5.3'

  MessageScope = defined?(ActiveModel) ? :activemodel : :activerecord

  LocalPartSpecialChars = /[\!\#\$\%\&\'\*\-\/\=\?\+\-\^\_\`\{\|\}\~]/

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
  # * <tt>message</tt> - A custom error message (default is: "does not appear to be valid")
  # * <tt>check_mx</tt> - Check for MX records (default is false)
  # * <tt>mx_message</tt> - A custom error message when an MX record validation fails (default is: "is not routable.")
  # * <tt>with</tt> The regex to use for validating the format of the email address (deprecated)
  # * <tt>local_length</tt> Maximum number of characters allowed in the local part (default is 64)
  # * <tt>domain_length</tt> Maximum number of characters allowed in the domain part (default is 255)
  def self.validate_email_format(email, options={})
      default_options = { :message => I18n.t(:invalid_email_address, :scope => [MessageScope, :errors, :messages], :default => 'does not appear to be valid'),
                          :check_mx => false,
                          :mx_message => I18n.t(:email_address_not_routable, :scope => [MessageScope, :errors, :messages], :default => 'is not routable'),
                          :domain_length => 255,
                          :local_length => 64
                          }
      opts = options.merge(default_options) {|key, old, new| old}  # merge the default options into the specified options, retaining all specified options

      email = email.strip if email
      
      begin
        domain, local = email.reverse.split('@', 2)
      rescue
        return [ opts[:message] ]
      end

      # need local and domain parts
      return [ opts[:message] ] unless local and not local.empty? and domain and not domain.empty?

      # check lengths
      return [ opts[:message] ] unless domain.length <= opts[:domain_length] and local.length <= opts[:local_length]

      local.reverse!
      domain.reverse!

      if opts.has_key?(:with) # holdover from versions <= 1.4.7
        return [ opts[:message] ] unless email =~ opts[:with]
      else
        return [ opts[:message] ] unless self.validate_local_part_syntax(local) and self.validate_domain_part_syntax(domain)
      end

      if opts[:check_mx] and !self.validate_email_domain(email)
        return [ opts[:mx_message] ]
      end

      return nil    # represents no validation errors
  end
  

  def self.validate_local_part_syntax(local)
    in_quoted_pair = false
    in_quoted_string = false

    (0..local.length-1).each do |i|
      ord = local[i].ord

      # accept anything if it's got a backslash before it
      if in_quoted_pair 
        in_quoted_pair = false
        next
      end
        
      # backslash signifies the start of a quoted pair
      if ord == 92 and i < local.length - 1
        return false if not in_quoted_string # must be in quoted string per http://www.rfc-editor.org/errata_search.php?rfc=3696
        in_quoted_pair = true
        next
      end
        
      # double quote delimits quoted strings
      if ord == 34
        in_quoted_string = !in_quoted_string
        next
      end    

      next if local[i,1] =~ /[a-z0-9]/i
      next if local[i,1] =~ LocalPartSpecialChars
      
      # period must be followed by something
      if ord == 46
        return false if i == 0 or i == local.length - 1 # can't be first or last char
        next unless local[i+1].ord == 46 # can't be followed by a period
      end

      return false
    end
    
    return false if in_quoted_string # unbalanced quotes

    return true
  end
  
  def self.validate_domain_part_syntax(domain)
    parts = domain.downcase.split('.', -1)
    
    return false if parts.length <= 1 # Only one domain part

    # Empty parts (double period) or invalid chars
    return false if parts.any? { 
      |part| 
        part.nil? or 
        part.empty? or 
        not part =~ /\A[a-zA-Z0-9\-]+\Z/ or
        part[0,1] == '-' or part[-1,1] == '-' # hyphen at beginning or end of part
    } 
        
    # ipv4
    return true if parts.length == 4 and parts.all? { |part| part =~ /\A[0-9]+\Z/ and part.to_i.between?(0, 255) }
        
    return false if parts[-1].length < 2 or not parts[-1] =~ /[a-z\-]/ # TLD is too short or does not contain a char or hyphen
    
    return true
  end

  module Validations
    # Validates whether the value of the specified attribute is a valid email address
    #
    #   class User < ActiveRecord::Base
    #     validates_email_format_of :email, :on => :create
    #   end
    #
    # Configuration options:
    # * <tt>message</tt> - A custom error message (default is: "does not appear to be valid")
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
        errors = ValidatesEmailFormatOf::validate_email_format(value.to_s, options)
        errors.each do |error|
          record.errors.add(attr_name, error)
        end unless errors.nil?
      end
    end
  end
end

if defined?(ActiveModel)
  class EmailFormatValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      err = ValidatesEmailFormatOf::validate_email_format(value, options)
      unless err.nil?
        record.errors[attribute] << err
        record.errors[attribute].flatten!
      end
      #if record.errors.messages[attribute] == [] or record.errors.messages[attribute].nil?
      #  record.errors.delete(attribute)
      #end
    end
  end

  module ActiveModel::Validations::HelperMethods
    def validates_email_format_of(*attr_names)
      validates_with EmailFormatValidator, _merge_attributes(attr_names)
    end
  end
else
  if defined?(ActiveRecord)
    class ActiveRecord::Base
      extend ValidatesEmailFormatOf::Validations
    end
  end
end

