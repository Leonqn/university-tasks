class Server < Sinatra::Base
  include Mongo

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :logging
    Mongoid.load!('./config/mongoid.yml')
    use Rack::Session::Cookie,
        :key => 'session',
        :expire_after => 2592000,
        :secret => 'secret'
    User.create_indexes
    HelpPoint.create_indexes
  end

  before do
    headers 'Content-Type' => 'application/json; charset=utf-8'
  end

  get '/' do
    headers 'Content-Type' => 'text/html; charset=utf-8'
    ''
  end

  post '/reg' do
    halt 400, JSON.generate(error: 'There is no token') if params[:token].nil?
    begin
      vk_user = Vk.get_user(params[:token])
      User.new(uid: vk_user.id, first_name: vk_user.first_name, last_name: vk_user.last_name, photo: vk_user.photo).upsert
      session[:id] = vk_user.id
      status 201
    rescue Exception => e
      p e
      halt 400, JSON.generate(error: 'Wrong token')
    end
  end

  post '/hp/set' do
    halt 403 if session[:id].nil?
    user = User.find(session[:id])
    halt 403 if user.nil?
    user.help_points << HelpPoint.new(location: [params[:lng].to_f, params[:lat].to_f], message: params[:message], photo: params[:photo])
    status 201
  end

  get '/hp/get' do
    HelpPoint.where(done: -1).geo_near([params[:lng].to_f, params[:lat].to_f]).max_distance(params[:side].to_f).as_json.each do |point|
      user = User.find(point['user_id']).as_json
      user.delete('uid')
      point['user'] = user
      point.delete('user_id')
    end.to_json
  end

  put '/hp/update-status' do
    halt 403 if session[:id].nil?
    HelpPoint.where(_id: params[:id]).update(done: params[:to].to_i)
    status 202
  end
end


