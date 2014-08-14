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

class Resolv::DNS
  # Stub for MX record checks.
  #
  # If subdomain equals either 'mx' or 'a' returns that kind of record
  # otherwise returns no match.
  def getresources(name, typeclass)
    stub = name.split('.').first
    case stub
    when 'mx'
      [Resolv::DNS::Resource::IN::MX.new(10, '127.0.0.1')]
    when 'a'
      [Resolv::DNS::Resource::IN::A.new('127.0.0.1')]
    else
      []
    end
  end
end
