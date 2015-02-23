RSpec.shared_examples 'email domain tests' do
  context 'with an MX and A record' do
    it { is_expected.to be_truthy }
  end

  context 'without an MX or A record' do
    let(:a_record) { [] }
    let(:mx_record) { [] }

    it { is_expected.to be_falsey }
  end

  context 'without an MX but an A record' do
    let(:mx_record) { [] }

    it { is_expected.to be_truthy }
  end

  context 'without an A but an MX record' do
    let(:a_record) { [] }

    it { is_expected.to be_truthy }
  end
end
