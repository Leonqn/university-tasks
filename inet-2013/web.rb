require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/reloader'
require '../inet-2013/app/model/post'
require '../inet-2013/app/model/visitor'
require '../inet-2013/app/model/form'
require 'base64'

class Web < Sinatra::Base
  
  configure :development do
    register Sinatra::Reloader
    #DataMapper.auto_migrate!
  end
  
  configure do
    set :views, 'app/haml'
    set :public_dir, 'public'
    helpers Sinatra::ContentFor
    helpers Sinatra::Cookies
    use Rack::Recaptcha, :public_key => '6LcgcusSAAAAAD3XuTxc2brz7_iZfGxsIQiqxOKr', :private_key => '6LcgcusSAAAAABR-4n0y1BOE8e4Dos6r0_bxj9k8'
    helpers Rack::Recaptcha::Helpers
    Encoding.default_external = 'UTF-8'
    enable :sessions
    enable :logging
    DataMapper::setup :default, "sqlite3://#{Dir.pwd}/app_data/visitors.db"
    DataMapper.finalize.auto_upgrade!
  end

  helpers do
    def h(text)
      tags = {'<i>' => '</i>', '<b>' => '</b>', '<s>' => '</s>'}
      tags.each do |k, v|
        begin_tag_index = text.downcase.index k
        end_tag_index = text.downcase.index v
          if begin_tag_index && end_tag_index
            return Rack::Utils.escape_html(text[0...begin_tag_index]) + k + Rack::Utils.escape_html(text[begin_tag_index + 3...end_tag_index]) + v + Rack::Utils.escape_html(text[end_tag_index+4..-1])
          end
        end
      Rack::Utils.escape_html(text)
    end
    def generate_result(res)
      ok, sr_ok, ne_ok = res
      if File.exist?(settings.public_dir + "/answers/#{ok}.#{sr_ok}.#{ne_ok}.png")
        "/answers/#{ok}.#{sr_ok}.#{ne_ok}.png"
      else
        i = Magick::Image.new(128, 70)
        gc = Magick::Draw.new
        gc.font settings.public_dir + '/consola.ttf'
        gc.pointsize = 14
        gc.text(0, 11, "Хорошо:     #{ok}".force_encoding('UTF-8'))
        gc.text(0,33,  "Нормально:  #{sr_ok}".force_encoding('UTF-8'))
        gc.text(0, 55, "Плохо:      #{ne_ok}".force_encoding('UTF-8'))
        gc.draw i
        i.write(settings.public_dir + "/answers/#{ok}.#{sr_ok}.#{ne_ok}.png")
        "/answers/#{ok}.#{sr_ok}.#{ne_ok}.png"
      end
    end
    def get_number(num)
      if File.exist?(settings.public_dir + "/numbers/#{num}.png")
        "/numbers/#{num}.png"
      else
        i = Magick::Image.new(7 * Math.log(num + 3).ceil, 15)
        gc = Magick::Draw.new
        gc.text(3, 13, num.to_s)
        gc.draw i
        i.write (settings.public_dir + "/numbers/#{num}.png")
        "/numbers/#{num}.png"
      end
    end
    def get_votes
      [Visitor.count(vote: :ok), Visitor.count(vote: :sr_ok), Visitor.count(vote: :ne_ok)]
    end
    def get_visitors(day)
      [get_number(Visitor.count(day: day)), get_number(Visitor.count(:ip))]
    end
  end

  get '/help/image' do
    width, height = params[:resolution].split('x').map(&:to_i)
    i = Magick::Image.new(width, height) do
      self.background_color = 'black'
      self.format = 'png'
    end
    gc = Magick::Draw.new
    gc.pointsize = 16
    gc.fill = 'white'
    params.each do |param, text|
      text = text.split ','
      gc.text(text[0].to_i, text[1].to_i, text[2]) if param.index 'text'
    end
    gc.draw i
    Base64.encode64(i.to_blob)
  end

  before do
    @vote_result = generate_result(get_votes)
    @visitor = Visitor.first_or_create(ip: request.ip)
    Page.create(page: request.path, visitor: @visitor) if request.request_method != 'POST' && request.path != '/voting'
    @user_agent = UserAgent.parse @request.user_agent
    time = DateTime.now
    @today_visitors, @in_all_visitors = get_visitors(time.day)
    @last_seen = @visitor.last_seen
    haml @visitor.vote.nil? ? :not_voted : :voted
    @votes_ok, @votes_sr_ok, @votes_ne_ok =
    if time.to_time - @visitor.last_seen.to_time > 600
      @visitor.update({was_count: @visitor.was_count + 1, last_seen: time, day: time.day})
    end
  end

  get '/' do
    haml :main_page
  end

  get %r{^/gallery/?(\d+)?$} do
    if params[:captures].nil? || params[:captures].empty?
      haml :gallery, :locals => {locals: {display: 'display: none', img: '/images/gallery_navigation/loading.gif', id: 'img'}}
    else
      haml :gallery, :locals => {locals: {display: 'display: flex;   display: -ms-flexbox;',  img: "/gallery/image_#{params[:captures][0]}.jpg", id: params[:captures][0]}}
    end
  end

  get '/admin' do
    @visitors = Visitor.all
    haml :admin
  end

  post '/admin' do
    @activity = Visitor.get(params[:ip]).pages
    haml :activity, layout: false
  end

  get '/about' do
    haml :about
  end

  get '/guest/:page' do
    posts = Post.all(order: [:id.desc])
    haml :guest_book, locals: {locals: {post: posts.drop(params[:page].to_i*20).take(20), size: posts.size / 20, page: params[:page],
                               user_name: session[:user_name], password: session[:password], message: session[:message]}}
  end

  post '/guest/:page' do
    if recaptcha_valid?
      p = Post.create(
                  time: DateTime.now,
                  user_name: params[:user_name] == '' ? 'Anonymous' : params[:user_name],
                  password: params[:password] == '' ? nil : params[:password])
      Message.create(message: params[:message], post: p)
      session.clear
      redirect "/guest/#{params[:page]}"
    else
      session[:user_name] = params[:user_name]
      session[:password] = params[:password]
      session[:message] = params[:message]
      redirect "/guest/#{params[:page]}"
    end
  end

  post '/voting' do
    @visitor.update({vote: params[:vote].to_sym})
    @votes_ok, @votes_sr_ok, @votes_ne_ok = get_votes
    redirect '/voting'
  end

  post '/guest/edit/:id' do
    @post = Post.get(params[:id].to_i)
    pass = params[:pass] ? params[:pass] : session[params[:id]]
    p pass
    if pass && @post.password == pass
      session[params[:id]] = pass
      if params[:mess]
        Message.create(message: params[:mess], post: @post)
        @post.messages.reload
        haml :post, layout: false
      else
        haml :edit_post, layout: false
      end
    else
      'wrngpss'
    end
  end

  get '/voting' do
    haml '', layout: '=yield_content :voting'
  end

  get '/form' do
    haml cookies[:voted] ? :already_filled : :form
  end

  post '/form' do
      cookies[:voted] = 'true'
      wishes = params[:wishes] unless params[:wishes].empty?
      date = params[:date] unless params[:date].empty?
      p params
      f = Form.create(name: params[:name],
                      full: params[:full],
                      color: params[:color],
                      wish: wishes,
                      ie: params[:ie],
                      chrome: params[:chrome],
                      firefox: params[:firefox],
                      date: date)
      params[:like].each do |like|
        if like == 'other'
          Like.create like: like, other: params[:like_other], form: f
        else
          Like.create like: like, form: f
        end
      end if params[:like]
      f.likes.reload
      redirect '/form'
  end

  get '/form/results' do
    content_type 'application/xml'
    Nokogiri::XML::Builder.new do
      results {
          Form.all.each do |form|
            user(id: form.id) {
              name form.name
              full_score form.full if form.full
              best_pages {
                form.likes.each do |like|
                  if like.like == 'other'
                    other like.other if like.other
                  else
                    like like.like if like.like
                  end
                end
              } if form.likes.any?
              browsers {
                ie form.ie if form.ie
                chrome form.chrome if form.chrome
                firefox form.firefox if form.firefox
              } if form.ie || form.chrome || form.firefox
              color form.color
              wishes form.wish if form.wish
              date_of_birth form.date if form.date
            }
          end
      }
    end.to_xml(encoding: 'UTF-8')
  end

end


