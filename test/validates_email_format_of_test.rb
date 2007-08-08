require File.dirname(__FILE__) + '/test_helper'

class ValidatesEmailFormatOfTest < Test::Unit::TestCase
  fixtures :people

  def setup
    @valid_email = 'valid@example.com'
    @invalid_email = '_invalid@example.com'
  end
  
  def test_should_allow_valid_email_addresses
    ['valid@example.com',
     'valid@test.example.com',
     'valid+valid123@test.example.com',
     'valid_valid123@test.example.com',
     'valid-valid+123@test.example.co.uk',
     'valid-valid+1.23@test.example.com.au',
     'valid@example.co.uk',
     'v@example.com',
     'valid@example.ca',
     'valid123.456@example.org',
     'valid123.456@example.travel',
     'valid123.456@example.museum',
     'valid@example.mobi',
     'valid@example.info'].each do |email|
      p = create_person(:email => email)
      save_passes(p, email)
    end
  end

  def test_should_not_allow_invalid_email_addresses
    ['_invalid@example.com',
     'invalid@example-com',
     'invalid_@example.com',
     'invalid-@example.com',
     '.invalid@example.com',
     'invalid.@example.com',
     'invalid@example.com.',
     'invalid@example.com_',
     'invalid@example.com-',
     'invalid-example.com',
     'invalid@example.b#r.com',
     'invalid@example.c',
     'invali d@example.com',
     'invalidexample.com',
     'invalid@example.'].each do |email|
      p = create_person(:email => email)
      save_fails(p, email)
    end
  end
  
  def test_should_respect_validate_on_option
    p = create_person(:email => @valid_email)
    save_passes(p)
    
    assert p.update_attributes(:email => @invalid_email)
    assert_equal '_invalid@example.com', p.email
  end
  
  def test_should_allow_custom_error_message
    p = create_person(:email => @invalid_email)
    save_fails(p)
    assert_equal 'fails with custom message', p.errors.on(:email)
  end

  protected
    def create_person(params)
      Person.new(params)
    end

    def save_passes(p, email = '')
      assert p.valid?, " validating #{email}"
      assert p.save
      assert_nil p.errors.on(:email)
    end
    
    def save_fails(p, email = '')
      assert !p.valid?, " validating #{email}"
      assert !p.save
      assert p.errors.on(:email)
    end
end
