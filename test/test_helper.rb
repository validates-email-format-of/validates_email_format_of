$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'bundler/setup'
require 'minitest/autorun'

require 'active_model'
require "validates_email_format_of"

if ActiveSupport.const_defined?(:TestCase)
  TEST_CASE = ActiveSupport::TestCase
else
  TEST_CASE = Test::Unit::TestCase
end

Dir.glob("#{File.dirname(__FILE__)}/fixtures/*.rb") { |f| require f }
