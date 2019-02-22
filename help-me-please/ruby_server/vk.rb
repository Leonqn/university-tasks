require 'net/http'
require 'json'
class Vk
  def self.get_user(token)
    uri = URI("https://api.vk.com/method/users.get?access_token=#{token}&v=5.21&fields=photo_200")

    Net::HTTP.start(uri.host, uri.port,
                    :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      json_response = JSON.parse(response.body)
      raise 'VkException' unless json_response['error'].nil?
      return parse_user(json_response['response'][0])
  end
  end

  private
  def self.parse_user(response)
    p response
    VKUser.new(response['id'], response['first_name'], response['last_name'], response['photo_200'])
  end

  def self.token_expired?(response)
    !response['error'].nil? && response['error']['error_code'] == 10
  end
end

class VKUser
  attr_accessor :id, :first_name, :last_name, :photo

  def initialize(id, first_name, last_name, photo)
    @id, @first_name, @last_name, @photo = id, first_name, last_name, photo
  end
end