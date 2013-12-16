class Adapter
  class GoogleVoice
    attr_reader :parser, :params, :api, :credentials, :registered_user

    def initialize(args)
      @registered_user = args[:registered_user]
      @params = args[:params]
      @parser = args[:parser] ||= ::DataParser.new(params)
    end

    def say_something
      "google voice is here"
    end

    def send_text(recipient_number, msg)
      Message.create(:content => msg.to_s)
      api.sms(recipient_number.to_s, msg.to_s)
    end

    def send_reply(msg)
      send_text(registered_user[:sms_number], msg)
    end

    def send_to_everyone_else(msg)
      recipients = User.exclude(:sms_number => parser.from_number.to_i)
      recipient_numbers_in_array = recipients.map(:sms_number)
      recipient_numbers_in_array.each do |recipient_number|
        send_text(recipient_number.to_s, msg)
      end
    end

    def send_text_to_group(msg)
      recipient_numbers_in_array = User.map(:sms_number)
      recipient_numbers_in_array.each do |recipient_number|
        send_text(recipient_number.to_s, msg)
      end
    end

    def forward_text_to_group
      recipients = active_users.exclude(:sms_number => parser.from_number.to_i)
      recipient_numbers_in_array = recipients.map(:sms_number)
      message_to_send = "#{registered_user[:alias]}: #{parser.message}"
      recipient_numbers_in_array.each do |recipient_number|
        send_text(recipient_number.to_s, message_to_send)
      end
    end

    # in the kitchen

    def credentials
      @credentials ||= Auth::Credentials.new
    end

    def api
      @api ||= ::GoogleVoice::Api.new(credentials.googlevoice_username, credentials.googlevoice_password)
    end

    def active_users
      @active_users ||= User.where(:active => true)
    end

  end
end
