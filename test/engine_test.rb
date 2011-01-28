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
  
  describe '#add_vehicle_strategy' do
    before(:each) do
      @map        = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")
      @engine     = TrafficSim::Engine.new(@map)
      @strategy   = TrafficSim::Drivers::DummyForwarder.new('a', @map)
      @strategy2  = TrafficSim::Drivers::DummyForwarder.new('b', @map)
    end

    it 'should let us add a vehicle strategies to the engine' do
      @engine.add_vehicle_strategy(@strategy)      
      assert @strategy, @engine.vehicle_strategies.last

      @engine.add_vehicle_strategy(@strategy2)
      assert @strategy2, @engine.vehicle_strategies.last
    end

    it 'should raise an exception if adding a duplicate strategy' do
      @engine.add_vehicle_strategy(@strategy)
      @engine.add_vehicle_strategy(@strategy2)

      assert_raises TrafficSim::Engine::StrategyAlreadyExists do
        @engine.add_vehicle_strategy(@strategy)
      end

      assert_raises TrafficSim::Engine::StrategyAlreadyExists do
        @engine.add_vehicle_strategy(@strategy2)
      end      
    end
  end
end

