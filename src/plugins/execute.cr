@[Discord::Plugin::Options(middleware: {DiscordMiddleware::Error.new("error: `%exception%`"),
                                        DiscordMiddleware::Prefix.new("<@#{CLIENT_ID}> exec")})]
class SGM::Bot::Execute
  include Discord::Plugin

  @[Discord::Handler(event: :message_create)]
  def handle(payload, _ctx)
    args = payload.content.split(' ', remove_empty: true)
    if args.size < 3
      reply = client.create_message(
        payload.channel_id,
        "You've got to actually enter a command to be executed... *sigh*"
      )

      return reply
    end

    account = DB.get_mc(payload.author.id.value)
    if account.empty?
      reply = client.create_message(
        payload.channel_id,
        "Hmm, looks like you haven't linked your account yet!"
      )
      return reply
    end

    command = args[2..-1].join(' ')

    RCON_CLIENT.sudo(account, command)
  end
end
