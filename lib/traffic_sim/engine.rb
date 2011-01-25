module TrafficSim
  class Engine
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
          v.move
        end
      end
    end
  end
end

