require "validates_email_format_of/version"
require "simpleidn"

module ValidatesEmailFormatOf
  def self.load_i18n_locales
    require "i18n"
    I18n.load_path += Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "locales", "*.yml")))
  end

  require "resolv"

  # Characters that are allowed in to appear in the local part unquoted
  # https://www.rfc-editor.org/rfc/rfc5322#section-3.2.3
  #
  # An addr-spec is a specific Internet identifier that contains a
  # locally interpreted string followed by the at-sign character ("@",
  # ASCII value 64) followed by an Internet domain.  The locally
  # interpreted string is either a quoted-string or a dot-atom.  If the
  # string can be represented as a dot-atom (that is, it contains no
  # characters other than atext characters or "." surrounded by atext
  # characters), then the dot-atom form SHOULD be used and the quoted-
  # string form SHOULD NOT be used.  Comments and folding white space
  # SHOULD NOT be used around the "@" in the addr-spec.
  #
  #   atext           =   ALPHA / DIGIT /
  #                       "!" / "#" / "$" / "%" / "&" / "'" / "*" /
  #                       "+" / "-" / "/" / "=" / "?" / "^" / "_" /
  #                       "`" / "{" / "|" / "}" / "~"
  #   dot-atom-text   =   1*atext *("." 1*atext)
  #   dot-atom        =   [CFWS] dot-atom-text [CFWS]
  ATEXT = /\A[A-Z0-9!\#$%&'*\-\/=?+\^_`{|}~]\z/i

  # Characters that are allowed to appear unquoted in comments
  # https://www.rfc-editor.org/rfc/rfc5322#section-3.2.2
  #
  # ctext           =   %d33-39 / %d42-91 / %d93-126
  # ccontent        =   ctext / quoted-pair / comment
  # comment         =   "(" *([FWS] ccontent) [FWS] ")"
  # CFWS            =   (1*([FWS] comment) [FWS]) / FWS
  CTEXT = /\A[#{Regexp.escape([33..39, 42..91, 93..126].map { |ascii_range| ascii_range.map(&:chr) }.flatten.join)}\s]/i

  # https://www.rfc-editor.org/rfc/rfc5322#section-3.2.4
  #
  # Strings of characters that include characters other than those
  # allowed in atoms can be represented in a quoted string format, where
  # the characters are surrounded by quote (DQUOTE, ASCII value 34)
  # characters.
  #
  # qtext           =   %d33 /             ; Printable US-ASCII
  #                     %d35-91 /          ;  characters not including
  #                     %d93-126 /         ;  "\" or the quote character
  #                     obs-qtext
  #
  # qcontent        =   qtext / quoted-pair
  # quoted-string   =   [CFWS]
  #                     DQUOTE *([FWS] qcontent) [FWS] DQUOTE
  #                     [CFWS]
  QTEXT = /\A[#{Regexp.escape([33..33, 35..91, 93..126].map { |ascii_range| ascii_range.map(&:chr) }.flatten.join)}\s]/i

  IP_OCTET = /\A[0-9]+\Z/

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
  #
  # Additionally, from https://datatracker.ietf.org/doc/html/rfc1123#section-2.1
  #
  # > One aspect of host name syntax is hereby changed: the
  # > restriction on the first character is relaxed to allow either a
  # > letter or a digit.  Host software MUST support this more liberal
  # > syntax.
  DOMAIN_PART_LABEL = /\A[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]?\Z/

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
  DOMAIN_PART_TLD = /\A[A-Za-z][A-Za-z0-9-]*[A-Za-z0-9]\Z/

  def self.validate_email_domain(email, idn: true, check_mx_timeout: 3)
    domain = email.to_s.downcase.match(/@(.+)/)[1]
    domain = SimpleIDN.to_ascii(domain) if idn

    Resolv::DNS.open do |dns|
      dns.timeouts = check_mx_timeout
      @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX) + dns.getresources(domain, Resolv::DNS::Resource::IN::A)
    end
    @mx.size > 0
  end

  DEFAULT_MESSAGE = "does not appear to be valid"
  DEFAULT_MX_MESSAGE = "is not routable"
  ERROR_MESSAGE_I18N_KEY = :invalid_email_address
  ERROR_MX_MESSAGE_I18N_KEY = :email_address_not_routable

  def self.default_message
    defined?(I18n) ? I18n.t(ERROR_MESSAGE_I18N_KEY, scope: [:activemodel, :errors, :messages], default: DEFAULT_MESSAGE) : DEFAULT_MESSAGE
  end

  # Validates whether the specified value is a valid email address.  Returns nil if the value is valid, otherwise returns an array
  # containing one or more validation error messages.
  #
  # Configuration options:
  # * <tt>message</tt> - A custom error message (default is: "does not appear to be valid")
  # * <tt>check_mx</tt> - Check for MX records (default is false)
  # * <tt>check_mx_timeout</tt> - Timeout in seconds for checking MX records before a `ResolvTimeout` is raised (default is 3)
  # * <tt>idn</tt> - Enable or disable Internationalized Domain Names (default is true)
  # * <tt>mx_message</tt> - A custom error message when an MX record validation fails (default is: "is not routable.")
  # * <tt>local_length</tt> Maximum number of characters allowed in the local part (default is 64)
  # * <tt>domain_length</tt> Maximum number of characters allowed in the domain part (default is 255)
  # * <tt>generate_message</tt> Return the I18n key of the error message instead of the error message itself (default is false)
  def self.validate_email_format(email, options = {})
    default_options = {message: options[:generate_message] ? ERROR_MESSAGE_I18N_KEY : default_message,
                       check_mx: false,
                       check_mx_timeout: 3,
                       idn: true,
                       mx_message: if options[:generate_message]
                                     ERROR_MX_MESSAGE_I18N_KEY
                                   else
                                     (defined?(I18n) ? I18n.t(ERROR_MX_MESSAGE_I18N_KEY, scope: [:activemodel, :errors, :messages], default: DEFAULT_MX_MESSAGE) : DEFAULT_MX_MESSAGE)
                                   end,
                       domain_length: 255,
                       local_length: 64,
                       generate_message: false}
    opts = options.merge(default_options) { |key, old, new| old } # merge the default options into the specified options, retaining all specified options

    begin
      domain, local = email.reverse.split("@", 2)
    rescue
      return [opts[:message]]
    end

    # need local and domain parts
    return [opts[:message]] unless local && !local.empty? && domain && !domain.empty?

    # check lengths
    return [opts[:message]] unless domain.length <= opts[:domain_length] && local.length <= opts[:local_length]

    local.reverse!
    domain.reverse!

    if opts.has_key?(:with) # holdover from versions <= 1.4.7
      deprecation_warn(":with option is deprecated and will be removed in the next version")
      return [opts[:message]] unless email&.match?(opts[:with])
    else
      return [opts[:message]] unless validate_local_part_syntax(local) && validate_domain_part_syntax(domain, idn: opts[:idn])
    end

    if opts[:check_mx] && !validate_email_domain(email, check_mx_timeout: opts[:check_mx_timeout], idn: opts[:idn])
      return [opts[:mx_message]]
    end

    nil # represents no validation errors
  end

  def self.validate_local_part_syntax(local)
    in_quoted_pair = false
    in_quoted_string = false
    comment_depth = 0

    # The local part is made up of dot-atom and quoted-string joined together by "." characters
    #
    # https://www.rfc-editor.org/rfc/rfc5322#section-3.4.1
    # > local-part      =   dot-atom / quoted-string / obs-local-part
    #
    # https://www.rfc-editor.org/rfc/rfc5322#section-3.2.3
    # Both atom and dot-atom are interpreted as a single unit, comprising
    # > the string of characters that make it up.  Semantically, the optional
    # > comments and FWS surrounding the rest of the characters are not part
    # > of the atom; the atom is only the run of atext characters in an atom,
    # > or the atext and "." characters in a dot-atom.
    joining_atoms = true

    (0..local.length - 1).each do |i|
      ord = local[i].ord

      # accept anything if it's got a backslash before it
      if in_quoted_pair
        in_quoted_pair = false
        next
      end

      # double quote delimits quoted strings
      if ord == 34
        if in_quoted_string # leaving the quoted string
          in_quoted_string = false
          next
        elsif joining_atoms # are we allowed to enter a quoted string?
          in_quoted_string = true
          joining_atoms = false
          next
        else
          return false
        end
      end

      # period indicates we want to join atoms, e.g. `aaa.bbb."ccc"@example.com
      if ord == 46
        return false if i.zero?
        return false if joining_atoms
        joining_atoms = true
        next
      end

      joining_atoms = false

      # quoted string logic must come before comment processing since a quoted string
      # may contain parens, e.g. `"name(a)"@example.com`
      if in_quoted_string
        next if QTEXT.match?(local[i])
      end

      # opening paren to show we are going into a comment (CFWS)
      if ord == 40
        comment_depth += 1
        next
      end

      # closing paren
      if ord == 41
        comment_depth -= 1
        return false if comment_depth < 0
        next
      end

      # backslash signifies the start of a quoted pair
      if ord == 92
        # https://www.rfc-editor.org/rfc/rfc5322#section-3.2.1
        # > The only places in this specification where quoted-pair currently appears are
        # > ccontent, qcontent, and in obs-dtext in section 4.
        return false unless in_quoted_string || comment_depth > 0
        in_quoted_pair = true
        next
      end

      if comment_depth > 0
        next if CTEXT.match?(local[i])
      elsif ATEXT.match?(local[i, 1])
        next
      end

      return false
    end

    return false if in_quoted_pair # unbalanced quoted pair
    return false if in_quoted_string # unbalanced quotes
    return false unless comment_depth.zero? # unbalanced comment parens
    return false if joining_atoms # the last char we encountered was a period

    true
  end

  def self.validate_domain_part_syntax(domain, idn: true)
    parts = domain.downcase.split(".", -1)
    parts.map! { |part| SimpleIDN.to_ascii(part) } if idn

    return false if parts.length <= 1 # Only one domain part

    # ipv4
    return true if parts.length == 4 && parts.all? { |part| part =~ IP_OCTET && part.to_i.between?(0, 255) }

    # From https://datatracker.ietf.org/doc/html/rfc3696#section-2 this is the recommended, pragmatic way to validate a domain name:
    #
    # > It is likely that the better strategy has now become to make the "at least one period" test,
    # > to verify LDH conformance (including verification that the apparent TLD name is not all-numeric),
    # > and then to use the DNS to determine domain name validity, rather than trying to maintain
    # > a local list of valid TLD names.
    #
    # We do a little bit more but not too much and validate the tokens but do not check against a list of valid TLDs.
    parts.each do |part|
      return false if part.nil? || part.empty?
      return false if part.length > 63
      return false unless DOMAIN_PART_LABEL.match?(part)
    end

    return false unless DOMAIN_PART_TLD.match?(parts[-1])
    true
  end

  def self.deprecation_warn(msg)
    if defined?(ActiveSupport::Deprecation)
      deprecator.warn(msg)
    else
      warn(msg)
    end
  end

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("2.0", "validates_email_format_of")
  end
end

require "validates_email_format_of/active_model" if defined?(::ActiveModel) && !(ActiveModel::VERSION::MAJOR < 2 || (ActiveModel::VERSION::MAJOR == 2 && ActiveModel::VERSION::MINOR < 1))
require "validates_email_format_of/railtie" if defined?(::Rails::Railtie)
