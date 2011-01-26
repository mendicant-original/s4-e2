require_relative "test_helper"

describe TrafficSim::Vehicle do
  describe '#initialize' do
    it 'initializes a vehicle with its mandatory params' do
      map = MiniTest::Mock.new

      assert_raises ArgumentError do
        v = TrafficSim::Vehicle.new
        v = TrafficSim::Vehicle.new(:map => map)
        v = TrafficSim::Vehicle.new(:position => [0,0])
        v = TrafficSim::Vehicle.new(:name => 'a')
        v = TrafficSim::Vehicle.new(:map => map, :position => [0,0])
        v = TrafficSim::Vehicle.new(:map => map, :name => 'a')
        v = TrafficSim::Vehicle.new(:position => [0,0], :name => 'a')
      end

      v = TrafficSim::Vehicle.new(:map => map, :position => [3,2], :name => 'a')
      assert_equal 'a', v.driver_name
      assert_equal [3,2], v.position
      assert_equal TrafficSim::Vehicle::MIN_SPEED, v.speed
      assert_equal TrafficSim::Map::DIRECTIONS.first, v.facing
    end
  end

  describe 'instance methods' do
    before(:each) do
      @mocked_map = MiniTest::Mock.new
      @vehicle = TrafficSim::Vehicle.new(:map => @mocked_map, :position => [1,1],
        :name => 'a')
    end

    describe '#increase_speed' do
      it 'should progressively increase speed' do
        @vehicle.increase_speed
        assert_equal TrafficSim::Vehicle::MIN_SPEED+1, @vehicle.speed

        @vehicle.increase_speed
        assert_equal TrafficSim::Vehicle::MIN_SPEED+2, @vehicle.speed
      end

      it 'should not exceed defined maximum' do
        (TrafficSim::Vehicle::MAX_SPEED*2).times { @vehicle.increase_speed }
        assert_equal TrafficSim::Vehicle::MAX_SPEED, @vehicle.speed
      end
    end

    describe '#decrease_speed' do
      it 'should progressively decrease speed' do
        TrafficSim::Vehicle::MAX_SPEED.times { @vehicle.increase_speed }

        @vehicle.decrease_speed
        assert_equal TrafficSim::Vehicle::MAX_SPEED-1, @vehicle.speed

        @vehicle.decrease_speed
        assert_equal TrafficSim::Vehicle::MAX_SPEED-2, @vehicle.speed
      end

      it 'should fall below defined minimum' do
        (TrafficSim::Vehicle::MAX_SPEED*2).times { @vehicle.decrease_speed }
        assert_equal TrafficSim::Vehicle::MIN_SPEED, @vehicle.speed
      end
    end

    describe '#facing' do
      it 'should raise ArgumentError when unrecognized direction' do
        assert_raises ArgumentError do
          @vehicle.face(:forward)
        end
      end

      it 'should change direction' do
        @vehicle.face(:north)
        assert_equal :north, @vehicle.facing

        @vehicle.face(:south)
        assert_equal :south, @vehicle.facing

        @vehicle.face(:east)
        assert_equal :east, @vehicle.facing

        @vehicle.face(:west)
        assert_equal :west, @vehicle.facing
      end
    end

    describe '#command' do
      # TODO: write this spec
    end

    describe '#move' do
      it 'should raise LostInSpace when out-of-bounds ' do
        # dunno if this is acceptable or should go everywhere else
        def @mocked_map.destination(args={})
          return nil
        end

        assert_raises TrafficSim::Vehicle::LostInSpace do
          @vehicle.move
        end
      end

      # TODO: complete this
    end
  end
end

