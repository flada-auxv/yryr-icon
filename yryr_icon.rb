require 'active_record'
require 'hamlit'
require 'omniauth-twitter'
require 'pry'
require 'pg'
require 'rack-flash'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'twitter'
require 'yaml'

require_relative 'models/schedule'
require_relative 'models/user'
require_relative 'models/icon'

class YRYRIcon < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  register Sinatra::Reloader

  configure do
    enable :sessions
    set :haml, escape_html: false

    use Rack::Flash

    use OmniAuth::Builder do
      provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
    end
  end

  get '/' do
    redirect to('/login') unless current_user

    haml :index
  end

  get '/login' do
    haml :not_logged_in
  end

  get '/change' do
    require_authentication!

    @icon = current_user.update_icon_randomly

    haml :complete, layout: false
  end

  post '/schedule' do
    require_authentication!

    current_user.schedule_at(params[:hours])

    flash[:notice] = "毎日 #{params[:hours]} 時に実行されるように予約したよ"

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
        flash[:notice] = 'トップページから Twitter で認証してね'

        redirect to('/')
      end
    end
  end
end
