# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ValidatesEmailFormatOfTest < TEST_CASE
  def setup
    @valid_email = 'valid@example.com'
    @invalid_email = 'invalid@example.'
  end

  def test_validating_with_custom_regexp
    assert_nil ValidatesEmailFormatOf::validate_email_format('012345@789', :with => /[0-9]+\@[0-9]+/)
  end

  def test_check_valid_mx
    pmx = MxRecord.new(:email => 'test@mx.example.com')
    save_passes(pmx)
  end

  def test_check_invalid_mx
    pmx = MxRecord.new(:email => 'test@nomx.example.com')
    save_fails(pmx)
  end

  def test_check_mx_fallback_to_a
    pmx = MxRecord.new(:email => 'test@a.example.com')
    save_passes(pmx)
  end

  def test_shorthand
    s = Shorthand.new(:email => 'invalid')
    assert s.invalid?
    assert_equal 2, s.errors[:email].size
    assert s.errors[:email].any? { |err| err =~ /fails with shorthand message/ }
  end

  protected
    def save_passes(p)
      assert p.valid?, " #{p.email} should pass"
      assert p.errors[:email].empty? && !p.errors.include?(:email)
    end

    def save_fails(p)
      assert !p.valid?, " #{p.email} should fail"
      assert_equal 1, p.errors[:email].size
    end
end
