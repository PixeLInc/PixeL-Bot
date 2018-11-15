require "discordcr-plugin"

require "discordcr-middleware"
require "discordcr-middleware/middleware/cached_routes"
require "discordcr-middleware/middleware/attribute"
require "discordcr-middleware/middleware/channel"
require "discordcr-middleware/middleware/prefix"
require "discordcr-middleware/middleware/error"

require "./plugins/*"
require "./utils/rcon/rcon"

require "./web/app/config"
require "./web/app/database"

module SGM::Bot
  CONFIG = SGM::Web::Config.from_file("config.yml")
  DB = SGM::Web::DB.new(CONFIG.database_url)
  at_exit { DB.close }

  RCON_CLIENT = RCON::Client.connect("mugjet.com", 25575, "TBO4j^wUVHOfb")
  CLIENT_ID   = 507730014805032980_u64

  client = Discord::Client.new(token: "Bot NTA3NzMwMDE0ODA1MDMyOTgw.Dr098Q.6147Dv1gD1_gxbkE7FCL_PlVXwk")
  cache = Discord::Cache.new(client)
  client.cache = cache

  Discord::Plugin.plugins.each do |plugin|
    client.register(plugin)
  end

  client.run
end
