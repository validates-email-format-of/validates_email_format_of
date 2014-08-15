require_relative "spec_helper"
require "validates_email_format_of"

describe ValidatesEmailFormatOf do
  before(:all) do
    described_class.load_i18n_locales
    I18n.enforce_available_locales = false
  end
  subject do |example|
    if defined?(ActiveModel)
      user = Class.new do
        def initialize(email)
          @email = email
        end
        attr_reader :email
        include ActiveModel::Validations
        validates_email_format_of :email, example.example_group_instance.options
      end
      example.example_group_instance.class::User = user
      user.new(example.example_group_instance.email).tap(&:valid?).errors.full_messages
    else
      ValidatesEmailFormatOf::validate_email_format(email, options)
    end
  end
  let(:options) { {} }
  let(:email) { |example| example.example_group.description }
  describe "no_at_symbol" do
    it { should have_errors_on_email.because("does not appear to be a valid e-mail address") }
  end
  describe "user1@gmail.com" do
    it { should_not have_errors_on_email }
  end
end
