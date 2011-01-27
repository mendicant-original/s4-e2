module TrafficSim
  module Drivers
    class DummyForwarder < TrafficSim::Driver
      def step
        return :increase_speed if vehicle.speed == 0
        :move
      end
    end
  end
end

