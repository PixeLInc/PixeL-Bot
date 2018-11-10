require "raze"
require "kilt/slang"
require "discordcr"
require "./app/*"

module SGM::Web
  class_getter config = Config.from_file("config.yml")

  class_getter db = DB.new(config.database_url)
  at_exit { @@db.close }

  class UserNotFound < Exception
  end

  def self.handle_minecraft_link(code : String, mcuser : String)
    result = db.update_user(code, mcuser)

    raise UserNotFound.new("User not found") if result.rows_affected.zero?
  end
end
