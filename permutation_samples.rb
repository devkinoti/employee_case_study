# ruby permutation_samples.rb

# Define the array of elements
elements = (1..20).to_a

# Generate permutations of three elements
permutations = elements.repeated_permutation(3).to_a

# Filter permutations where the sum equals 20
valid_permutations = permutations.select { |a, b, c| a + b + c == 20 }

# Print the valid permutations
puts "Permutations that sum to 20:"
valid_permutations.each { |permutation| p permutation }
