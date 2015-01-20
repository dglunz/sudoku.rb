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
    block_rows = [['A', 'B', 'C'],['D', 'E', 'F'],['G', 'H', 'I']]
    block_cols = [[1, 2, 3],[4, 5, 6],[7, 8, 9]]
    row = block_rows.index { |br| br.include? selected.location[0] }
    col = block_cols.index { |bc| bc.include? selected.location[1] }
    block = combine(block_rows[row], block_cols[col])
    squares.select { |square| block.include? square.location }
  end

  def unit_lists
    { v: vertical_unit, h: horizontal_unit, b: block_unit }
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

TEST_GRID = "
          Grid 01
          003020600
          900305001
          001806400
          008102900
          700000008
          006708200
          002609500
          800203009
          005010300
"
a = Grid.new(TEST_GRID)
puts a.block_unit(a.squares.last)
