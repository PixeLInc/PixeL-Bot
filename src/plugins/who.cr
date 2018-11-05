@[Discord::Plugin::Options(middleware: {DiscordMiddleware::Error.new("error: `%exception%`"),
                                        DiscordMiddleware::Prefix.new("<@#{CLIENT_ID}> players")})]
class SGM::Bot::Who
  include Discord::Plugin

  @[Discord::Handler(event: :message_create)]
  def handle(payload, _ctx)
    response = String.new(RCON_CLIENT.players.payload).gsub(/(?i)§[0-9A-FK-OR]/, "")
    client.create_message(payload.channel_id, response)
  end

end
