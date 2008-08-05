$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'active_record'

require 'validates_email_format_of'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:')

ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.column 'email', :string
  end
end

class Person < ActiveRecord::Base
  validates_email_format_of :email, :on => :create, :message => 'fails with custom message', :allow_nil => true
end

# Set up Feedback testing framework, a la carte

require 'test/unit'
require 'shoulda'
require "#{File.dirname(__FILE__)}/../init"

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
  
  def self.get_options!(args, *wanted)
    ret  = []
    opts = (args.last.is_a?(Hash) ? args.pop : {})
    wanted.each {|w| ret << opts.delete(w)}
    raise ArgumentError, "Unsuported options given: #{opts.keys.join(', ')}" unless opts.keys.empty?
    return *ret
  end
  
end
