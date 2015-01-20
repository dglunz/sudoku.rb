class Grid
  attr_reader :squares, :puzzle

  def initialize(puzzle)
    @rows = ('A'..'I').to_a
    @cols = (1..9).to_a
    @puzzle = clean(puzzle)
    @squares = fill_squares(@puzzle)
  end

  def clean(puzzle)
    puzzle.scan(/\d{9}/).join.chars.map(&:to_i)
  end

  def grid_layout
    combine(@rows, @cols)
  end

  def combine(rows, cols)
    rows.flat_map { |x| cols.map { |y| [x,y] } }
  end

  def create_squares
    grid_layout.map { |location| Square.new(location) }
  end

  def fill_squares(puzzle)
    create_squares.each_with_index do |square, index|
      square.value = puzzle[index] if puzzle[index] != 0
    end
  end

  def vertical_unit(selected)
    squares.select { |square| square.location[0] == selected.location[0] }
  end

  def horizontal_unit(selected)
    squares.select { |square| square.location[1] == selected.location[1] }
  end

  def block_unit(selected)
    block = combine(block_row(selected), block_col(selected))
    squares.select { |square| block.include? square.location }
  end

  def block_row(selected)
    block_rows = [['A', 'B', 'C'],['D', 'E', 'F'],['G', 'H', 'I']]
    block_rows.find { |br| br.include? selected.location[0] }
  end

  def block_col(selected)
    block_cols = [[1, 2, 3],[4, 5, 6],[7, 8, 9]]
    block_cols.find { |bc| bc.include? selected.location[1] }
  end

  def unit_lists(selected)
    { v: vertical_unit(selected), 
      h: horizontal_unit(selected), 
      b: block_unit(selected)
    }
  end
end

class Square
  attr_reader :location
  attr_accessor :value

  def initialize(location, value=0)
    @location = location
    @value    = value
  end
end

