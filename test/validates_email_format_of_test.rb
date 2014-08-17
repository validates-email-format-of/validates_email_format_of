# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ValidatesEmailFormatOfTest < TEST_CASE
  def test_validating_with_custom_regexp
    assert_nil ValidatesEmailFormatOf::validate_email_format('012345@789', :with => /[0-9]+\@[0-9]+/)
  end

  def test_shorthand
    s = Shorthand.new(:email => 'invalid')
    assert s.invalid?
    assert_equal 2, s.errors[:email].size
    assert s.errors[:email].any? { |err| err =~ /fails with shorthand message/ }
  end
end
