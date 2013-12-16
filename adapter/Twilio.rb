class Adapter
  class TwilioParser
    attr_reader :account

    def say_something
      "Drop some of those funky, fresh beats, blanco nino."
    end

    def account
      @account ||= load_account
    end

    def load_account
      account_sid = credentials.twilio_account_sid
      auth_token = credentials.twilio_auth_token
      client = Twilio::REST::Client.new(account_sid, auth_token)
      client.account
    end

    def send_group_text(msg)
      if registered_user
        recipients = users.exclude(:sms_number => params[:from].to_i)
        recipient_numbers_in_array = recipients.map(:sms_number)
        message_to_send = "#{registered_user[:alias]}: #{msg}"
        recipient_numbers_in_array.each do |recipient_number|
          twilio_message = twilio_account.sms.messages.create({:from => '+19496827852', :to => recipient_number.to_s, :body => message_to_send})
          puts twilio_message
        end
      end
    end

    def send_reply(msg)
      twiml = ::Twilio::TwiML::Response.new do |r|
        r.Sms msg
      end
      twiml.text
    end
  end

  # in the kitchen

  def credentials
    @auth ||= Auth::Credentials.new
  end
end
