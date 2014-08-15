# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ValidatesEmailFormatOfTest < TEST_CASE
  def setup
    @valid_email = 'valid@example.com'
    @invalid_email = 'invalid@example.'
  end

  def test_without_activerecord
    assert_valid(@valid_email)
    assert_invalid(@invalid_email)
  end

  # from http://www.rfc-editor.org/errata_search.php?rfc=3696
  def test_should_allow_quoted_characters
    ['"Abc\@def"@example.com',
     '"Fred\ Bloggs"@example.com',
     '"Joe.\\Blow"@example.com',
     ].each do |email|
      assert_valid(email)
    end
  end

  def test_should_required_balanced_quoted_characters
    assert_valid(%!"example\\\\\\""@example.com!)
    assert_valid(%!"example\\\\"@example.com!)
    assert_invalid(%!"example\\\\""example.com!)
  end

  # from http://tools.ietf.org/html/rfc3696, page 5
  # corrected in http://www.rfc-editor.org/errata_search.php?rfc=3696
  def test_should_not_allow_escaped_characters_without_quotes
    ['Fred\ Bloggs_@example.com',
     'Abc\@def+@example.com',
     'Joe.\\Blow@example.com'
     ].each do |email|
      assert_invalid(email)
    end
  end

  def test_validating_with_custom_regexp
    assert_nil ValidatesEmailFormatOf::validate_email_format('012345@789', :with => /[0-9]+\@[0-9]+/)
  end

  def test_should_allow_custom_error_message
    p = create_person(:email => @invalid_email)
    save_fails(p)
    assert_equal 'fails with custom message', p.errors[:email].first
  end

  def test_should_allow_nil
    p = create_person(:email => nil)
    save_passes(p)

    p = PersonForbidNil.new(:email => nil)
    save_fails(p)
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

  def test_frozen_string
    assert_valid("  #{@valid_email}  ".freeze)
    assert_invalid("  #{@invalid_email}  ".freeze)
  end

  protected
    def create_person(params)
      ::Person.new(params)
    end

    def assert_valid(email)
      assert_nil ValidatesEmailFormatOf::validate_email_format(email), "#{email} should be considered valid"
    end

    def assert_invalid(email)
      assert_not_nil ValidatesEmailFormatOf::validate_email_format(email), "#{email} should not be considered valid"
    end

    def save_passes(p)
      assert p.valid?, " #{p.email} should pass"
      assert p.errors[:email].empty? && !p.errors.include?(:email)
    end

    def save_fails(p)
      assert !p.valid?, " #{p.email} should fail"
      assert_equal 1, p.errors[:email].size
    end
end
