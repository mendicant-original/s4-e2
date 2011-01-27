module TrafficSim
  class Driver
    def initialize(driver_name, map)
      @driver_name = driver_name
      @map  = map
      @vehicle = map.vehicles[driver_name]
    end

    attr_reader :driver_name, :vehicle

    def step
      raise 'To be overriden by a subclass'
    end
  end
end

