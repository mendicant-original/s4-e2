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

  it "should not kill vehicle by laser when it tries to go to its own dock" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_dock.txt")

    vehicle_strategies = { "a" => TrafficSim::Drivers::Sample.new }

    engine = TrafficSim::Engine.new(map, vehicle_strategies)

    # In this case, the vehicle won't stop and get killed on the dock,
    # it will run up until it hits an asteroid
    assert_raises TrafficSim::Engine::AsteroidCollision do
      engine.run {}
    end
  end
end
