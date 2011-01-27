require_relative '../test_helper.rb'

describe TrafficSim::Drivers::Wanderer do
  before(:each) do
    @map        = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/wanderer_tests.txt")

    @wanderer_a = TrafficSim::Drivers::Wanderer.new('a', @map)
    @wanderer_b = TrafficSim::Drivers::Wanderer.new('b', @map)
    @wanderer_c = TrafficSim::Drivers::Wanderer.new('c', @map)
  end

  describe '#avoid_crash' do
    it 'should avoid inminent crash conditions' do
      assert_equal :increase_speed, @wanderer_a.step
      @wanderer_a.vehicle.command(:increase_speed)

      assert_equal :move, @wanderer_a.step
      @wanderer_a.vehicle.command(:move)

      refute_equal :face_north, @wanderer_a.step
    end
  end

  describe '#dock_if_we_can' do
    it 'should dock if own dock is around' do
      @wanderer_b.vehicle.command(:increase_speed)
      @wanderer_b.vehicle.command(:face_east)
      3.times { @wanderer_b.vehicle.command(:move) }

      # just below a dock, we should follow => :north & :move
      assert_equal :face_north, @wanderer_b.step
      @wanderer_b.vehicle.command(:face_north)

      assert_equal :move, @wanderer_b.step
      @wanderer_b.vehicle.command(:move)
    end
  end

  describe '#adjust_speed' do
    it 'should increase speed if speed = 0' do
      assert_equal 0, @wanderer_a.vehicle.speed
      assert_equal :increase_speed, @wanderer_a.step
    end

    it 'should do nothing if speed > 0' do
      assert_equal 0, @wanderer_a.vehicle.speed
      assert_equal :increase_speed, @wanderer_a.step
      @wanderer_a.vehicle.command(:increase_speed)

      refute_equal :increase_speed, @wanderer_a.step
    end

    it 'should decrease speed if in a emergency_situation' do
      @wanderer_c.vehicle.command(:increase_speed)
      @wanderer_c.vehicle.command(:face_south)
      @wanderer_b.vehicle.command(:increase_speed)
      @wanderer_b.vehicle.command(:face_east)
      4.times { @wanderer_b.vehicle.command(:move) }

      assert_equal :decrease_speed, @wanderer_c.step
      @wanderer_c.vehicle.command(:decrease_speed)
      @wanderer_b.vehicle.command(:move)

      assert_equal :increase_speed, @wanderer_c.step
      @wanderer_c.vehicle.command(:increase_speed)

      assert_equal :face_north, @wanderer_c.step
      @wanderer_c.vehicle.command(:face_north)
    end
  end

  describe '#emergency_turn' do
    it 'should get us facing a safe direction' do
      @wanderer_c.vehicle.command(:increase_speed)
      @wanderer_c.vehicle.command(:face_south)

      assert_equal :face_north, @wanderer_c.step
    end
  end

  describe '#turn_to_dock_direction' do
    it 'should return docks direction' do
      @wanderer_a.vehicle.command(:increase_speed)
      @wanderer_b.vehicle.command(:increase_speed)
      @wanderer_c.vehicle.command(:increase_speed)

      @wanderer_a.vehicle.command(:face_south)
      @wanderer_a.vehicle.command(:move)
      @wanderer_a.vehicle.command(:move)

      @wanderer_b.vehicle.command(:face_west)
      @wanderer_b.vehicle.command(:move)
      @wanderer_b.vehicle.command(:move)

      @wanderer_c.vehicle.command(:face_north)
      @wanderer_c.vehicle.command(:move)
      @wanderer_c.vehicle.command(:face_east)
      @wanderer_c.vehicle.command(:move)
      @wanderer_c.vehicle.command(:move)
      @wanderer_c.vehicle.command(:move)

      assert_equal :face_north, @wanderer_a.step
      assert_equal :face_east, @wanderer_b.step
      assert_equal :face_south, @wanderer_c.step
    end
  end
end

