# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ValidatesEmailFormatOfTest < TEST_CASE
  fixtures :people

  def setup
    @valid_email = 'valid@example.com'
    @invalid_email = 'invalid@example.'
  end

  def test_with_activerecord
    p = create_person(:email => @valid_email)
    save_passes(p)

    p = create_person(:email => @invalid_email)
    save_fails(p)
  end

  def test_without_activerecord
    assert_valid(@valid_email)
    assert_invalid(@invalid_email)
  end

  def test_should_allow_valid_email_addresses
    ['valid@example.com',
     'Valid@test.example.com',
     'valid+valid123@test.example.com',
     'valid_valid123@test.example.com',
     'valid-valid+123@test.example.co.uk',
     'valid-valid+1.23@test.example.com.au',
     'valid@example.co.uk',
     'v@example.com',
     'valid@example.ca',
     'valid_@example.com',
     'valid123.456@example.org',
     'valid123.456@example.travel',
     'valid123.456@example.museum',
     'valid@example.mobi',
     'valid@example.info',
     'valid-@example.com',
     'fake@p-t.k12.ok.us',
  # allow single character domain parts
     'valid@mail.x.example.com',
     'valid@x.com',
     'valid@example.w-dash.sch.uk',
  # from RFC 3696, page 6
     'customer/department=shipping@example.com',
     '$A12345@example.com',
     '!def!xyz%abc@example.com',
     '_somename@example.com',
  # apostrophes
     "test'test@example.com",
  # international domain names
     'test@xn--bcher-kva.ch',
     'test@example.xn--0zwm56d',
     'test@192.192.192.1'
     ].each do |email|
      assert_valid(email)
    end
  end

  def test_should_not_allow_invalid_email_addresses
    ['invalid@example-com',
  # period can not start local part
     '.invalid@example.com',
  # period can not end local part
     'invalid.@example.com', 
  # period can not appear twice consecutively in local part
     'invali..d@example.com',
  # should not allow underscores in domain names
    'invalid@ex_mple.com',
    'invalid@e..example.com',
    'invalid@p-t..example.com',
    'invalid@example.com.',
    'invalid@example.com_',
    'invalid@example.com-',
    'invalid-example.com',
    'invalid@example.b#r.com',
    'invalid@example.c',
    'invali d@example.com',
  # TLD can not be only numeric
    'invalid@example.123',
  # unclosed quote
     "\"a-17180061943-10618354-1993365053@example.com",
  # too many special chars used to cause the regexp to hang
     "-+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++@foo",
     'invalidexample.com',
  # should not allow special chars after a period in the domain
     'local@sub.)domain.com',
     'local@sub.#domain.com',
  # one at a time
     "foo@example.com\nexample@gmail.com",
     'invalid@example.',
     "\"foo\\\\\"\"@bar.com",
     "foo@mail.com\r\nfoo@mail.com",
     '@example.com',
     'foo@',
     'foo',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email',
     'foo@Iñtërnâtiônàlizætiøn.example.com'
     ].each do |email|
      assert_invalid(email)
    end
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

  def test_should_check_length_limits
    ['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@example.com',
     'test@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com'
     ].each do |email|
      assert_invalid(email)
    end
  end

  def test_overriding_length_checks
    assert_not_nil ValidatesEmailFormatOf::validate_email_format('valid@example.com', :local_length => 1)
    assert_not_nil ValidatesEmailFormatOf::validate_email_format('valid@example.com', :domain_length => 1)
  end

  def test_validating_with_custom_regexp
    assert_nil ValidatesEmailFormatOf::validate_email_format('012345@789', :with => /[0-9]+\@[0-9]+/)
  end

  def test_should_respect_validate_on_option
    p = create_person(:email => @valid_email)
    save_passes(p)

    # we only asked to validate on :create so this should fail
    assert p.update_attributes(:email => @invalid_email)
    assert_equal @invalid_email, p.email
  end

  def test_should_allow_custom_error_message
    p = create_person(:email => @invalid_email)
    save_fails(p)
    if ActiveRecord::VERSION::MAJOR >= 3
      assert_equal 'fails with custom message', p.errors[:email].first
    else
      assert_equal 'fails with custom message', p.errors.on(:email)
    end
  end

  def test_should_allow_nil
    p = create_person(:email => nil)
    save_passes(p)

    p = PersonForbidNil.new(:email => nil)
    save_fails(p)
  end

  # TODO: find a future-proof way to check DNS records
  def test_check_mx
    pmx = MxRecord.new(:email => 'test@dunae.ca')
    save_passes(pmx)

    pmx = MxRecord.new(:email => 'test@127.0.0.2')
    save_fails(pmx)
  end

  # TODO: find a future-proof way to check DNS records
  def test_check_mx_fallback_to_a
    pmx = MxRecord.new(:email => 'test@code.dunae.ca')
    save_passes(pmx)
  end

  def test_shorthand
    if ActiveRecord::VERSION::MAJOR >= 3
      s = Shorthand.new(:email => 'invalid')
      assert !s.save
      assert_equal 2, s.errors[:email].size
      assert_block do
        s.errors[:email].any? do |err|
        err =~ /fails with shorthand message/
      end
      end
    end
  end

  def test_frozen_string
    assert_valid("  #{@valid_email}  ".freeze)
    assert_invalid("  #{@invalid_email}  ".freeze)
  end

  protected
    def create_person(params)
      Person.new(params)
    end

    def assert_valid(email)
      assert_nil ValidatesEmailFormatOf::validate_email_format(email), "#{email} should be considered valid"
    end

    def assert_invalid(email)
      assert_not_nil ValidatesEmailFormatOf::validate_email_format(email), "#{email} should not be considered valid"
    end

    def save_passes(p, email = '')
      assert p.valid?, " #{email} should pass"
      assert p.save
      if ActiveRecord::VERSION::MAJOR >= 3
        assert p.errors[:email].empty? && !p.errors.include?(:email)
      else
        assert_nil p.errors.on(:email)
      end
    end

    def save_fails(p, email = '')
      assert !p.valid?, " #{email} should fail"
      assert !p.save
      if ActiveRecord::VERSION::MAJOR >= 3
        assert_equal 1, p.errors[:email].size
      else
        assert p.errors.on(:email)
      end
    end
end
