module TrafficSim
  class Vehicle
    MAX_SPEED = 3
    MIN_SPEED = 0

    def initialize(driver_name, position)
      @driver_name = driver_name
      @position    = position
      @speed       = MIN_SPEED
      @facing      = Map::DIRECTIONS.first
    end

    attr_reader :speed, :facing, :driver_name
    attr_accessor :position

    def speed_up
      @speed += 1 if @speed < MAX_SPEED
    end

    def slow_down
      @speed -= 1 if @speed > MIN_SPEED
    end

    def face(direction)
      raise ArgumentError unless Map::DIRECTIONS.include?(direction)

      @facing = direction 
    end

  end
end
