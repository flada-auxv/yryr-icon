require 'active_record'
require 'hamlit'
require 'omniauth-twitter'
require 'pry'
require 'pg'
require 'rack-flash'
require 'sinatra'
require 'sinatra/activerecord'
require 'twitter'
require 'yaml'

class MyApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure do
    enable :sessions
    use Rack::Flash

    use OmniAuth::Builder do
      provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
    end
  end

  get '/' do
    haml :index
  end

  get '/change' do
    require_authentication!

    @icon = current_user.update_icon_randomly

    haml :complete
  end

  post '/schedule' do
    require_authentication!

    current_user.schedule_at(params[:hours])

    redirect to('/')
  end

  get '/auth/twitter/callback' do
    auth = env['omniauth.auth']
    user = User.find_or_initialize_by(twitter_uid: auth[:uid])
    user.update(token: auth[:credentials][:token], secret: auth[:credentials][:secret])
    session[:current_user_id] = user.id

    redirect to('/')
  end

  helpers do
    def current_user
      User.find_by(id: session[:current_user_id])
    end

    def require_authentication!
      unless current_user
        flash[:error] = 'トップページから Twitter で認証してね'

        redirect to('/')
      end
    end

    def twitter
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['CONSUMER_KEY']
        config.consumer_secret     = ENV['CONSUMER_SECRET']
        config.access_token        = current_user.token
        config.access_token_secret = current_user.secret
      end
    end

    def image_urls
      YAML.load_file('./config/image_urls.yml')
    end

    def random_image_path
      image_urls.sample
    end

    def get_yryr_icon(image_path = random_image_path)
      conn = Faraday.new do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      end

      res = conn.get(image_path)

      tempfile = Tempfile.create(['yryr_img', '.jpg'])
      tempfile.write(res.body)
      tempfile.rewind
      tempfile
    end
  end
end

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

class Schedule < ActiveRecord::Base
  belongs_to :user

  validates :hours, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 24}
end

class YRYRIcon
  attr_accessor :url, :file

  class << self
    def all_urls
      @all_urls ||= YAML.load_file('./config/image_urls.yml')
    end

    def random_url
      all_urls.sample
    end

    def get_random_icon
      url = random_url
      res = client.get(url)

      tempfile = Tempfile.create(['yryr_icon', '.jpg'])
      tempfile.write(res.body)
      tempfile.rewind
      tempfile

      new {|icon|
        icon.url = url
        icon.file = tempfile
      }
    end

    private

    def client
      Faraday.new {|faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      }
    end
  end

  def initialize(&block)
    yield(self) if block_given?
  end
end
