module TrafficSim
  class Dock
    def initialize(owner)
      @owner = owner
    end

    attr_reader :owner

    def owned_by?(driver_name)
      driver_name == owner
    end
  end
end
