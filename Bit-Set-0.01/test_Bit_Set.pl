#!/home/chrisarg/perl5/perlbrew/perls/current/bin/perl
use v5.38;

use strict;
use warnings;
use Bit::Set;
use Bit::Set::DB;
use FFI::Platypus::Buffer qw(window);


# Create a new bitset with 1024 bits
my $bitset1 = Bit::Set->new(1024);
my $bitset2 = Bit::Set->new(1024);

# Set some bits
$bitset1->set(42);
$bitset1->set(100);
$bitset2->set(42);
$bitset2->set(200);

# Check if a bit is set
print "Bit 42 in bitset1: ", $bitset1->get(42), "\n";
print "Bit 100 in bitset1: ", $bitset1->get(100), "\n";
print "Bit 200 in bitset1: ", $bitset1->get(200), "\n";

# Count the number of bits set
print "Number of bits set in bitset1: ", $bitset1->count(), "\n";
print "Number of bits set in bitset2: ", $bitset2->count(), "\n";

# Calculate intersection count
my $intersection_count = $bitset1->intersection_count($bitset2);
print "Intersection count: $intersection_count\n";

# Create a new bitset as the union of the two bitsets
my $union = $bitset1->union($bitset2);

my $bitset4 = Bit::Set->new(16);

#$bitset4->set(0);
$bitset4->set(1);
$bitset4->set(2);
$bitset4->set(3);
$bitset4->set(4);
$bitset4->set(5);


printf "0x%x\n", $bitset4->{_handle};

my $pointer = FFI::Platypus::Buffer::scalar_to_pointer(\$bitset4->{_handle});
printf "0x%x\n", \$pointer;
printf "0x%x\n",  \$bitset4->{_handle};

use Data::Dumper;
print Dumper($bitset4);
$bitset4->Bit_debug();
$bitset4->Bit_free();

# Create a BitDB with 3 bitsets of length 1024
my $db = Bit::Set::DB->new(1024, 3);
my $db2 = Bit::Set::DB->new(1024, 3);

# Put our bitsets into the DB
$db->put_bitset(0, $bitset2);
$db->put_bitset(1, $bitset2);
$db->put_bitset(2, $union);

# Count bits in each bitset in the DB
print "Bits set in DB at index 0: ", $db->count_at(0), "\n";
print "Bits set in DB at index 1: ", $db->count_at(1), "\n";
print "Bits set in DB at index 2: ", $db->count_at(2), "\n";


use Inline C => <<'END_C';

#define T Bit_T
#define T_DB Bit_T_DB
/*---------------------------------------------------------------------------*/
// Bitset structure
/*
 The ADT provides access to the bitset as bytes,or qwords,
 anticipating optimization of the code *down the road*,
 including loading of externally allocated buffers into it
 The interface is effectively the one for Bit_T presented by D. Hanson
 in C Interfaces and Implementations, ISBN 0-201-49841-3 Ch13, 1997.
 Changes made by the author include
 1) the introduction of the set_count operations to avoid
 forming the intermediate Bit_T
 2) using optimized popcount functions and defaulting to the
    WWG algorithm for popcount if the user elects not to use the
    libpopcnt library.
*/
struct T {
  int length;                 // capacity of the bitset in bits
  int size_in_bytes;          // number of bytes of the 8 bit container
  int size_in_qwords;         // number of qwords of the 64 bit container
  bool is_Bit_T_allocated;    // true if allocated by the library
  unsigned char *bytes;       // pointer to the first byte
  unsigned long long *qwords; // pointer to the first qword
};
void print_addr(void *ptr) {
  printf("HELLO %ld! with %#ld\n", ptr, *(unsigned long long *)ptr);
}
END_C