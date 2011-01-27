module TrafficSim
  class Engine
    def initialize(map, strategies=[])
      @map                = map
      @vehicle_strategies = strategies
    end

    attr_reader :map, :vehicle_strategies

    def add_vehicle_strategy(strategy)
      @vehicle_strategies.push(strategy)
    end

    def run
      until map.vehicles.empty?
        step
        yield map
      end
    end

    def step
      @vehicle_strategies.each do |strategy|
        next unless strategy.vehicle
        instruction = strategy.step
        strategy.vehicle.command(instruction)
      end
    end
  end
end

