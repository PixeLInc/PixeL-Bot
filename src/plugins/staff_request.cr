@[Discord::Plugin::Options(middleware: {DiscordMiddleware::Error.new("error: `%exception%`"),
                                        DiscordMiddleware::Prefix.new("<@#{CLIENT_ID}> staff")})]
class SGM::Bot::Requests
  include Discord::Plugin

  VALID_SERVERS   = ["west", "east", "eu", "vanilla", "eu2", "dr"]
  REQUEST_CHANNEL = 380421717861990401_u64

  # TODO: Store globally somewhere else, prolly.
  STAFF_ROLES = [] of UInt64

  def is_staff?(user)
    # cache.resolve_member(guild_id, user_id)
    return false
  end

  @[Discord::Handler(event: :message_create)]
  def handle(payload, _ctx)
    args = payload.content.split(' ', remove_empty: true)

    if args.size < 3
      reply = client.create_message(
        payload.channel_id,
        "That doesn't seem right.. How about @PixeLBot staff <server> [reason]"
      )

      return reply
    end

    server = args[2]
    if server == "cancel" && is_staff?(payload.author)
      if args.size < 4
        reply = client.create_message(
          payload.channel_id,
          "Sorry, which server did you want to cancel the request for?"
        )

        return reply
      end
      name = args[3]
      reply = client.create_message(
        payload.channel_id,
        "Cancelled the request for **#{name}**"
      )

      return reply
    end

    reason = args[3..-1].join(" ")

    unless VALID_SERVERS.includes?(server)
      reply = client.create_message(
        payload.channel_id,
        "Invalid server. Try (#{VALID_SERVERS.join(", ")})"
      )

      return reply
    end

    reply = <<-MESSAGE
      @here
      #{payload.author.username} has requested staff for **#{server}**:
      ```#{reason.empty? ? "No reason specified" : reason}```
    MESSAGE

    client.create_message(REQUEST_CHANNEL, reply)
  end
end
