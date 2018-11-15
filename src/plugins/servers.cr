require "sgm-binding"

@[Discord::Plugin::Options(middleware: {DiscordMiddleware::Error.new("error: `%exception%`"),
                                        DiscordMiddleware::Prefix.new("<@#{CLIENT_ID}> servers")})]
class SGM::Bot::Servers
  include Discord::Plugin

  @[Discord::Handler(event: :message_create)]
  def handle(payload, _ctx)
    servers = SGM.servers

    fields = servers.map do |element|
      name = if element.name_full.includes?("|")
               element.name_full.split(" |")[0]
             else
               element.name_full.split(" -")[0]
             end
      Discord::EmbedField.new(
        name: "#{name} (#{element.num_players}/#{element.num_maxplayers})",
        value: "steam://connect/#{element.ip}:#{element.port}"
      )
    end

    embed = Discord::Embed.new(
      title: "**SGM - Servers List:**",
      thumbnail: Discord::EmbedThumbnail.new(
        url: "https://www.seriousgmod.com/styles/seriousgmod/logo.png",
      ),
      fields: fields,
    )

    client.create_message(payload.channel_id, "", embed)
  end
end
