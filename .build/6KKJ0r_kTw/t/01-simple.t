use strict;
use warnings;

use Test::More;
use Bit::Set;

plan tests => 1;

# Create a new bitset
my $set = Bit::Set::Bit_new(1024);

# Set some bits
Bit::Set::Bit_bset($set, 0); # first bit
Bit::Set::Bit_bset($set, 1); # second bit
Bit::Set::Bit_bset($set, 4); # fifth bit

# Get the population count
my $count = Bit::Set::Bit_count($set);

# Check if the count is 3
is($count, 3, "Population count is 3");

# Free the bitset
Bit::Set::Bit_free(\$set);
