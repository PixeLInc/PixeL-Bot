require "./app"
require "random"

module SGM::Web
  get "/" do |ctx|
    params = HTTP::Params.build do |form|
      form.add "client_id", SGM::Web.config.client_id.to_s
      form.add "redirect_uri", SGM::Web.config.host + "/oauth2/discord"
      form.add "scope", "identify email"
      form.add "response_type", "code"
    end

    authorize_url = "https://discordapp.com/oauth2/authorize?#{params}"
    render("views/index.slang")
  end

  get("/oauth2/discord",
    SGM::Web::Middleware::DiscordOAuth2.new(
      SGM::Web.config.client_id,
      SGM::Web.config.client_secret,
      SGM::Web.config.host + "/oauth2/discord")) do |ctx|
    token = ctx.state["token"].as(String)

    response = HTTP::Client.get(
      "#{Discord::REST::API_BASE}/users/@me",
      HTTP::Headers{
        "User-Agent"    => "SGM-Bot",
        "Authorization" => "Bearer #{token}",
      })

    user = Discord::User.from_json(response.body)
    if user.email
      code = Random::Secure.hex(3)

      db.create_user(
        user.id.to_u64,
        token,
        code
      )

      render("views/link_minecraft.slang")
    else
      message = <<-MESSAGE
        You don't have an email listed on your Discord account.
        Please verify your Discord account.
        MESSAGE

      render("views/user_error.slang")
    end
  end

  get("/minecraft/verify",
    SGM::Web::Middleware::VerifyMinecraft.new(
    SGM::Web.config.web_secret)) do |ctx|

    if code = ctx.request.query_params["code"]?
      if mc_username = ctx.request.query_params["username"]?
        begin
          SGM::Web.handle_minecraft_link(code, mc_username)

          ctx.status_code = 200
          "OK"
        rescue ex : SGM::Web::UserNotFound
          ctx.halt_plain "Code not found", 400
        end
      else
        ctx.halt_plain "Missing username", 400
      end
    else
      ctx.halt_plain "Missing code", 400
    end
  end

  get("/minecraft/checkverification",
      SGM::Web::Middleware::VerifyMinecraft.new(
      SGM::Web.config.web_secret)) do |ctx|
    if username = ctx.request.query_params["username"]?
      begin
        user = SGM::Web.db.get_user(username)[0]
        if user && user.verification_code.nil? && user.discord_id
          ctx.status_code = 200
          "OK"
        else
          ctx.halt_plain "Not verified", 400
        end
      rescue ex
        ctx.halt_plain "Not verified", 400
      end
    else
      ctx.halt_plain "Missing username", 400
    end
  end

  Raze.config.host = "0.0.0.0"
  Raze.run
end
