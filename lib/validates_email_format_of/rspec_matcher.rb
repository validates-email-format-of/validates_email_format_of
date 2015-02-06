require "validates_email_format_of"

RSpec::Matchers.define :validate_email_format_of do |attribute|
  match do
    actual = subject.is_a?(Class) ? subject.new : subject
    actual.send(:"#{attribute}=", "invalid@example.")
    expect(actual).to be_invalid
    @expected_message ||= ValidatesEmailFormatOf.default_message
    expect(actual.errors.messages[attribute.to_sym]).to include(@expected_message)
  end
  chain :with_message do |message|
    @expected_message = message
  end
end
