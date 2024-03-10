# validates_email_format_of

[![Build Status](https://github.com/validates-email-format-of/validates_email_format_of/actions/workflows/ci.yml/badge.svg)]( https://github.com/validates-email-format-of/validates_email_format_of/actions/workflows/ci.yml?query=branch%3Amaster)

A Ruby gem to validate email addresses against RFC 2822 and RFC 5322.

## Why this email validator?

This gem is the O.G. email validation gem for Rails.  It was started back in 2006.

Why use this validator?  Instead of trying to validate email addresses with one giant regular expression, this library parses addresses character by character.  This lets us handle weird cases like [nested comments](https://www.rfc-editor.org/rfc/rfc5322#appendix-A.5).  Gross but technically allowed.

In reality, most email validating scripts will get you where you need to go.  This library just aims to go all the way.

## Installation

Add the gem to your Gemfile with:

```sh
gem 'validates_email_format_of'
```

### Usage in a Rails app

```ruby
class Person < ActiveRecord::Base
  validates :email, :email_format => { :message => "is not looking good" }

  # OR

  validates_email_format_of :email, :message => "is not looking good"
end
```

You can use the included `rspec` matcher as well:

```ruby
require "validates_email_format_of/rspec_matcher"

describe Person do
  it { should validate_email_format_of(:email).with_message("is not looking good") }
end
```

### Usage without Rails

```ruby
# Optional, if you want error messages to be in your language
ValidatesEmailFormatOf::load_i18n_locales
I18n.locale = :pl

ValidatesEmailFormatOf::validate_email_format("example@mydomain.com") # => nil
ValidatesEmailFormatOf::validate_email_format("invalid@") # => ["does not appear to be a valid email address"]
```

## Options

| Option | Type | Description |
| --- | --- | --- |
| `:message` | String | A custom error message when the email format is invalid (default is: "does not appear to be a valid email address") |
| `:check_mx` | Boolean | Check domain for a valid MX record (default is false) |
| `:check_mx_timeout` | Integer | Timeout in seconds for checking MX records before a `ResolvTimeout` is raised (default is 3). |
| `:idn` | Boolean | Allowed internationalized domain names like `test@exämple.com` and `test@пример.рф`. Otherwise only domains that have already been converted to [Punycode](https://en.wikipedia.org/wiki/Punycode) are supported. (default is true) |
| `:mx_message` | String | A custom error message when the domain does not match a valid MX record (default is: "is not routable").  Ignored unless :check_mx option is true. |
| `:local_length` |Integer | Maximum number of characters allowed in the local part (everything before the '@') (default is 64) |
| `:domain_length` | Integer | Maximum number of characters allowed in the domain part (everything after the '@') (default is 255) |
| `:generate_message` | Boolean | Return the I18n key of the error message instead of the error message itself (default is false) |

The standard ActiveModel validation options (`:on`, `:if`, `:unless`, `:allow_nil`, `:allow_blank`, etc...) all work as well when using the gem as part of a Rails application.
## Testing

You can see our [current Ruby and Rails test matrix here](.github/workflows/ci.yml).

To execute the unit tests against [all the Rails versions we support run](gemfiles/) <tt>bundle exec appraisal rspec</tt> or run against an individual version with <tt>bundle exec appraisal rails-6.0 rspec</tt>.
## Contributing

If you think we're letting some rules about valid email formats slip through the cracks, don't just update the parser. Instead, add a failing test and demonstrate that the described email address should be treated differently.  A link to an appropriate RFC is the best way to do this. Then change the gem code to make the test pass.

```ruby
describe "i_think_this_is_not_a_v@lid_email_addre.ss" do
  # According to http://..., this email address IS NOT valid.
  it { should have_errors_on_email.because("does not appear to be valid") }
end

describe "i_think_this_is_a_v@lid_email_addre.ss" do
  # According to http://..., this email address IS valid.
  it { should_not have_errors_on_email }
end
```

Yes, our Rspec syntax is that simple!

## Homepage

* https://github.com/validates-email-format-of/validates_email_format_of

## Credits

Written by Alex Dunae (dunae.ca), 2006-22.

Many thanks to the plugin's recent contributors: https://github.com/alexdunae/validates_email_format_of/contributors

Thanks to Francis Hwang (http://fhwang.net/) at Diversion Media for creating the 1.1 update.

Thanks to Travis Sinnott for creating the 1.3 update.

Thanks to Denis Ahearn at Riverock Technologies (http://www.riverocktech.com/) for creating the 1.4 update.

Thanks to George Anderson (http://github.com/george) and 'history' (http://github.com/history) for creating the 1.4.1 update.

Thanks to Isaac Betesh (https://github.com/betesh) for converting tests to Rspec and refactoring for version 1.6.0.
