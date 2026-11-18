ENV['RACK_ENV'] ||= 'development'
require 'sinatra/base'
require 'securerandom'
require_relative 'models/database_setup'

class MakersBnb < Sinatra::Base
  secret = ENV['SESSION_SECRET']
  if secret.nil? || secret.bytesize < 64
    raise 'Set SESSION_SECRET to at least 64 random bytes' if environment == :production
    secret = SecureRandom.hex(64)
  end
  set :session_secret, secret
  set :sessions, key: 'makersbnb.session', httponly: true, same_site: :lax,
                 secure: environment == :production, expire_after: 86_400
  use Rack::MethodOverride

  helpers do
    def h(value)
      Rack::Utils.escape_html(value.to_s)
    end

    def csrf_token
      session[:csrf_token] ||= SecureRandom.hex(32)
    end

    def current_user
      @current_user ||= User.get(session[:user_id])
    end

    def space_id
      @space ||= Space.get(session[:space_id])
    end
  end

  before do
    @errors = []
    if %w[POST PUT PATCH DELETE].include?(request.request_method) &&
       !Rack::Utils.secure_compare(csrf_token, params[:csrf_token].to_s)
      halt 403, 'Invalid form token'
    end
    protected_route = ['/spaces', '/spaces/new', '/spaces/booking', '/booking', '/request'].include?(request.path_info)
    redirect '/login' if protected_route && !current_user
  end

  get('/') { redirect '/signup' }
  get('/signup') { erb :signup }
  get('/login') { erb :login }

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session.clear
      session[:user_id] = user.id
      redirect '/spaces'
    else
      @errors = ['The email or password is incorrect']
      erb :login
    end
  end

  delete '/sessions' do
    session.clear
    session[:notice] = 'goodbye'
    redirect '/'
  end

  post '/signup' do
    @user = User.new(username: params[:username], email: params[:email], password: params[:password])
    if @user.save
      session.clear
      session[:user_id] = @user.id
      redirect '/spaces'
    else
      @errors = @user.errors.full_messages
      erb :signup
    end
  rescue Sequel::UniqueConstraintViolation
    @errors = ['Username or email is already registered']
    erb :signup
  end

  get '/spaces' do
    @spaces = Space.all
    erb :spaces
  end

  get('/spaces/new') { erb :new_space }

  post '/spaces/new' do
    space = Space.new(space_name: params[:space_name], space_description: params[:space_description],
                      space_price: params[:space_price], availability_start: params[:availability_start],
                      availability_end: params[:availability_end], user_id: current_user.id)
    unless space.save
      @errors = space.errors.full_messages
      status 400
      return erb :new_space
    end
    redirect '/spaces'
  end

  get '/booking' do
    halt 404, 'Space not found' unless space_id
    erb :booking
  end

  post '/spaces/booking' do
    id = params[:post_id]
    halt 400, 'Invalid space ID' unless id.is_a?(String) && /\A[1-9]\d*\z/.match?(id)
    halt 404, 'Space not found' unless Space.get(id.to_i)
    session[:space_id] = id.to_i
    redirect '/booking'
  end

  get '/request' do
    halt 404, 'Space not found' unless space_id
    erb :request
  end

  post '/request' do
    halt 404, 'Space not found' unless space_id
    redirect '/request'
  end

  run! if app_file == $0
end
