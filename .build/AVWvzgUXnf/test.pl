#!/home/chrisarg/perl5/perlbrew/perls/current/bin/perl
use strict;
use warnings;
use Test::More tests => 1;

use Bit::Set #qw(Bit_new Bit_bset Bit_count Bit_free);

my $bitset = Bit_new(1024);
Bit_bset($bitset, 0);
Bit_bset($bitset, 1);
Bit_bset($bitset, 4);

print "Popcount: ", Bit_count($bitset), "\n";
is(Bit_count($bitset), 3, 'Popcount should be 3');

Bit_free(\$bitset);