# -*- encoding : utf-8 -*-
require "#{File.expand_path(File.dirname(__FILE__))}/spec_helper"
require "validates_email_format_of"

RSpec.configure do |config|
  config.before(:suite) do
    ValidatesEmailFormatOf.load_i18n_locales
    I18n.enforce_available_locales = false
  end
end

describe ValidatesEmailFormatOf do
  subject do |example|
    if defined?(ActiveModel)
      user = Class.new do
        def initialize(email)
          @email = email.freeze
        end
        attr_reader :email
        include ActiveModel::Validations
        validates_email_format_of :email, example.example_group_instance.options
      end
      example.example_group_instance.class::User = user
      user.new(example.example_group_instance.email).tap(&:valid?).errors.full_messages
    else
      ValidatesEmailFormatOf::validate_email_format(email.freeze, options)
    end
  end
  let(:options) { {} }
  let(:email) { |example| example.example_group.description }

  shared_examples_for :all_specs do
    [
      'valid@example.com',
      'Valid@test.example.com',
      'valid+valid123@test.example.com',
      'valid_valid123@test.example.com',
      'valid-valid+123@test.example.co.uk',
      'valid-valid+1.23@test.example.com.au',
      'valid@example.co.uk',
      'v@example.com',
      'valid@example.ca',
      'valid_@example.com',
      'valid123.456@example.org',
      'valid123.456@example.travel',
      'valid123.456@example.museum',
      'valid@example.mobi',
      'valid@example.info',
      'valid-@example.com',
      'fake@p-t.k12.ok.us',
      # allow single character domain parts
      'valid@mail.x.example.com',
      'valid@x.com',
      'valid@example.w-dash.sch.uk',
      # from RFC 3696, page 6
      'customer/department=shipping@example.com',
      '$A12345@example.com',
      '!def!xyz%abc@example.com',
      '_somename@example.com',
      # apostrophes
      "test'test@example.com",
      # international domain names
      'test@xn--bcher-kva.ch',
      'test@example.xn--0zwm56d',
      'test@192.192.192.1',
      # Allow quoted characters.  Valid according to http://www.rfc-editor.org/errata_search.php?rfc=3696
      '"Abc\@def"@example.com',
      '"Fred\ Bloggs"@example.com',
      '"Joe.\\Blow"@example.com',
      # Balanced quoted characters
      %!"example\\\\\\""@example.com!,
      %!"example\\\\"@example.com!
    ].each do |address|
      describe address do
        it { should_not have_errors_on_email }
      end
    end

    [
      'no_at_symbol',
      'invalid@example-com',
      # period can not start local part
        '.invalid@example.com',
      # period can not end local part
        'invalid.@example.com',
      # period can not appear twice consecutively in local part
        'invali..d@example.com',
      # should not allow underscores in domain names
      'invalid@ex_mple.com',
      'invalid@e..example.com',
      'invalid@p-t..example.com',
      'invalid@example.com.',
      'invalid@example.com_',
      'invalid@example.com-',
      'invalid-example.com',
      'invalid@example.b#r.com',
      'invalid@example.c',
      'invali d@example.com',
      # TLD can not be only numeric
      'invalid@example.123',
      # unclosed quote
      "\"a-17180061943-10618354-1993365053@example.com",
      # too many special chars used to cause the regexp to hang
      "-+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++@foo",
      'invalidexample.com',
      # should not allow special chars after a period in the domain
      'local@sub.)domain.com',
      'local@sub.#domain.com',
      # one at a time
      "foo@example.com\nexample@gmail.com",
      'invalid@example.',
      "\"foo\\\\\"\"@bar.com",
      "foo@mail.com\r\nfoo@mail.com",
      '@example.com',
      'foo@',
      'foo',
      'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email',
      # Escaped characters with quotes.  From http://tools.ietf.org/html/rfc3696, page 5.  Corrected in http://www.rfc-editor.org/errata_search.php?rfc=3696
      'Fred\ Bloggs_@example.com',
      'Abc\@def+@example.com',
      'Joe.\\Blow@example.com',
      # Unbalanced quoted characters
      %!"example\\\\""example.com!
    ].each do |address|
      describe address do
        it { should have_errors_on_email.because("does not appear to be a valid e-mail address") }
      end
    end

    describe do
      shared_examples_for :local_length_limit do |limit|
        describe "#{'a' * limit}@example.com" do
          it { should_not have_errors_on_email }
        end
        describe "#{'a' * (limit + 1)}@example.com" do
          it { should have_errors_on_email.because("does not appear to be a valid e-mail address") }
        end
      end
      describe "when using default" do
        it_should_behave_like :local_length_limit, 64
      end
      describe "when overriding defaults" do
        let(:options) { { :local_length => 20 } }
        it_should_behave_like :local_length_limit, 20
      end
    end
    describe do
      shared_examples_for :domain_length_limit do |limit|
        describe "user@#{'a' * (limit - 4)}.com" do
          it { should_not have_errors_on_email }
        end
        describe "user@#{'a' * (limit - 3)}.com" do
          it { should have_errors_on_email.because("does not appear to be a valid e-mail address") }
        end
      end
      describe "when using default" do
        it_should_behave_like :domain_length_limit, 255
      end
      describe "when overriding defaults" do
        let(:options) { { :domain_length => 100 } }
        it_should_behave_like :domain_length_limit, 100
      end
    end

    describe "custom error messages" do
      describe 'invalid@example.' do
        let(:options) { { :message => "just because I don't like you" } }
        it { should have_errors_on_email.because("just because I don't like you") }
      end
    end

    describe "mx record" do
      domain = "stubbed.com"
      email = "valid@#{domain}"
      describe "when testing" do
        let(:dns) { double(Resolv::DNS) }
        let(:mx_record) { [double] }
        let(:a_record) { [double] }
        before(:each) do
          allow(Resolv::DNS).to receive(:open).and_yield(dns)
          allow(dns).to receive(:getresources).with(domain, Resolv::DNS::Resource::IN::MX).once.and_return(mx_record)
          allow(dns).to receive(:getresources).with(domain, Resolv::DNS::Resource::IN::A).once.and_return(a_record)
        end
        let(:options) { { :check_mx => true } }
        describe "and only an mx record is found" do
          let(:a_record) { [] }
          describe email do
            it { should_not have_errors_on_email }
          end
        end
        describe "and only an a record is found" do
          let(:mx_record) { [] }
          describe email do
            it { should_not have_errors_on_email }
          end
        end
        describe "and both an mx record and an a record are found" do
          describe email do
            it { should_not have_errors_on_email }
          end
        end
        describe "and neither an mx record nor an a record is found" do
          let(:a_record) { [] }
          let(:mx_record) { [] }
          describe email do
            it { should have_errors_on_email.because("is not routable") }
          end
          describe "with a custom error message" do
            let(:options) { { :check_mx => true, :mx_message => "There ain't no such domain!" } }
            describe email do
              it { should have_errors_on_email.because("There ain't no such domain!") }
            end
          end
          describe "i18n" do
            before(:each) do
              allow(I18n.config).to receive(:locale).and_return(locale)
            end
            describe "present locale" do
              let(:locale) { :pl }
              describe email do
                it { should have_errors_on_email.because("jest nieosiągalny") }
              end
            end
            unless defined?(ActiveModel)
              describe email do
                let(:locale) { :ir }
                describe email do
                  it { should have_errors_on_email.because("is not routable") }
                end
              end
            end
          end
          unless defined?(ActiveModel)
            describe "without i18n" do
              before(:each) { hide_const("I18n") }
              describe email do
                it { should have_errors_on_email.because("is not routable") }
              end
            end
          end
        end
      end
      describe "when not testing" do
        before(:each) { allow(Resolv::DNS).to receive(:open).never }
        describe "by default" do
          describe email do
            it { should_not have_errors_on_email }
          end
        end
        describe "explicitly" do
          describe email do
            let(:options) { { :check_mx => false } }
            it { should_not have_errors_on_email }
          end
        end
      end
      describe "without mocks" do
        describe email do
          let(:options) { { :check_mx => true } }
          it { should_not have_errors_on_email }
        end
      end
    end

    describe "custom regex" do
      let(:options) { { :with => /[0-9]+\@[0-9]+/ } }
      describe '012345@789' do
        it { should_not have_errors_on_email }
      end
      describe 'valid@example.com' do
        it { should have_errors_on_email.because("does not appear to be a valid e-mail address") }
      end
    end

    describe "i18n" do
      before(:each) do
        allow(I18n.config).to receive(:locale).and_return(locale)
      end
      describe "present locale" do
        let(:locale) { :pl }
        describe "invalid@exmaple." do
          it { should have_errors_on_email.because("nieprawidłowy adres e-mail") }
        end
      end
      unless defined?(ActiveModel)
        describe "missing locale" do
          let(:locale) { :ir }
          describe "invalid@exmaple." do
            it { should have_errors_on_email.because("does not appear to be valid") }
          end
        end
      end
    end
    unless defined?(ActiveModel)
      describe "without i18n" do
        before(:each) { hide_const("I18n") }
        describe "invalid@exmaple." do
          it { should have_errors_on_email.because("does not appear to be valid") }
        end
      end
    end
  end
  it_should_behave_like :all_specs

  if defined?(ActiveModel)
    describe "shorthand ActiveModel validation" do
      subject do |example|
        user = Class.new do
          def initialize(email)
            @email = email.freeze
          end
          attr_reader :email
          include ActiveModel::Validations
          validates :email, :email_format => example.example_group_instance.options
        end
        example.example_group_instance.class::User = user
        user.new(example.example_group_instance.email).tap(&:valid?).errors.full_messages
      end

      it_should_behave_like :all_specs
    end
  end
end
