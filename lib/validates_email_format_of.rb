# encoding: utf-8
require 'validates_email_format_of/version'

module ValidatesEmailFormatOf
  def self.load_i18n_locales
    require 'i18n'
    I18n.load_path += Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.yml')))
  end

  require 'resolv'

  LocalPartSpecialChars = /[\!\#\$\%\&\'\*\-\/\=\?\+\^\_\`\{\|\}\~]/.freeze

  # From https://datatracker.ietf.org/doc/html/rfc1035#section-2.3.1
  #
  # > The labels must follow the rules for ARPANET host names.  They must
  # > start with a letter, end with a letter or digit, and have as interior
  # > characters only letters, digits, and hyphen.  There are also some
  # > restrictions on the length.  Labels must be 63 characters or less.
  #
  # <label> | <subdomain> "." <label>
  # <label> ::= <letter> [ [ <ldh-str> ] <let-dig> ]
  # <ldh-str> ::= <let-dig-hyp> | <let-dig-hyp> <ldh-str>
  # <let-dig-hyp> ::= <let-dig> | "-"
  # <let-dig> ::= <letter> | <digit>
  DomainPartLabel =  /\A[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9]?\Z/.freeze

  IPAddressPart = /\A[0-9]+\Z/.freeze

  # From https://tools.ietf.org/id/draft-liman-tld-names-00.html#rfc.section.2
  #
  # > A TLD label MUST be at least two characters long and MAY be as long as 63 characters -
  # > not counting any leading or trailing periods (.). It MUST consist of only ASCII characters
  # > from the groups "letters" (A-Z), "digits" (0-9) and "hyphen" (-), and it MUST start with an
  # > ASCII "letter", and it MUST NOT end with a "hyphen". Upper and lower case MAY be mixed at random,
  # > since DNS lookups are case-insensitive.
  #
  # tldlabel = ALPHA *61(ldh) ld
  # ldh      = ld / "-"
  # ld       = ALPHA / DIGIT
  # ALPHA    = %x41-5A / %x61-7A   ; A-Z / a-z
  # DIGIT    = %x30-39             ; 0-9
  DomainPartTLD = /\A[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9]\Z/.freeze

  def self.validate_email_domain(email, check_mx_timeout: 3)
    domain = email.to_s.downcase.match(/\@(.+)/)[1]
    Resolv::DNS.open do |dns|
      dns.timeouts = check_mx_timeout
      @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX) + dns.getresources(domain, Resolv::DNS::Resource::IN::A)
    end
    @mx.size > 0 ? true : false
  end

  DEFAULT_MESSAGE = "does not appear to be valid"
  DEFAULT_MX_MESSAGE = "is not routable"
  ERROR_MESSAGE_I18N_KEY = :invalid_email_address
  ERROR_MX_MESSAGE_I18N_KEY = :email_address_not_routable

  def self.default_message
    defined?(I18n) ? I18n.t(ERROR_MESSAGE_I18N_KEY, :scope => [:activemodel, :errors, :messages], :default => DEFAULT_MESSAGE) : DEFAULT_MESSAGE
  end

  # Validates whether the specified value is a valid email address.  Returns nil if the value is valid, otherwise returns an array
  # containing one or more validation error messages.
  #
  # Configuration options:
  # * <tt>message</tt> - A custom error message (default is: "does not appear to be valid")
  # * <tt>check_mx</tt> - Check for MX records (default is false)
  # * <tt>check_mx_timeout</tt> - Timeout in seconds for checking MX records before a `ResolvTimeout` is raised (default is 3)
  # * <tt>mx_message</tt> - A custom error message when an MX record validation fails (default is: "is not routable.")
  # * <tt>with</tt> The regex to use for validating the format of the email address (deprecated)
  # * <tt>local_length</tt> Maximum number of characters allowed in the local part (default is 64)
  # * <tt>domain_length</tt> Maximum number of characters allowed in the domain part (default is 255)
  # * <tt>generate_message</tt> Return the I18n key of the error message instead of the error message itself (default is false)
  def self.validate_email_format(email, options={})
      default_options = { :message => options[:generate_message] ? ERROR_MESSAGE_I18N_KEY : default_message,
                          :check_mx => false,
                          :check_mx_timeout => 3,
                          :mx_message => options[:generate_message] ? ERROR_MX_MESSAGE_I18N_KEY : (defined?(I18n) ? I18n.t(ERROR_MX_MESSAGE_I18N_KEY, :scope => [:activemodel, :errors, :messages], :default => DEFAULT_MX_MESSAGE) : DEFAULT_MX_MESSAGE),
                          :domain_length => 255,
                          :local_length => 64,
                          :generate_message => false
                          }
      opts = options.merge(default_options) {|key, old, new| old}  # merge the default options into the specified options, retaining all specified options

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

      if opts[:check_mx] and !self.validate_email_domain(email, check_mx_timeout: opts[:check_mx_timeout])
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

    # ipv4
    return true if parts.length == 4 && parts.all? { |part| part =~ IPAddressPart && part.to_i.between?(0, 255) }

    # From https://datatracker.ietf.org/doc/html/rfc3696#section-2 this is the recommended, pragmatic way to validate a domain name:
    #
    # > It is likely that the better strategy has now become to make the "at least one period" test,
    # > to verify LDH conformance (including verification that the apparent TLD name is not all-numeric),
    # > and then to use the DNS to determine domain name validity, rather than trying to maintain
    # > a local list of valid TLD names.
    #
    # We do a little bit more but not too much and validate the tokens but do not check against a list of valid TLDs.
    parts.each do |part|
      return false if part.blank?
      return false if part.length > 63
      return false unless part =~ DomainPartLabel
    end

    return false unless parts[-1] =~ DomainPartTLD
    return true
  end
end

require 'validates_email_format_of/active_model' if defined?(::ActiveModel) && !(ActiveModel::VERSION::MAJOR < 2 || (2 == ActiveModel::VERSION::MAJOR && ActiveModel::VERSION::MINOR < 1))
require 'validates_email_format_of/railtie' if defined?(::Rails::Railtie)
