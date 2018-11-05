require "discordcr-middleware"
require "discordcr-middleware/middleware/cached_routes"
require "discordcr-middleware/middleware/attribute"
require "discordcr-middleware/middleware/channel"

module SGM::Bot

  @[Discord::Plugin::Options(middleware: DiscordMiddleware::Channel.new(id: 506649880547164161))]
  class ServerLink
    include Discord::Plugin

    class Text
      include JSON::Serializable

      @[JSON::Field(key: "text")]
      property text : String

      @[JSON::Field(key: "color")]
      property color : String

      def initialize(@text : String, @color : String = "white")
      end
    end

    @[Discord::Handler(event: :message_create)]
    def on_message(payload, ctx)
      # TODO: Eventually let players link their mc to discord
      return if payload.author.bot
      
      texts = [
        Text.new("[Discord] ", "blue"),
        Text.new("#{payload.author.username}: ", "gray"),
        Text.new(payload.content)
      ]
      RCON_CLIENT.send(:command, "tellraw @a [#{texts.map{|text| text.to_json}.join(", ")}]".to_slice)
    end
  end
end
