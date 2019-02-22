require 'mongoid'
class HelpPoint
  include  Mongoid::Document
  field :location, type: Array
  field :message, type: String
  field :photo, type: String
  field :created_at, type: Time, default: -> {Time.now}
  field :done, type: Integer, default: -1
  belongs_to :user
  index({location: '2d'})
  index({done: 1})
end