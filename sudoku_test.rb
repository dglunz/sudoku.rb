gem 'minitest'
gem 'pry'

require 'minitest/autorun'
require 'minitest/pride'
require './sudoku'

class SudokuTest < Minitest::Base
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

  def test_it_can_fill_in_a_grid

  end

  def test_it_can_flatten_a_grid

  end

  def test_it_can_solve_a_given_grid

  end
end


