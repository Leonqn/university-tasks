require 'test/unit'
require 'rack/test'
require 'json'
#https://oauth.vk.com/authorize?client_id=4299842&scope=offline&v=5.21&response_type=token&redirect_uri=https://oauth.vk.com/blank.html
TOKEN = '0c4eea5d48608a497cf90d6306d75ed03628e3dde71a0d4bb9cae03d5128a3afbf103f7e8dff0737e9bbc'
class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  def setup
    clear_cookies
  end

  def test_invalid_token
    post '/reg', token: 'qweqwe'
    assert_equal 400, last_response.status
  end

  def test_empty_token
    post '/reg'
    assert_equal 400, last_response.status
  end

  def test_valid_token
    post '/reg', token: TOKEN
    assert_equal 201, last_response.status
    assert_not_nil rack_mock_session.cookie_jar
  end

  def test_set_autorized
    post '/reg', token: TOKEN
    post '/hp/set', lng: 123, lat: 123
    assert_equal 201, last_response.status
  end

  def test_set_unautorized
    post 'hp/set', lng: 123, lat: 123
    assert_equal 403, last_response.status
  end

  def test_get_points
    post '/reg', token: TOKEN
    post '/hp/set', lng: 123, lat: 123
    get '/hp/get', lng: 123, lat: 123, side: 5
    assert_equal 200, last_response.status
    assert_no_match /\[\]/, last_response.body
  end

  def test_update_status
    post '/reg', token: TOKEN
    post '/hp/set', lng: 123, lat: 123
    get '/hp/get', lng: 123, lat: 123, side: 5
    put '/hp/update-status', id: last_response.body[10, 24], to: 123
    assert_equal 202, last_response.status
  end
end