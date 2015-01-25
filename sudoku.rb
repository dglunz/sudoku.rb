class Grid
  attr_reader :squares, :puzzle, :rows, :cols

  def initialize(puzzle)
    @rows = ('A'..'I').to_a
    @cols = (1..9).to_a
    @puzzle = clean(puzzle)
    @squares = fill_given_squares(@puzzle)
  end

  def fitness
    total = 0
    units = [horizontal, vertical, block]
    units.each do |unit|
      total += specific_fitness(unit)
    end
    total / 3.0
  end

  def specific_fitness(unit)
    total = 0
    unit.each do |set|
        set_values = set.map(&:value)
        total += (set_values.uniq.count / 9.0)
    end
    total / 9.0
  end

  def clean(puzzle)
    puzzle.to_s.scan(/\d{9}/).join.chars.map(&:to_i)
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

  def find_and_replace(replacement)
    square = squares.find { |square| square.location == replacement.location }
    square.value = replacement.value
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
        square.value = data[count].to_i
        count -= 1
      end
    end
  end

  def mutatable_squares
    squares.reject(&:protected?)
  end

  def chromosome
    mutatable_squares.map(&:value).reverse
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

  def horizontal
    horizontal = @rows.zip(Array.new(9,1))
    vertical = Array.new(9,"A").zip(@cols)
    horizontal.map { |h| vertical_unit(h) }
  end

  def vertical
    vertical = Array.new(9,"A").zip(@cols)
    horizontal = @rows.zip(Array.new(9,1))
    vertical.map { |v| horizontal_unit(v) }
  end

  def block
    block = combine(["A", "D", "G"], [1, 4, 7])
    block.map { |b| block_unit(b) }
  end
 
  def print
    cache_squares = squares
    board_string_thingy = "╔═══════════╦═══════════╦═══════════╗\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n║           ║           ║           ║\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n║           ║           ║           ║\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n╠═══════════╬═══════════╬═══════════╣\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n║           ║           ║           ║\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n║           ║           ║           ║\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n╠═══════════╬═══════════╬═══════════╣\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n║           ║           ║           ║\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n║           ║           ║           ║\n║ 0   0   0 ║ 0   0   0 ║ 0   0   0 ║\n╚═══════════╩═══════════╩═══════════╝"
    board_string_thingy.gsub!("0").with_index do |spot, index|
      color = correct?(cache_squares[index]) ? 32 : 31
      "\e[#{color}m#{cache_squares[index].value}\e[0m"
    end
    puts board_string_thingy
  end

  def correct?(square)
    (vertical_unit(square.location) + horizontal_unit(square.location) + block_unit(square.location)).flatten.map(&:value).count(square.value) == 3
  end
end

class Square
  attr_reader :location
  attr_accessor :value

  def initialize(location, value=0)
    @location  = location
    @value     = value
  end

  def protect!
    @protected = true
  end

  def protected?
    @protected
  end
end
