#!/usr/bin/env ruby
# Generate a password by rolling dice

class XRandom
  attr_reader :entropy, :ebits, :randombits

  def initialize(faces=20)
    @randombits = 0.0
    @dicerolls = 0
    @entropy = Rational(0,1)
    @ebits = 0.0
    @faces = faces
  end

  def seed()
    (@faces <= 1) ? devrandom() : get_roll()
  end

  ##
  # Seed the RNG from /dev/random
  def devrandom()
    File.open("/dev/random", "r") do |fp|
      rb = fp.read(1).bytes[0]
      @entropy /= 256
      @entropy += Rational(rb, 256)
      @ebits += 8
    end
  end

  ##
  # Seed the RNG from dice rolls
  def get_roll()
    roll = 0
    loop do
      print "#{"%02f" % @randombits} Rolld#{@faces}: "
      roll = STDIN.gets().chomp
      roll = roll.to_i
      break if roll >= 1 && roll <= @faces
      puts "Enter input between 1 and #{@faces}"
    end
    @entropy /= faces
    @entropy += Rational(roll-1, faces)
    bits = Math.log(faces) / Math.log(2)
    @ebits += bits
  end

  def random_bytes(nbytes)
    # File.open("/dev/random", "r") do |fp|
    #   return(fp.read(nbytes))
    # end
    bytes = []
    while bytes.length < nbytes do
      seed()
      next if @ebits < 8
      @entropy *= 256
      b = @entropy.floor
      @entropy -= b
      @ebits -= 8
      bytes << b
    end
    return(bytes)
  end

  def randnum(max)
    bits = Math.log(max) / Math.log(2)
    nbits = bits.ceil
    while @ebits < bits
      seed()
    end
    @entropy *= max
    val = @entropy.floor
    @entropy -= val
    @ebits -= bits
    @randombits += bits
    return(val)
  end
end
  
rng = XRandom.new(0)
matrix = File.open(ARGV[0]) {|fp| eval(fp.read) }
pwl = ARGV[1].to_i
ncaps = (ARGV[2].to_s =~ /^[0-9]+$/) ? ARGV[2].to_i : rng.randnum(pwl/4) + 1
nums = (ARGV[3].nil?) ? 0 : ARGV[3].to_i
depth = matrix[:start].keys.inject(0) {|x,y| (y.length > x) ? y.length : x }
state = :start
output = ""
while output.length < pwl do
  p state
  sum = 0
  nextstate = nil
  state = :start if matrix[state].nil?
  smax = matrix[state].values.sum
  p smax
  ranno = rng.randnum(smax)
  p rng.ebits
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
  choice = rng.randnum(choices.length-1)
  capletters << choices[choice]
  choices.delete(choices[choice])
end
capletters.each { |choice| output[choice] = output[choice].capitalize }
nums.times do
  pos = rng.randnum(output.length)
  num = [rng.randnum(10) + 0x30].pack("c")
  output[pos] = num
end
puts "Password: #{output}"
puts "Entropy: #{rng.randombits}"

