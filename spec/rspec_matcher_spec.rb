require "#{__dir__}/spec_helper"
require "validates_email_format_of/rspec_matcher"

class Person
  attr_accessor :email_address
  include ::ActiveModel::Validations
  validates_email_format_of :email_address
end

describe Person do
  it { should validate_email_format_of(:email_address) }
end
