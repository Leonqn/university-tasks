require 'mongoid'
class User
  include Mongoid::Document
  field :uid, type: Integer
  field :_id, type: String, default: ->{ uid.to_s }
  field :first_name, type: String
  field :last_name, type: String
  field :photo, type: String
  has_many :help_points
end