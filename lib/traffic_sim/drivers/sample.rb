module TrafficSim
  module Drivers
    class Sample
      def initialize
        @movements = [:increase_speed, :move].cycle
      end

      def step(map, driver_name)
        @movements.next
      end
    end
  end
end

