require "active_model"
require "active_support"

RSpec::Matchers.define :have_errors_on_email do
  match do |user|
    actual = user.errors.full_messages
    expect(user.errors.added?(:email, ValidatesEmailFormatOf::ERROR_MESSAGE_I18N_KEY))
    expect(actual).not_to be_nil, "#{actual} should not be nil"
    expect(actual).not_to be_empty, "#{actual} should not be empty"
    expect(actual.size).to eq(@reasons.size), "#{actual} should have #{@reasons.size} elements"
    @reasons.each do |reason|
      reason = "Email #{reason}"
      expect(actual).to include(reason), "#{actual} should contain #{reason}"
    end
  end
  chain :because do |reason|
    (@reasons ||= []) << reason
  end
  chain :and_because do |reason|
    (@reasons ||= []) << reason
  end
  match_when_negated do |user|
    expect(user.errors).to(be_empty)
  end
end
