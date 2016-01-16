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

    @icon_url = random_image_path
    icon = get_yryr_icon(@icon_url)
    twitter.update_profile_image(icon)

    haml :complete
  end

  get '/auth/twitter/callback' do
    session[:uid] = env['omniauth.auth']['uid']
    redirect to('/')
  end

  helpers do
    def current_user
      session[:uid]
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
        config.access_token        = ENV['ACCESS_TOKEN']
        config.access_token_secret = ENV['ACCESS_SECRET']
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
end

class Schedule < ActiveRecord::Base
  belongs_to :user
end
