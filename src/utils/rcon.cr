require "socket"
require "io/hexdump"

module SGM::Bot
  class RCONClient
    private getter socket : IO

    struct Packet
      enum Type
        MultiPacket
        Command = 2
        Login = 3
      end

      getter length     : Int32
      getter request_id : Int32
      getter type       : Type
      getter payload    : Bytes

      def initialize(length : Int32, request_id : Int32, type : Type, payload : Bytes)
        @length = length
        @request_id = request_id
        @type = type
        @payload = payload
      end

      def self.from_io(io, format)
        length = io.read_bytes(Int32, format) # 0 bytes

        request_id = io.read_bytes(Int32, format) # 4 bytes
        type = Type.new(io.read_bytes(Int32, format)) # 8 bytes
        payload_size = length - sizeof(Int32) * 2 - 2 # 8 bytes read since length

        bytes = Bytes.new(payload_size)
        io.read(bytes)

        padding = Bytes.new(2)
        io.read(padding)

        raise "Malformed Packet, got #{padding}" unless padding == Bytes[0, 0]

        new(length, request_id, type, bytes)
      end
    end

    def self.new(ip, port, password)
      new(IO::Hexdump.new(TCPSocket.new(ip, port), output: STDOUT, read: true), password)
    end

    def initialize(@socket : IO, @password : String)
    end

    def authenticate
      puts "Sending authentication..."
      send(:login, @password.to_slice)
    end

    private def sync_write(bytes : Bytes)
      (@write_mutex ||= Mutex.new).synchronize do
        @socket.write(bytes)
      end
    end

    def send(type : Packet::Type, bytes : Bytes)
      puts "Sending #{type}: #{String.new(bytes)}"
      request_id = 1
      length = sizeof(Int32) * 2 + bytes.size + 2

      buffer = Bytes.new(length + sizeof(Int32))
      IO::ByteFormat::LittleEndian.encode(length, buffer[0, 4])
      IO::ByteFormat::LittleEndian.encode(request_id, buffer[4, 4])
      IO::ByteFormat::LittleEndian.encode(type.value, buffer[8, 4])
      bytes.copy_to(buffer[12, bytes.size])
      sync_write(buffer)

      @socket.read_bytes(Packet)
    end
  end
end
