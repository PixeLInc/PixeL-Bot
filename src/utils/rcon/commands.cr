module RCON::Commands

  def tell_raw(player : String, object)
    execute("tellraw", player, object.to_json)
  end

  def players
    execute("list")
  end

end
