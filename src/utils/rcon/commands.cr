module RCON::Commands
  def tell_raw(player : String, object)
    execute("tellraw", player, object.to_json)
  end

  def players
    execute("list")
  end

  def sudo(player : String, command : String)
    execute("osudo", player, command)
  end
end
