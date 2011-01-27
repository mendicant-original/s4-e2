require_relative "test_helper"

describe TrafficSim::Engine do
  it "should kill vehicle by laser when it tries to go to another's dock" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_die.txt")

    engine = TrafficSim::Engine.new(map)
    engine.add_vehicle_strategy(TrafficSim::Drivers::DummyForwarder.new('a', map))

    # In the first run, Sample driver will throttle.
    # In the second run, the Sample driver will try to move, and
    # should be stopped by DeathByLaser
    assert_raises TrafficSim::Vehicle::DeathByLaser do
      engine.run {}
    end
  end

  it "should actually let vehicle dock when it tries entering its own" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_dock.txt")

    engine = TrafficSim::Engine.new(map)
    engine.add_vehicle_strategy(TrafficSim::Drivers::DummyForwarder.new('a', map))

    engine.step
    engine.step
    assert engine.map.vehicles.empty?
  end
end

