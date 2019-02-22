require 'rubygems' 
require 'bundler'
require 'sinatra/base'
require './vk'
require './models/help_point'
require './models/user'
Bundler.require
require './server'

run Server
