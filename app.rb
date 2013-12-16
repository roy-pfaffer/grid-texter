require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'haml'
require './config/init'
require 'twilio-ruby'
require 'googlevoiceapi'
require 'shotgun'

require './auth/credentials'
require './data_parser/data_parser'
require './adapter/twilio'
require './adapter/googlevoice'
require './commander/commander'
require_relative 'models/init'

class App < Sinatra::Base
  attr_reader :sender, :parser

  configure do
    @@active_users = [] # store all active users as User objects
  end

  get '/' do
    @users = User.all
    @messages = Message.all
    haml :index
  end

  get '/sms-gateway' do
    if (registered_user && user_active?)
      (parser.command?) ? commander.do : sender.forward_text_to_group
    elsif (parser.command? && parser.sent_command == 'join')
      join_user
    end
  end

  # in the kitchen

  def join_user
    if (registered_user)
      registered_user.update(:active => true)
    else
      User.create(:alias => parser.original_alias,
                  :sms_number => parser.from_number.to_i,
                  :active => true)
    end
    sender.send_text(parser.from_number,
                     "You've joined the conversation as #{registered_user[:alias]}.  Send '/help' for a list of available commands.")
    sender.send_to_everyone_else("#{registered_user[:alias]} has joined the conversation.")
  end

  def registered_user
    @registered_user ||= User.where(:sms_number => parser.from_number.to_i).first
  end

  def user_active?
    registered_user[:active]
  end

  def parser
    @parser ||= ::DataParser.new(params)
  end

  def sender
    @sender ||= ::Adapter::GoogleVoice.new(registered_user: registered_user,
                                           params: params,
                                           parser: parser)
  end

  def commander
    @commander ||= ::Commander.new(registered_user: registered_user,
                                   params: params,
                                   parser: parser)
  end

  run! if app_file == $0
end

