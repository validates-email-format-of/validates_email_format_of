require "validates_email_format_of"

RSpec::Matchers.define :validate_email_format_of do |attribute|
  match do
    actual = subject.is_a?(Class) ? subject.new : subject
    actual.send(:"#{attribute}=", "invalid@example.")
    @expected_message ||= ValidatesEmailFormatOf.default_message
    !actual.valid? && actual.errors.messages[attribute.to_sym].include?(@expected_message)
  end
  chain :with_message do |message|
    @expected_message = message
  end
end
