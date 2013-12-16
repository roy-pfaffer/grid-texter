require 'sequel'
DB = Sequel.connect("sqlite://#{Dir.pwd}/development.db")

require_relative 'migrations'
require_relative 'user'
require_relative 'message'
