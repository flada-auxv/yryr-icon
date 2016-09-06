class User < ActiveRecord::Base
  has_one :schedule

  validates :twitter_uid, :token, :secret, presence: true

  def schedule_at(hours)
    schedule ? schedule.update(hours: hours) : create_schedule(hours: hours)
  end

  def update_profile_image(icon)
    twitter.update_profile_image(icon)
  end

  def tweet_chaging_icon(icon_url)
    twitter.update <<TWEET
"TwitterのアイコンをランダムでYRYRするやつ" でアイコンを変えたよ https://yryr-icon.herokuapp.com/ #yryr_icon
#{icon_url}
TWEET
  end

  def update_icon_randomly
    icon = Icon.get_random
    update_profile_image(icon.file)
    tweet_chaging_icon(icon.url)
    icon
  end

  private

  def twitter
    @client ||= Twitter::REST::Client.new {|config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = token
      config.access_token_secret = secret
    }
  end
end
