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

grid = Grid.new(TEST_GRID)

Ai4r::GeneticAlgorithm::Chromosome.grid(grid)

puts "Example of randomly filled in values"
5.times do
  chromo = Ai4r::GeneticAlgorithm::Chromosome.seed
  puts "#{chromo.data}"
end

puts "Beginning genetic search..."

search = Ai4r::GeneticAlgorithm::GeneticSearch.new(100, 1000000)
result = search.run

puts "Fitness lvl: #{result.fitness} \n #{result.data}"


