RSpec.describe YRYRIcon do
  describe 'when not logged in' do
    before do
      get '/'
    end

    it { expect(last_response).to be_redirect }
    it { expect(last_response.location).to be_include('/login') }
  end
end
