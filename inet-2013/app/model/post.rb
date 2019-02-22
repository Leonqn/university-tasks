require 'data_mapper'
class Message
  include DataMapper::Resource

  property :id, Serial, index: true
  property :message, Text
  belongs_to :post

end

class Post
  include DataMapper::Resource

  property :id, Serial, index: true
  property :user_name, String
  property :password, String, allow_nil: true
  property :time, DateTime
  has n, :messages
end