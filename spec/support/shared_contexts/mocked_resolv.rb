RSpec.shared_context 'mocked Resolv' do |domain|
  let(:dns) { double(Resolv::DNS) }
  let(:mx_record) { [double] }
  let(:a_record) { [double] }

  before do
    allow(Resolv::DNS).to receive(:open).and_yield(dns)
    allow(dns).to receive(:getresources).with(domain, Resolv::DNS::Resource::IN::MX).once.and_return(mx_record)
    allow(dns).to receive(:getresources).with(domain, Resolv::DNS::Resource::IN::A).once.and_return(a_record)
  end
end
