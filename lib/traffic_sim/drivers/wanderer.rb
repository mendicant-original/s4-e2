module TrafficSim
  module Drivers
    class Wanderer
      def initialize
        @map          = nil
        @vehicle      = nil
        @name         = nil

        @must_brake   = false

        @action       = nil
      end

      attr_reader :name

      def step(map, driver_name)
        # get data
        @map        = map
        @name       = driver_name
        @vehicle    = map.vehicles[name]

        # compute next action
        @action = avoid_crash || dock_if_we_can || adjust_speed || turn_to_dock_direction || :move
      end

      # proxy methods for vehicle to avoid vehicle.xxx everywhere
      def speed
        @vehicle.speed if @vehicle
      end

      def direction
        @vehicle.facing if @vehicle
      end

      def position
        @vehicle.position if @vehicle
      end

      def dock_position
        @dock_position ||= find_own_dock
      end

      def direction_of(point)
        cy, cx = position
        dy, dx = point

        if (cx - dx).abs > (cy - dy).abs
          dx > cx ? :east : :west
        else
          dy > cy ? :south : :north
        end
      end

      def avoid_crash
        @must_brake = false

        where = @map.destination(:origin => position, :distance => speed,
          :direction => direction)
        unless clear_path?(position, where)
          @must_brake = true
          return (emergency_turn || adjust_speed)
        end

        false
      end

      def dock_if_we_can
        TrafficSim::Map::DIRECTIONS.each do |at|
          where = @map.destination(:origin => position, :distance => speed,
            :direction => at)
          what  = @map[*where]

          return (turn_to_dock_direction || adjust_speed || :move) if is_my_dock?(what)
        end

        false
      end

      def adjust_speed
        return :decrease_speed if must_brake?
        return :increase_speed if speed == TrafficSim::Vehicle::MIN_SPEED

        false
      end

      def emergency_turn
        other = TrafficSim::Map::DIRECTIONS.reject { |d| d == direction }.shuffle
        other.each do |new_dir|
          where = @map.destination(:origin => position, :distance => speed,
            :direction => new_dir)
          return "face_#{new_dir}".to_sym if clear_path?(position, where)
        end

        false
      end

      def turn_to_dock_direction
        target = direction_of(dock_position)
        where  = @map.destination(:origin => position, :distance => speed,
          :direction => target)
        return "face_#{target}".to_sym if clear_path?(position, where) && target != direction

        false
      end

      protected

      attr_reader :must_brake

      def must_brake?
        must_brake
      end

      def find_own_dock
        @map.rows.map.with_index do |row, y|
          row.map.with_index do |e, x|
            return [y,x] if is_my_dock?(e)
          end
        end
      end

      def is_my_dock?(object)
        object.kind_of?(Dock) && object.owned_by?(@name)
      end

      def is_my_vehicle?(object)
        object.kind_of?(Vehicle) && object.driver_name == name
      end

      def obstacles_in_path(a,b)
        row_a, col_a = a
        row_b, col_b = b

        objects = case
        when row_a == row_b
          start_col, end_col = [col_a, col_b].sort
          @map.rows[row_a][start_col..end_col].compact
        when col_a == col_b
          start_row, end_row = [row_a, row_b].sort
          @map.columns[col_a][start_row..end_row].compact
        else
          raise ArgumentError
        end

        objects.reject { |e| is_my_vehicle?(e) || is_my_dock?(e) }
      end

      def clear_path?(a,b)
        obstacles_in_path(a,b).empty?
      end
    end
  end
end

