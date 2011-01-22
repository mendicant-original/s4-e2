module TrafficSim
  class Engine

    AsteroidCollision = Class.new(StandardError)
    VehicleCollision  = Class.new(StandardError)
    DeathByLaser      = Class.new(StandardError)
    LostInSpace       = Class.new(StandardError)

    def initialize(map, vehicle_strategies)
      @vehicle_strategies = vehicle_strategies
      @map                = map
    end

    attr_reader :vehicle_strategies, :map

    def run
      until map.vehicles.empty?
        step
        yield map
      end
    end

    def step
      map.vehicles.each do |k,v|
        map_copy = Marshal.load(Marshal.dump(map))
        instruction = vehicle_strategies[v.driver_name].step(map_copy, k)

        case instruction
        when :increase_speed
          v.speed_up
        when :decrease_speed
          v.slow_down
        when :face_north
          v.face(:north)
        when :face_south
          v.face(:south)
        when :face_east
          v.face(:east)
        when :face_west
          v.face(:west)
        when :launch
          move(v)
        end
      end
    end

    def move(v)
      origin = v.position
      dest   = map.destination(:origin    => origin,
                               :distance  => v.speed,
                               :direction => v.facing)

      raise LostInSpace unless dest
      raise AsteroidCollision unless map.clear_path?(origin, dest)

      map[*origin] = nil

      case map[*dest]
      when Dock
        raise DeathByLaser unless map[*dest].owned_by?(v.driver_name)
        map.vehicles.delete(v.driver_name)
      when Vehicle
        raise VehicleCollision
      when nil
        map[*dest] = v
        v.position = dest
      else
        raise ArgumentError, "unknown object at destination"
      end
    end
  end
end
