require 'data_mapper'

class Visitor
  include DataMapper::Resource

  property :ip, String, key: true, index: true
  property :was_count, Integer, default: 1
  property :last_seen, DateTime, default: DateTime.now
  property :day, Integer, default: DateTime.now.day
  property :vote, Enum[:ok, :sr_ok, :ne_ok], required: false
  has n, :pages
end

class Page
  include DataMapper::Resource
  property :id, Serial, index: true
  property :page, String
  property :date, DateTime, default: DateTime.now
  belongs_to :visitor
end