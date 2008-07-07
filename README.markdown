Validates email format
======================

Validate various formats of email address against RFC 2822.

Usage
-----

    class Person < ActiveRecord::Base
      validates_email_format_of :email
    end

Options
-------

<dl>
	<dt>:message</dt>
    <dd>String. A custom error message (default is: " does not appear to be a valid e-mail address")
  <dt>:on</dt>
    <dd>Symbol. Specifies when this validation is active (default is :save, other options :create, :update)</dd>
  <dt>:allow_nil</dt>
    <dd>Boolean. Allow nil values (default is false)</dd>
  <dt>:allow_blank</dt>
    <dd>Boolean. Allow blank values (default is false)</dd>
  <dt>:if</dt>
    <dd>Specifies a method, proc or string to call to determine if the validation should occur (e.g. :if => :allow_validation, or :if => Proc.new { |user| user.signup_step > 2 }). The method, proc or string should return or evaluate to a true or false value.</dd>
  <dt>:unless</dt>
    <dd>See :if option.</dd>
</dl>

Testing
-------

To execute the unit tests run <tt>rake test</tt>.

The unit tests for this plugin use an in-memory sqlite3 database.

Installing the gem
------------------

* gem sources -a http://gems.github.com (only needed once)
* sudo gem install dancroak-validates\_email\_format\_of

Credits
-------

Written by Alex Dunae (dunae.ca), 2006-07.

Thanks to Francis Hwang (http://fhwang.net/) at Diversion Media for creating the 1.1 update.
