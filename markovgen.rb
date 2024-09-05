#!/usr/bin/env ruby
#
# Markov chain frequency analyzer.  Give it a corpus of words,
# and it will analyze the words into a Markov chain data structure
# that can be used to generate other words that should conform
# closely to the same phonology more or less.
#

def add_transition(matrix, state, nstate)
#  p [state, nstate]
  matrix[state] ||= Hash.new
  matrix[state][nstate] ||= 0
  matrix[state][nstate] += 1
end

MAXCHARS = 26
clen = ARGV[0].to_i
matrix = {}
STDIN.each do |line|
  line.chomp!
  line.downcase!
  next unless line =~ /^[a-z]+$/
  state = :start
  nstate = ""
  ch = 0
#  p line
  loop do
    nstate = line[ch,clen]
    break if nstate.nil? || nstate.empty?
    add_transition(matrix, state, nstate)
    state = nstate.clone
    ch += clen
  end
end
# # Normalize the state counts
# matrix.each_key do |k|
#   sum = matrix[k].each_value.sum
#   matrix[k].each_key do |kk|
#     val = (matrix[k][kk]*65536)/ sum
#     if val > 0
#       matrix[k][kk] = val
#     else
#       matrix[k].delete(kk)
#     end
#   end
# end
p matrix
