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

    before do
      stub_request(:get, url).to_return(body: "xxx")
    end

    subject { YRYRIcon.get_icon(url) }

    it { expect(subject.url).to eq('https://example.com/akari')  }
    it { expect(subject.file).to be_a(File) }
  end

  describe '#initialize' do
    let(:attributes) { {url: 'https://example.com/akari', file: dummy_file} }

    subject { YRYRIcon.new(attributes) }

    it { expect(subject.url).to eq('https://example.com/akari') }
    it { expect(subject.file).to be_a(File) }
  end
end
