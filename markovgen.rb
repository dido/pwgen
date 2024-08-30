#!/usr/bin/env ruby
#
# Markov chain frequency analyzer.  Give it a corpus of words,
# and it will analyze the words into a Markov chain data structure
# that can be used to generate other words that should conform
# closely to the same phonology more or less.
#
# The letters are converted to lowercase and then numbered from 0 to
# 25.
# The Markov chain 
def inc_tblidx(mtx, indices)
  m = mtx
  while indices.length > 1
    m = m[indices.shift]
  end
  idx = indices.shift
  m[idx] += 1.0
end

def tblidx(mtx, indices)
  m = mtx
  indices.each do |idx|
    m = m[idx]
  end
  return(m)
end

MAXCHARS = 26
context = ARGV[0].to_i
# generate an empty multidimensional array with 0.0 for all values
def gen_array(depth)
  return(Array.new(MAXCHARS, 0.0)) if (depth <= 0)
  a = Array.new(MAXCHARS)
  0.upto(MAXCHARS-1) {|i| a[i] = gen_array(depth-1) }
  return(a)
end
matrix = gen_array(context-1)
count = 0
STDIN.each do |line|
  line.chomp!
  line.downcase!
  next unless line =~ /^[a-z]+$/
  letters = line.unpack("c*").map {|x| x - 97 }
  letters.each_index do |i|
    ctx = []
    0.upto(context-1) do |j|
      break if i+j >= letters.length
      ctx << letters[i+j]
    end
    next if ctx.length < context
    #p (ctx.map{|x| x+ 97}).pack("c*")
    inc_tblidx(matrix, ctx)
    count += 1
  end
end
# Normalize the matrix
def normalize(matrix, div)
  if matrix[0].is_a?(Array)
    return(matrix.map {|x| normalize(x, div) })
  end
  return(matrix.map {|x| x/div})
end
matrix = normalize(matrix, count)
p matrix
