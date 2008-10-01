require File.dirname(__FILE__) + '/test_helper'

class User < ActiveRecord::Base
  validates_email_format_of :email, 
    :on        => :create, 
    :message   => 'fails with custom message', 
    :allow_nil => true
end

class ValidatesEmailFormatOfTest < Test::Unit::TestCase

  context 'Typical valid email' do
    should_allow_values  
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
       'valid-@example.com']                 
  end
  
  context 'valid email from RFC 3696, page 6' do
    should_allow_values 
      ['customer/department=shipping@example.com',
       '$A12345@example.com',
       '!def!xyz%abc@example.com',
       '_somename@example.com']
  end
  
  context 'valid email with apostrophe' do
    should_allow_values "test'test@example.com"
  end
  
  context 'valid email from http://www.rfc-editor.org/errata_search.php?rfc=3696' do
    should_allow_values
      ['"Abc\@def"@example.com',     
       '"Fred\ Bloggs"@example.com',
       '"Joe.\\Blow"@example.com']
  end
  
  context 'Typical invalid email' do
    should_not_allow_values
      ['invalid@example-com',
       'invalid@example.com.',
       'invalid@example.com_',
       'invalid@example.com-',
       'invalid-example.com',
       'invalid@example.b#r.com',
       'invalid@example.c',
       'invali d@example.com',
       'invalidexample.com',
       'invalid@example.']
  end
  
  context 'invalid email with period starting local part' do
    should_not_allow_values '.invalid@example.com'
  end
  
  context 'invalid email with period ending local part' do
    should_not_allow_values 'invalid.@example.com'
  end
  
  context 'invalid email with consecutive periods' do
    should_not_allow_values 'invali..d@example.com'
  end
  
  # corrected in http://www.rfc-editor.org/errata_search.php?rfc=3696
  context 'invalid email from http://tools.ietf.org/html/rfc3696, page 5' do
    should_not_allow_values 
      ['Fred\ Bloggs_@example.com',
       'Abc\@def+@example.com',
       'Joe.\\Blow@example.com']
  end

  context 'invalid email exceeding length limits' do
    should_not_allow_values
      ['aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@example.com',
       'test@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com']
  end
  
  context 'An invalid user on update' do
    setup do
      @user = User.new(:email => 'dcroak@thoughtbot.com')
      @user.save
      @user.update_attribute :email, '..dcroak@thoughtbot.com'
    end
      
    should 'pass validation' do
      assert @user.valid?
      assert @user.save
      assert_nil @user.errors.on(:email)
    end
  end
  
  context 'A user with a nil email' do
    setup { @user = User.new(:email => nil) }
    
    should 'pass validation' do
      assert @user.valid?
      assert @user.save
      assert_nil @user.errors.on(:email)
    end
  end

end
