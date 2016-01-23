class User < ActiveRecord::Base
  has_one :schedule

  validates :twitter_uid, :token, :secret, presence: true

  def schedule_at(hours)
    schedule ? schedule.update(hours: hours) : create_schedule(hours: hours)
  end

  def update_profile_image(icon)
    twitter.update_profile_image(icon)
  end

  def update_icon_randomly
    icon = YRYRIcon.get_random_icon
    update_profile_image(icon.file)
    icon
  end

  private

  def twitter
    Twitter::REST::Client.new {|config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = token
      config.access_token_secret = secret
    }
  end
end
