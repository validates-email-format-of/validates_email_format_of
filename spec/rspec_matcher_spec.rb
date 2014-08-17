require "#{File.expand_path(File.dirname(__FILE__))}/spec_helper"
if defined?(ActiveModel)
  require "validates_email_format_of/rspec_matcher"

  class Person
    attr_accessor :email_address
    include ::ActiveModel::Validations
    validates_email_format_of :email_address
  end

  describe Person do
    it { should validate_email_format_of(:email_address) }
  end
end
