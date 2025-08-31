#!/home/chrisarg/perl5/perlbrew/perls/current/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use Bit::Set qw(Bit_new Bit_bset Bit_count Bit_free);

my $bitset = Bit_new(1024);
Bit_bset($bitset, 0);
Bit_bset($bitset, 1);
Bit_bset($bitset, 4);

is(Bit_count($bitset), 4, 'Popcount should be 3');

Bit_free(\$bitset);