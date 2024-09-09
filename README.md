# pwgen
Entropy Efficient Password Generator

This is a password generator using an arithmetic-coded randomness pool
for more efficient use of entropy.  If a trustworthy and reliable
source of entropy is not available, one can add entropy manually by
rolling dice.


## Entropy pool

The arithmetic coded entropy pool is an exact rational number between
0 and 1. Entropy is added to the pool by literally adding the random
number obtained after dividing 

We attempt to keep track of how much entropy actually gathered in
shannons (bits of entropy), and make sure that we will never try to extract more entropy
from the pool than our running entropy tally says we have.

The amount of entropy available for the usual dice types is not very
large:

1d4 - 2 shannon (bits)
1d6 - 2.58 shannon
1d8 - 3 shannon
1d12 - 3.58 shannon
1d20 - 4.32 shannon
byte from /dev/random - 8 shannon

Long passwords may thus require many dice rolls.

If you are rolling dice to generate passwords it is important that one
does not skip or fudge the results of any properly done roll. Do not
attempt to "balance" the randomness or you may impose a pattern on it
without realising it.
