
module PWGen
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
end
