module TrafficSim
  class Map
    DIRECTIONS = [:north, :south, :east, :west]
    ASTEROID   = :asteroid

    def initialize(filename)
      @vehicles = {}
      @data     = parse_map_from_file(filename)
    end

    attr_reader :vehicles

    def [](row, col)
      @data[row][col]
    end

    def []=(row, col, val)
      @data[row][col] = val
    end

    def rows
      data
    end

    def columns
      data.transpose
    end

    def destination(params)
      row, col  = params[:origin]
      distance  = params[:distance]
      direction = params[:direction]

      dest_point = case direction
      when :north
        [row - distance, col]
      when :south
        [row + distance, col]
      when :east
        [row, col + distance]
      when :west
        [row, col - distance]
      end

      return nil if row < 0 || row >= rows.length
      return nil if col < 0 || col >= columns.length

      dest_point
    end

    def clear_path?(a,b)
      row_a, col_a = a
      row_b, col_b = b

      case
      when row_a == row_b
        start_col, end_col = [col_a, col_b].sort
        rows[row_a][start_col..end_col].none? { |e| e == ASTEROID }
      when col_a == col_b
        start_row, end_row = [row_a, row_b].sort
        columns[col_a][start_row..end_row].none? { |e| e == ASTEROID }
      else
        raise ArgumentError
      end
    end

    def vehicle_for?(position, driver_name)
      map_position = self[*position]
      map_position.is_a?(Vehicle) && map_position.driver_name == driver_name
    end

    def dock_for?(position, driver_name)
      map_position = self[*position]
      map_position.is_a?(Dock) && map_position.owned_by?(driver_name)
    end

    def surroundings(position)
      surroundings = []

      (-1..1).each do |row_offset|
        (-1..1).each do |column_offset|
          map_i = position[0] + row_offset
          map_j = position[1] + column_offset

          unless row_offset == 0 && column_offset == 0 # do not include itself
            surroundings << [map_i, map_j]
          end
        end
      end

      surroundings
    end

    def to_s
      data.map do |row|
        output = row.map do |obj|
          case obj
          when nil
            " "
          when Map::ASTEROID
            "#"
          when Vehicle
            obj.driver_name
          when Dock
            obj.owner.upcase
          end
        end

        output.join
      end.join("\n")
    end

    private

    attr_reader :data

    def parse_map_from_file(filename)
      File.read(filename).lines.map.with_index do |row, row_i|
        row.chomp.chars.map.with_index do |symbol, col_i|
          convert_symbol(symbol, [row_i, col_i])
        end
      end
    end

    def convert_symbol(symbol, position)
      case symbol
      when "#"
        ASTEROID
      when /[A-Z]/
        Dock.new(symbol.downcase)
      when /[a-z]/
        vehicles[symbol] = Vehicle.new(symbol, position)
      when " "
        nil
      else
        raise
      end
    end

  end
end
