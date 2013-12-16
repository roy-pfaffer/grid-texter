class Commander
  attr_reader :registered_user, :params, :sender, :parser

  def initialize(args)
    @registered_user = args[:registered_user]
    @params = args[:params]
    @parser = args[:parser] ||= ::DataParser.new(@params)
    @sender = args[:sender] ||= ::Adapter::GoogleVoice.new(registered_user: @registered_user,
                                                           params: @params)
  end

  def do
    send("user_#{parser.sent_command}", *(parser.sent_args))
  end

  def method_missing(selector)
    sender.send_reply("#{selector} is not a command.")
  end

  # user commands - that is, commands that the user can issue

  def user_help(*args)
    command_description = {
      'alias' => "Changes your display name.  Example: '/alias Poopster'",
      'help' => "Lists available commands.",
      'invite' => "Invites user with specified alias.  Example: '/invite Pfaffer'",
      'leave' => "Leave the conversation.",
      'roster' => "Lists all registered users, active or inactive.",
      'unsubscribe' => "Leave the conversation and remove yourself from the user database.  Users will not be able to invite you, and you will not receive announcements.",
      'whoshere' => "Lists all users in the conversation."
    }
    if (args.empty?)
      sender.send_reply("Use '/' to send a command (example: /alias).  Type '/help (command)' for a description of the command.  COMMANDS: alias, whoshere, leave, unsubscribe")
    else
      sender.send_reply("#{args.first}: #{command_description[args.first]}")
    end
  end

  def user_alias(new_alias)
    sender.send_text_to_group("#{registered_user[:alias]} has changed his alias to #{new_alias}.")
    registered_user.update(:alias => new_alias)
  end


  def user_invite(*args)
    invitee_alias = args.join(' ')
    invitee = User.where(:alias => invitee_alias).first
    if (args.empty?)
      sender.send_reply("You must specify a user.  Example: '/invite Pfaffer'")
    else
      if (invitee)
        sender.send_text(invitee[:sms_number], "#{registered_user[:alias]} wants you to join the conversation!  Send '/join' to accept.")
        sender.send_reply("You have sent an invitation to #{invitee_alias}")
      else
        sender.send_reply("Sorry, there is no user with the alias #{invitee_alias}.  Send '/roster' to see a list of available users.")
      end
    end
  end

  def user_join
    sender.send_reply("You're already in conversation.")
  end

  def user_leave
    registered_user.update(:active => false)
    sender.send_reply("You have been disconnected.")
    sender.send_to_everyone_else("#{registered_user[:alias]} has left.")
  end

  def user_roster
    everyone_else = User.exclude(:sms_number => parser.from_number.to_i).map(:alias).join(', ')
    (!everyone_else.empty?) ? sender.send_reply(everyone_else) : sender.send_reply("You're alone.  Invite someone to join the conversation with the /invite command.")
  end

  def user_whoshere
    everyone_else = User.where(:active => true).exclude(:sms_number => parser.from_number.to_i).map(:alias).join(', ')
    (!everyone_else.empty?) ? sender.send_reply(everyone_else) : sender.send_reply("You're alone.  Invite someone to join the conversation with the /invite command.")
  end

  def user_unsubscribe
    registered_user.delete
    sender.send_reply("You have unsubscribed.  Send /join to resubscribe and join the conversation.")
    sender.send_to_everyone_else("#{registered_user[:alias]} has unsubscribed.")
  end

  end
