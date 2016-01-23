RSpec.describe YRYRIcon do
  let(:dummy_file) { File.new('spec/fixtures/yryr.png') }

  describe '.all_urls' do
    subject { described_class.all_urls }

    it { is_expected.to be_a(Array) }
  end

  describe '.create_tempfile' do
    subject { YRYRIcon.create_tempfile(str) }

    let(:str) { 'xxx' }

    it { is_expected.to be_a(File) }
    it { expect(subject.read).to eq('xxx') }
  end

  describe '.get_icon' do
    let(:url) { 'https://example.com/akari' }
    let(:headers) { {'Content-Type' => 'image/jpeg'} }

    subject { YRYRIcon.get_icon(url) }

    context 'when success' do
      before do
        stub_request(:get, url).to_return(body: "xxx", headers: headers)
      end

      it { expect(subject.url).to eq('https://example.com/akari')  }
      it { expect(subject.file).to be_a(File) }
    end

    context 'when Faraday:::ResourceNotFound occured' do
      before do
        stub_request(:get, url).to_raise(Faraday::ResourceNotFound)
      end

      it { is_expected.to be_nil }
    end

    context 'when Content-Type is not image' do
      before do
        stub_request(:get, url).to_return(body: "xxx", headers: {'Content-Type' => 'text/html'})
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#initialize' do
    let(:attributes) { {url: 'https://example.com/akari', file: dummy_file} }

    subject { YRYRIcon.new(attributes) }

    it { expect(subject.url).to eq('https://example.com/akari') }
    it { expect(subject.file).to be_a(File) }
  end
end
