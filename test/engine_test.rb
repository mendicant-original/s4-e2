require_relative "test_helper"

describe TrafficSim::Engine do

  before(:each) do
  end

  it "should kill vehicle by laser when it tries to go to another's dock" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_die.txt")

    vehicle_strategies = { "a" => TrafficSim::Drivers::Sample.new }

    engine = TrafficSim::Engine.new(map, vehicle_strategies)

    # In the first run, Sample driver will throttle.
    # In the second run, the Sample driver will try to move, and
    # should be stopped by DeathByLaser
    assert_raises TrafficSim::Engine::DeathByLaser do
      engine.run {}
    end
  end

  it "should actually let vehicle dock when it tries entering its own" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_dock.txt")

    vehicle_strategies = { "a" => TrafficSim::Drivers::Sample.new }

    engine = TrafficSim::Engine.new(map, vehicle_strategies)
    engine.step
    engine.step
    assert engine.map.vehicles.empty?
  end
end
