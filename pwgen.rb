#!/usr/bin/env ruby

def random_bytes(nbytes)
  File.open("/dev/random", "r") do |fp|
    return(fp.read(nbytes))
  end
end

def randnum(max)
  bits = Math.log(max) / Math.log(2)
  nbits = bits.ceil
  nbytes = (nbits / 8.0).ceil
  val = max + 1
  while val >= max
    rnd = random_bytes(nbytes)
    rnd = rnd.bytes.to_a
    val = 0
    val = rnd.inject(0) { |v, n| v*256 + n }
    if nbits < 8
      val &= (1 << nbits) - 1
    end
  end
  return(val)
end

matrix = File.open(ARGV[0]) {|fp| eval(fp.read) }
pwl = ARGV[1].to_i
ncaps = (ARGV[2].to_s =~ /^[0-9]+$/) ? ARGV[2].to_i : randnum(pwl/4) + 1
nums = (ARGV[3].nil?) ? 0 : ARGV[3].to_i
depth = matrix[:start].keys.inject(0) {|x,y| (y.length > x) ? y.length : x }
state = :start
output = ""
while output.length < pwl do
  ranno = randnum(65536)
  sum = 0.0
  nextstate = nil
  state = :start if matrix[state].nil?
  matrix[state].each_pair do |k,v|
    sum += v
    if sum >= ranno
      nextstate = k
      break
    end
  end
  if nextstate.nil?
    state = :start
  else
    output << nextstate
    state = nextstate
  end
end

output = output[0,pwl]
choices = (0..output.length).to_a
capletters = []
ncaps.times do
  choice = randnum(choices.length-1)
  capletters << choices[choice]
  choices.delete(choices[choice])
end
capletters.each { |choice| output[choice] = output[choice].capitalize }
nums.times do
  pos = randnum(output.length)
  num = [randnum(10) + 0x30].pack("c")
  output[pos] = num
end
puts "Password: #{output}"

