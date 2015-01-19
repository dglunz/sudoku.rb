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
    @rows.flat_map { |x| @cols.map { |y| [x,y] } }
  end

  def create_squares
    grid_layout.map { |location| Square.new(location) }
  end

  def fill_squares(puzzle)
    create_squares.each_with_index do |square, index|
      square.value = puzzle[index] if puzzle[index] != 0
    end
  end
end

class Square
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
#puts a.squares
#a.squares.each { |s| require 'pry'; binding.pry;  puts s.value }
