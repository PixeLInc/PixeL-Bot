struct RCON::Packet
  class Error < Exception
  end

  enum Type
    Response = 0
    Command  = 2
    Login    = 3
  end

  PADDING = Bytes[0, 0]

  getter request_id : Int32

  getter type : Type

  getter payload : Bytes

  def initialize(@request_id : Int32, @type : Type, payload)
    @payload = payload.to_slice
  end

  # Reads a `Packet` from the given IO.
  def self.from_io(io, format)
    remainder_length = io.read_bytes(Int32, format)

    request_id = io.read_bytes(Int32, format)
    type = Type.new(io.read_bytes(Int32, format))

    payload_length = remainder_length - sizeof(Int32) * 2 - PADDING.size
    payload_buffer = Bytes.new(payload_length)
    io.read(payload_buffer)

    padding_bytes = Bytes.new(PADDING.size)
    io.read(padding_bytes)
    raise Error.new("Unexpected padding bytes: #{padding_bytes}") unless padding_bytes == PADDING

    new(request_id, type, payload_buffer)
  end

  # Writes a `Packet` to the given IO.
  def to_io(io, format)
    remainder_size = sizeof(Int32) * 2 + @payload.size + PADDING.size
    total_size = remainder_size + sizeof(Int32)
    buffer = Bytes.new(remainder_size + sizeof(Int32))

    format.encode(remainder_size, buffer[0, 4])
    format.encode(@request_id, buffer[4, 4])
    format.encode(@type.value, buffer[8, 4])
    @payload.copy_to(buffer[12, @payload.size])

    io.write(buffer)
  end
end
