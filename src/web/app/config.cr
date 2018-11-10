require "yaml"

module SGM::Web
  class Config
    YAML.mapping(
      client_id: String,
      client_secret: String,
      host: String,
      database_url: String,
      web_secret: String
    )

    def self.from_file(filename : String)
      Config.from_yaml(File.read(filename))
    end
  end
end
