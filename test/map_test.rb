require_relative "test_helper"

describe TrafficSim::Map do
  it "should be able to create asteroids from a map file" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")

    asteroid = TrafficSim::Map::ASTEROID

    assert map.rows[0].all? { |e| e == asteroid }
    assert map.rows[map.rows.length - 1].all? { |e| e == asteroid }
    assert map.columns[0].all? { |e| e == asteroid }
    assert map.columns[map.columns.length - 1].all? { |e| e == asteroid }
  end

  it "should be able to create docks from a map file" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")
    dest_a = map[4,13]
    dest_b = map[5,4]

    assert dest_a.owned_by?("a")
    assert !dest_a.owned_by?("b")

    assert dest_b.owned_by?("b")
    assert !dest_b.owned_by?("a")
  end

  it "should be able to create vehicles from a map file" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")

    vehicle_a = map[11,6]
    vehicle_b = map[9, 17]

    assert_equal "a", vehicle_a.driver_name
    assert_equal "b", vehicle_b.driver_name
  end

  it "should be able to find out who is the owner of the vehicle" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")

    assert map.vehicle_for?([11,6], 'a')
    refute map.vehicle_for?([11,6], 'b')
  end

  it "should be able to find out who is the owner of the dock" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/simple.txt")

    assert map.dock_for?([4,13], 'a')
    refute map.dock_for?([4,13], 'b')
  end

  it "should be able to calculate the surroundings of an element" do
    map = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/about_to_die.txt")

    surroundings = map.surroundings([5, 13])

    assert_nil                     map[*surroundings[0]]
    assert_equal TrafficSim::Dock, map[*surroundings[1]].class
    assert_nil                     map[*surroundings[2]]
    assert_nil                     map[*surroundings[3]]
    assert_nil                     map[*surroundings[4]]
    assert_nil                     map[*surroundings[5]]
    assert_equal TrafficSim::Dock, map[*surroundings[6]].class
    assert_nil                     map[*surroundings[7]]
  end
end
