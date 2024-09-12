
module PWGen
  ##
  # Random number generator. This basically works by maintaining an
  # arithmetic coded pool of random numbers obtained either by dice
  # rolls input by the user or /dev/random.
  class XRandom
    attr_accessor :entropy, :ebits, :randombits

    ##
    # Create a new random number generator. The faces parameter
    # gives the number of faces to use for the dice by default.
    # If set to 0, it will use /dev/random.
    def initialize(faces=0)
      @randombits = 0.0
      @dicerolls = 0
      @entropy = Rational(0,1)
      @ebits = 0.0
      @faces = faces
    end

    def seed()
      (@faces < 1) ? devrandom() : get_roll()
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
    # Prompt for a random number from the user.
    def diceprompt()
      loop do
        print "Rolld#{@faces}: "
        roll = STDIN.gets().chomp
        roll = roll.to_i
        return(roll) if roll >= 1 && roll <= @faces
        puts "Enter input between 1 and #{@faces}"
      end
    end
    
    ##
    # Seed the RNG from dice rolls
    def get_roll()
      roll=diceprompt()
      @entropy /= @faces
      @entropy += Rational(roll-1, @faces)
      bits = Math.log2(@faces)
      @ebits += bits
    end

    ##
    # Get nbytes random bytes from the system, reseed the entropy pool
    # as needed.
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

    ##
    # Get a random number from 0 to max-1 from the entropy pool.
    def randnum(max)
      bits = Math.log2(max)
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

    ##
    # Given a hash with value and frequency pairs, choose a random
    # value based on the frequency.  This will basically attempt to
    # decode the arithmetic encoded entropy pool, using the frequency
    # as the statistical model. This feels a little mathematically
    # dubious though.
    def randval(vals)
      # Estimate the entropy of the distribution based on the
      # frequency.
      sum = vals.values.sum
      ventropy = -(vals.inject(0.0) do |x,y|
                     p = y[1].to_f/sum
                     x + p*Math.log2(p)
                   end)
      pcsum = 0
      csum = 0
      pp = nil
      vals.each_pair do |k, f|
        p = Rational(f, sum)
        ereq = -Math.log2(p)
        while ereq > @ebits
          seed()
        end
        pcsum = csum
        csum += p
        if csum > @entropy
          @entropy -= pcsum
          pp ||= p
          @entropy /= p
          @ebits -= ereq
          @randombits += ventropy
          return(k)
        end
        pp = p
      end
    end
  end
end

