require "socket"
require "io/hexdump"
require "./packet"
require "./commands"

class RCON::Client
  include Commands

  class Error < Exception
  end

  def self.connect(ip, port, password)
    client = new(ip, port)
    client.login(password)
    client
  end

  def self.new(ip, port)
#    new(IO::Hexdump.new(TCPSocket.new(ip, port), output: STDOUT, read: true))
    new(TCPSocket.new(ip, port))
  end

  def initialize(@socket : IO)
    @request_id = 0
    @logged_in = false
  end

  private def next_request_id
    @request_id += 1
  end

  private def send(packet : Packet)
    (@write_mutex ||= Mutex.new).synchronize do
      @socket.write_bytes(packet, IO::ByteFormat::LittleEndian)
    end
  end

  private def receive
    response = @socket.read_bytes(Packet, IO::ByteFormat::LittleEndian)
    raise Error.new("Authentication failed") if response.request_id == -1
    response
  end

  def close
    @socket.close
  end

  def login(password)
    packet = Packet.new(next_request_id, :login, password)
    send(packet)
    receive
    @logged_in = true
  end

  def execute(command : String)
    raise Error.new("You must be logged in to execute commands!") unless @logged_in
    packet = Packet.new(next_request_id, :command, command)
    send(packet)
    receive
  end

  def execute(command : String, *args)
    string = args.to_a.unshift(command).join(' ')
    execute(string)
  end
end
