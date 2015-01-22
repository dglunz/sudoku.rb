# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
module Ai4r
  
  # The GeneticAlgorithm module implements the GeneticSearch and Chromosome 
  # classes. The GeneticSearch is a generic class, and can be used to solved 
  # any kind of problems. The GeneticSearch class performs a stochastic search 
  # of the solution of a given problem.
  # 
  # The Chromosome is "problem specific". Ai4r built-in Chromosome class was 
  # designed to model the Travelling salesman problem. If you want to solve other 
  # type of problem, you will have to modify the Chromosome class, by overwriting 
  # its fitness, reproduce, and mutate functions, to model your specific problem.
  module GeneticAlgorithm

    #   This class is used to automatically:
    #   
    #     1. Choose initial population
    #     2. Evaluate the fitness of each individual in the population
    #     3. Repeat
    #           1. Select best-ranking individuals to reproduce
    #           2. Breed new generation through crossover and mutation (genetic operations) and give birth to offspring
    #           3. Evaluate the individual fitnesses of the offspring
    #           4. Replace worst ranked part of population with offspring
    #     4. Until termination
    #
    #   If you want to customize the algorithm, you must modify any of the following classes:
    #     - Chromosome
    #     - Population
    class GeneticSearch

      attr_accessor :population


      def initialize(initial_population_size, generations)
        @population_size = initial_population_size
        @max_generation = generations
        @generation = 0
      end

      #     1. Choose initial population
      #     2. Evaluate the fitness of each individual in the population
      #     3. Repeat
      #           1. Select best-ranking individuals to reproduce
      #           2. Breed new generation through crossover and mutation (genetic operations) and give birth to offspring
      #           3. Evaluate the individual fitnesses of the offspring
      #           4. Replace worst ranked part of population with offspring
      #     4. Until termination    
      #     5. Return the best chromosome
      def run
        generate_initial_population                    #Generate initial population 
        @max_generation.times do
          selected_to_breed = selection                #Evaluates current population 
          offsprings = reproduction selected_to_breed  #Generate the population for this new generation
          replace_worst_ranked offsprings
        end
        return best_chromosome
      end


      def generate_initial_population
       @population = []
       @population_size.times do
         population << Chromosome.seed
       end
      end

      # Select best-ranking individuals to reproduce
      # 
      # Selection is the stage of a genetic algorithm in which individual 
      # genomes are chosen from a population for later breeding. 
      # There are several generic selection algorithms, such as 
      # tournament selection and roulette wheel selection.        
      #
      def selection
        possible_parents = @population_size
        breeders = []
        possible_parents.times do
          breeders << tournament_selection(@population, possible_parents)
        end
        breeders
      end

      def tournament_selection(pop, possible_parents)
        best = nil
        possible_parents.times do
          contestant = pop[rand(@population_size)]
          if best == nil || contestant.fitness > best.fitness
            best = contestant
          end
        end
        return best
      end

      # We combine each pair of selected chromosome using the method 
      # Chromosome.reproduce
      #
      # The reproduction will also call the Chromosome.mutate method with 
      # each member of the population. You should implement Chromosome.mutate
      # to only change (mutate) randomly. E.g. You could effectivly change the
      # chromosome only if 
      #     rand < ((1 - chromosome.normalized_fitness) * 0.4)
      def reproduction(selected_to_breed)
        offsprings = []
        0.upto(selected_to_breed.length-2) do |i|
          offsprings << Chromosome.reproduce(selected_to_breed[i], selected_to_breed[i+1])
        end
        @population.each do |individual|
          Chromosome.mutate(individual)
        end
        return offsprings
      end

      # Replace worst ranked part of population with offspring
      def replace_worst_ranked(offsprings)
        size = offsprings.length-10
        pop = @population.sort_by(&:fitness).reverse
        @population = pop[0..(@population_size - size-1)] + offsprings[0..size-1]
        puts "Elitist survivors #{@population[0..10].map(&:fitness)}"
      end

      # Select the best chromosome in the population
      def best_chromosome
        the_best = @population.first
        @population.each do |chromosome|
          the_best = chromosome if chromosome.fitness > the_best.fitness
        end
        return the_best
      end

      private 
       
      def select_random_individual(acum_fitness)
        select_random_target = acum_fitness * rand
        local_acum = 0
        @population.each do |chromosome|
          local_acum += chromosome.normalized_fitness
          return chromosome if local_acum >= select_random_target
        end
      end

    end

    # A Chromosome is a representation of an individual solution for a specific 
    # problem. You will have to redifine the Chromosome representation for each
    # particular problem, along with its fitness, mutate, reproduce, and seed 
    # methods.
    class Chromosome

      attr_accessor :data
      attr_accessor :normalized_fitness

      def initialize(data)
        @data = data
      end

      # The fitness method quantifies the optimality of a solution 
      # (that is, a chromosome) in a genetic algorithm so that that particular 
      # chromosome may be ranked against all the other chromosomes. 
      # 
      # Optimal chromosomes, or at least chromosomes which are more optimal, 
      # are allowed to breed and mix their datasets by any of several techniques, 
      # producing a new generation that will (hopefully) be even better.
      def fitness
        return @fitness if @fitness
        @@grid.fill_search_squares(@data)
        @fitness = @@grid.fitness
        return @fitness
      end

      # mutation method is used to maintain genetic diversity from one 
      # generation of a population of chromosomes to the next. It is analogous 
      # to biological mutation. 
      # 
      # The purpose of mutation in GAs is to allow the 
      # algorithm to avoid local minima by preventing the population of 
      # chromosomes from becoming too similar to each other, thus slowing or even 
      # stopping evolution.
      # 
      # Calling the mutate function will "probably" slightly change a chromosome
      # randomly. 
      #
      # This implementation of "mutation" will (probably) reverse the 
      # order of 2 consecutive randome nodes 
      # (e.g. from [ 0, 1, 2, 4] to [0, 2, 1, 4]) if:
      #     ((1 - chromosome.normalized_fitness) * 0.4)
      def self.mutate(chromosome)
        if chromosome.normalized_fitness && rand < ((1 - chromosome.normalized_fitness) * 0.3)
          data = chromosome.data
          index = rand(data.length-1)
          data[index], data[index+1] = data[index+1], data[index]
          chromosome.data = data
          @fitness = nil
        end
      end

      # Reproduction method is used to combine two chromosomes (solutions) into 
      # a single new chromosome. There are several ways to
      # combine two chromosomes: One-point crossover, Two-point crossover,
      # "Cut and splice", edge recombination, and more. 
      # 
      # The method is usually dependant of the problem domain.
      def self.reproduce(a, b)
        data_size = @@grid.empty_squares.length - 1
        available = []
        (data_size/9).times { available << (1..9).to_a }
        1.upto(data_size%9) { |n| available << (1..9).to_a.at(n) }
        available.flatten!
        token = a.data[0]
        spawn = [token]
        available.delete(token)
        while available.length > 0 do 
          #Select next
          if a.data.index(token) == nil || b.data.index(token) == nil
            next_token = available[rand(available.length)]
          elsif token != b.data.last && available.include?(b.data[b.data.index(token)+1])
            next_token = b.data[b.data.index(token)+1]
          elsif token != a.data.last && available.include?(a.data[a.data.index(token)+1])
            next_token = a.data[a.data.index(token)+1] 
          else
            next_token = available[rand(available.length)]
          end
          #Add to spawn
          token = next_token
          available.delete(token)
          spawn << next_token
          a, b = b, a if rand < 0.4
        end
        return Chromosome.new(spawn)
      end

      # Initializes an individual solution (chromosome) for the initial 
      # population. Usually the chromosome is generated randomly, but you can 
      # use some problem domain knowledge, to generate a 
      # (probably) better initial solution.
      def self.seed
        data_size = @@grid.empty_squares.length 
        available = []

        0.upto(data_size-1) { |n| available << (1..9).to_a.sample }
        seed = []
        while available.length > 0 do 
          index = rand(available.length)
          seed << available.delete_at(index)
        end
        return Chromosome.new(seed)
      end

      def self.grid(grid)
        @@grid = grid
      end
    end

  end

end
