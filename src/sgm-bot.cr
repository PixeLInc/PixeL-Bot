require "discordcr-plugin"
require "./plugins/*"
require "./utils/*"

module SGM::Bot
  RCON_CLIENT = RCONClient.new("mugjet.com", 25575, "TBO4j^wUVHOfb")
  RCON_CLIENT.authenticate

  client = Discord::Client.new(token: "NTA3NzMwMDE0ODA1MDMyOTgw.Dr098Q.6147Dv1gD1_gxbkE7FCL_PlVXwk")
  cache  = Discord::Cache.new(client)
  client.cache = cache

  Discord::Plugin.plugins.each do |plugin|
    client.register(plugin)
  end

  client.run
end
