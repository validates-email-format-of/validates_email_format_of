RSpec.shared_examples 'check_mx tests on' do |email|
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
