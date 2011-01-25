require_relative "test_helper"

describe TrafficSim::Engine do

  before(:each) do
    # an "inline" driver which only goes forward
    @forward_driver = Object.new
    def @forward_driver.step(map, driver_name)
      vehicle = map.vehicles[driver_name]
      return :increase_speed if vehicle.speed == 0
      :move
    end
  end

  it "should kill vehicle by laser when it tries to go to another's dock" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_die.txt")

    vehicle_strategies = { "a" => @forward_driver }

    engine = TrafficSim::Engine.new(map, vehicle_strategies)

    # In the first run, Sample driver will throttle.
    # In the second run, the Sample driver will try to move, and
    # should be stopped by DeathByLaser
    assert_raises TrafficSim::Vehicle::DeathByLaser do
      engine.run {}
    end
  end

  it "should actually let vehicle dock when it tries entering its own" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_dock.txt")

    vehicle_strategies = { "a" => @forward_driver }

    engine = TrafficSim::Engine.new(map, vehicle_strategies)
    engine.step
    engine.step
    assert engine.map.vehicles.empty?
  end
end

