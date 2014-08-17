# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ValidatesEmailFormatOfTest < TEST_CASE
  def test_validating_with_custom_regexp
    assert_nil ValidatesEmailFormatOf::validate_email_format('012345@789', :with => /[0-9]+\@[0-9]+/)
  end
end
