require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../shoulda_macros/validates_email_format_of'

class User < ActiveRecord::Base
  validates_email_format_of :email, 
    :on        => :create, 
    :message   => 'fails with custom message', 
    :allow_nil => true
end

class ValidatesEmailFormatOfTest < Test::Unit::TestCase
  should_validate_email_format_of_klass(User, :email)
end
