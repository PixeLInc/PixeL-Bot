require "oauth2"

module SGM::Web::Middleware

  class VerifyMinecraft < Raze::Handler
    def initialize(@secret : String)
    end

    def call(ctx, done)
      request = ctx.request

      unless request.headers["X-Authorization"] == @secret
        ctx.halt_json({"message": "Invalid secret"}.to_json, 400)
        return
      end

      done.call
    end
  end

  class DiscordOAuth2 < Raze::Handler
    def initialize(client_id : String, client_secret : String,
                   redirect_uri : String)
      @client = OAuth2::Client.new("discordapp.com/api/v7",
        client_id,
        client_secret,
        redirect_uri: redirect_uri)
    end

    def call(ctx, done)
      if code = ctx.request.query_params["code"]?
        response = @client.get_access_token_using_authorization_code(code)
        ctx.state["token"] = response.access_token
        done.call
      else
        ctx.halt_plain "Missing code", 400
      end
    end
  end
end
