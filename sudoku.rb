class Grid
  attr_reader :squares, :puzzle

  def initialize(puzzle)
    @rows = ('A'..'I').to_a
    @cols = (1..9).to_a
    @puzzle = clean(puzzle)
    @squares = fill_given_squares(@puzzle)
  end

  def fitness
    total = 0
    units.each do |unit|
      unit.each do |set|
        set_values = set.map(&:value)
        total += (set_values.uniq.count / 9.0)
      end
    end
    total / 27.0
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

  def fill_given_squares(puzzle)
    create_squares.each_with_index do |square, index|
      if puzzle[index] != 0
        square.protect!
        square.value = puzzle[index]     
      end
    end
  end

  def fill_search_squares(data)
    count = data.length-1
    squares.each do |square, index|
      if !square.protected?
        square.value = data[count] 
        count -= 1
      end
    end
  end

  def empty_squares
    squares.reject(&:protected?)
  end

  def vertical_unit(location)
    squares.select { |square| square.location[0] == location[0] }
  end

  def horizontal_unit(location)
    squares.select { |square| square.location[1] == location[1] }
  end

  def block_unit(location)
    block = combine(block_row(location), block_col(location))
    squares.select { |square| block.include? square.location }
  end

  def block_row(location)
    block_rows = [['A', 'B', 'C'],['D', 'E', 'F'],['G', 'H', 'I']]
    block_rows.find { |br| br.include? location[0] }
  end

  def block_col(location)
    block_cols = [[1, 2, 3],[4, 5, 6],[7, 8, 9]]
    block_cols.find { |bc| bc.include? location[1] }
  end

  def units
    horizontal = @rows.zip(Array.new(9,1))
    vertical   = Array.new(9,"A").zip(@cols)
    block      = combine(["A", "D", "G"], [1, 4, 7])
    horizontals = horizontal.map { |h| vertical_unit(h) }
    verticals   = vertical.map   { |v| horizontal_unit(v)   }
    blocks      = block.map      { |b| block_unit(b)      }
    [horizontals, verticals, blocks] 
  end

  def unit_lists(selected)
    { v: vertical_unit(selected), 
      h: horizontal_unit(selected), 
      b: block_unit(selected)
    }
  end
end

class Square
  attr_reader :location, :protected
  attr_accessor :value

  def initialize(location, value=0)
    @location  = location
    @value     = value
    @protected = false
  end

  def protect!
    @protected = true
  end

  def protected?
    protected
  end
end
