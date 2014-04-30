$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'bundler/setup'
require 'test/unit'
require 'active_record'
require 'active_record/fixtures'
require "validates_email_format_of"

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'plugin_test'])

load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")

if ActiveSupport.const_defined?(:TestCase)
  ActiveSupport::TestCase.send(:include, ActiveRecord::TestFixtures)
  TEST_CASE = ActiveSupport::TestCase
else
  TEST_CASE = Test::Unit::TestCase
end

TEST_CASE.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$:.unshift(TEST_CASE.fixture_path)

class TEST_CASE #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(TEST_CASE.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(TEST_CASE.fixture_path, table_names)
    end
  end

  self.use_transactional_fixtures = false

  self.use_instantiated_fixtures  = false
end


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
