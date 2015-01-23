require './genetic_algorithm'
require './sudoku'

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
TEST_GRID_SOLVED = "
    Grid 01
    483921657
    967345821
    251876493
    548132976
    729564138
    136798245
    372689514
    814253769
    695417382
"

puzzle = Grid.new(TEST_GRID)

GeneticAlgorithm::Chromosome.puzzle(puzzle)

t = Time.new
puts "Beginning genetic search... #{t}"
search = GeneticAlgorithm::GeneticSearch.new(100, 1000)
result = search.run
elapsed = Time.now - t
puts "Fitness lvl: #{result.fitness} \n #{result.data} \n Time Elapsed: #{elapsed}"


