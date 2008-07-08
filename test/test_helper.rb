$:.unshift(File.dirname(__FILE__) + '/../lib')
RAILS_ROOT = File.dirname(__FILE__)

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'email_format_test'])

class Test::Unit::TestCase #:nodoc:
  
  def self.should_allow_values(*good_values)
    get_options!(good_values)
    good_values.each do |v|
      should "allow email to be set to #{v.inspect}" do
        user = User.new(:email => v)
        user.save
        assert_nil user.errors.on(:email)
      end
    end
  end

  def self.should_not_allow_values(*bad_values)
    message = get_options!(bad_values, :message)
    message ||= /invalid/
    bad_values.each do |v|
      should "not allow email to be set to #{v.inspect}" do
        user = User.new(:email => v)
        assert !user.save, "Saved user with email set to \"#{v}\""
        assert user.errors.on(:email), "There are no errors set on email after being set to \"#{v}\""
      end
    end
  end
  
  def self.should_pass_validation(user)
    should 'pass validation' do
      assert user.valid?
      assert user.save
      assert_nil user.errors.on(:email)
    end
  end
  
  def self.should_fail_validation(user)
    should 'fail validation' do
      assert !user.valid?
      assert !user.save
      assert user.errors.on(:email)
      assert_equal 'fails with custom message', user.errors.on(:email)
    end
  end
  
  def self.get_options!(args, *wanted)
    ret  = []
    opts = (args.last.is_a?(Hash) ? args.pop : {})
    wanted.each {|w| ret << opts.delete(w)}
    raise ArgumentError, "Unsuported options given: #{opts.keys.join(', ')}" unless opts.keys.empty?
    return *ret
  end
  
end
