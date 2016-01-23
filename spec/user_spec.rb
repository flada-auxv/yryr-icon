RSpec.describe User do
  let(:user) { User.create(twitter_uid: SecureRandom.hex, token: 'xxx', secret: 'xxx') }

  describe '#schedule_at' do
    let(:hours) { 3 }

    before do
      user.schedule_at(hours)
    end

    it { expect(user.schedule.hours).to eq(3) }
  end

  describe '#update_profile_image' do
    let(:twitter) { double(:twitter) }
    let(:icon) { instance_double(Icon) }

    before do
      allow(user).to receive(:twitter).and_return(twitter)
    end

    it  do
      expect(twitter).to receive(:update_profile_image).with(icon)
      user.update_profile_image(icon)
    end
  end
end
