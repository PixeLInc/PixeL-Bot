require "json"

module SGM::Bot

  @[Discord::Plugin::Options(middleware: DiscordMiddleware::Channel.new(id: 506649880547164161))]
  class ServerLink
    include Discord::Plugin

    @[Discord::Handler(event: :message_create)]
    def on_message(payload, ctx)
      # TODO: Eventually let players link their mc to discord
      return if payload.author.bot

      content = payload.content

      texts = [
        {
          text: "[Discord] ",
          color: "blue"
        },
        {
          text: "#{payload.author.username}: ",
          color: "gray"
        },
        {
          text: payload.content,
          color: "white"
        }
      ]

      RCON_CLIENT.tell_raw("@a", texts)
    end
  end
end
