require_relative '../test_helper.rb'

describe TrafficSim::Drivers::Wanderer do
  before(:each) do
    @wanderer = TrafficSim::Drivers::Wanderer.new
    @map      = TrafficSim::Map.new("#{TRAFFIC_SIM_BASEDIR}/data/maps/wanderer_tests.txt")
  end

  describe '#avoid_crash' do
    it 'should avoid inminent crash conditions' do
      assert_equal :increase_speed, @wanderer.step(@map, 'a')
      @map.vehicles['a'].command(:increase_speed)

      assert_equal :move, @wanderer.step(@map, 'a')
      @map.vehicles['a'].command(:move)

      refute_equal :face_north, @wanderer.step(@map, 'a')
    end
  end

  describe '#dock_if_we_can' do
    it 'should dock if own dock is around' do
      @map.vehicles['b'].command(:increase_speed)
      @map.vehicles['b'].command(:face_east)
      3.times { @map.vehicles['b'].command(:move) }

      # just below a dock, we should follow => :north & :move
      assert_equal :face_north, @wanderer.step(@map, 'b')
      @map.vehicles['b'].command(:face_north)

      assert_equal :move, @wanderer.step(@map, 'b')
      @map.vehicles['b'].command(:move)
    end
  end

  describe '#adjust_speed' do
    it 'should increase speed if speed = 0' do
      assert_equal 0, @map.vehicles['a'].speed
      assert_equal :increase_speed, @wanderer.step(@map, 'a')
    end

    it 'should do nothing if speed > 0' do
      assert_equal 0, @map.vehicles['a'].speed
      assert_equal :increase_speed, @wanderer.step(@map, 'a')
      @map.vehicles['a'].command(:increase_speed)

      refute_equal :increase_speed, @wanderer.step(@map, 'a')
    end

    it 'should decrease speed if in a emergency_situation' do
      @map.vehicles['c'].command(:increase_speed)
      @map.vehicles['c'].command(:face_south)
      @map.vehicles['b'].command(:increase_speed)
      @map.vehicles['b'].command(:face_east)
      4.times { @map.vehicles['b'].command(:move) }

      assert_equal :decrease_speed, @wanderer.step(@map, 'c')
      @map.vehicles['c'].command(:decrease_speed)
      @map.vehicles['b'].command(:move)

      assert_equal :increase_speed, @wanderer.step(@map, 'c')
      @map.vehicles['c'].command(:increase_speed)

      assert_equal :face_north, @wanderer.step(@map, 'c')
      @map.vehicles['c'].command(:face_north)
    end
  end

  describe '#emergency_turn' do
    it 'should get us facing a safe direction' do
      @map.vehicles['c'].command(:increase_speed)
      @map.vehicles['c'].command(:face_south)

      assert_equal :face_north, @wanderer.step(@map, 'c')
    end
  end

  describe '#turn_to_dock_direction' do
    it 'should return docks direction' do
      ['a', 'b', 'c'].each { |l| @map.vehicles[l].command(:increase_speed) }

      @map.vehicles['a'].command(:face_south)
      @map.vehicles['a'].command(:move)
      @map.vehicles['a'].command(:move)

      @map.vehicles['b'].command(:face_west)
      @map.vehicles['b'].command(:move)
      @map.vehicles['b'].command(:face_north)
      @map.vehicles['b'].command(:move)

      @map.vehicles['c'].command(:face_north)
      @map.vehicles['c'].command(:move)
      @map.vehicles['c'].command(:face_west)
      @map.vehicles['c'].command(:move)

      assert_equal :face_north, @wanderer.step(@map, 'a')
      assert_equal :face_east, @wanderer.step(@map, 'b')
      assert_equal :face_south, @wanderer.step(@map, 'c')
    end
  end
end

