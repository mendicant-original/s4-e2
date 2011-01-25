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
        map_copy    = Marshal.load(Marshal.dump(map))
        strategy    = vehicle_strategies[v.driver_name]
        instruction = strategy.step(map_copy, k)

        v.command(instruction)
      end
    end
  end
end

