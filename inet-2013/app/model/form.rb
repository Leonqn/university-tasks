require 'data_mapper'
class Form
  include DataMapper::Resource

  property :id, Serial, index: true
  property :name, String
  property :full, Integer, required: false
  has n, :likes
  property :ie, Integer, required: false
  property :chrome, Integer, required: false
  property :firefox, Integer, required: false
  property :color, String, required: false
  property :wish, Text, required: false
  property :date, String, required: false
end

class Like
  include DataMapper::Resource

  property :id, Serial
  property :like, String, required: false
  property :other, String, required: false
  belongs_to :form
end