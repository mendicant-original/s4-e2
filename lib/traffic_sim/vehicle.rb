module TrafficSim
  class Vehicle
    AsteroidCollision = Class.new(StandardError)
    VehicleCollision  = Class.new(StandardError)
    DeathByLaser      = Class.new(StandardError)
    LostInSpace       = Class.new(StandardError)

    InvalidCommand    = Class.new(StandardError)

    MAX_SPEED = 3
    MIN_SPEED = 0

    VALID_COMMANDS    = [:increase_speed, :decrease_speed, :face_north,
      :face_south, :face_east, :face_west, :move]

    def initialize(driver_name, map, position)
      @driver_name = driver_name
      @map         = map
      @position    = position
      @speed       = MIN_SPEED
      @facing      = Map::DIRECTIONS.first
    end

    attr_reader :speed, :facing, :driver_name
    attr_accessor :position

    def command(instruction)
      raise InvalidCommand unless VALID_COMMANDS.include?(instruction)
      self.send(instruction)
    end

    def increase_speed
      @speed += 1 if @speed < MAX_SPEED
    end

    def decrease_speed
      @speed -= 1 if @speed > MIN_SPEED
    end

    def face(direction)
      raise ArgumentError unless Map::DIRECTIONS.include?(direction)

      @facing = direction
    end

    def face_north
      face(:north)
    end

    def face_south
      face(:south)
    end

    def face_east
      face(:east)
    end

    def face_west
      face(:west)
    end

    def move
      dest = @map.destination(:origin => @position, :distance => @speed,
        :direction => @facing)

      raise LostInSpace unless dest
      raise AsteroidCollision unless @map.clear_path?(@position, dest)

      @map[*@position] = nil
      case @map[*dest]
      when Dock
        raise DeathByLaser unless @map[*dest].owned_by?(@driver_name)
        @map.vehicles.delete(@driver_name)
      when Vehicle
        raise VehicleCollision
      when nil
        @map[*dest] = self
        @position = dest
      else
        raise ArgumentError, "unknown object at destination"
      end
    end
  end
end

