package Bit::Set;

use strict;
use warnings;

use FFI::Platypus 1.00;
use Alien::Bit;

our $VERSION = '0.01';

# Set up the FFI object
my $ffi = FFI::Platypus->new(
    api => 1,
    lib => [ Alien::Bit->libs ],
);

# Define the opaque type for the bitset
$ffi->type('opaque' => 'Bit_T');
$ffi->type('opaque' => 'Bit_DB_T');

# Define a helper for debug checks
use constant DEBUG => $ENV{DEBUG};

# Functions to attach
my %functions = (
    Bit_new => {
        args => ['int'],
        ret  => 'Bit_T',
        wrapper => sub {
            my $orig = shift;
            my ($length) = @_;
            if (DEBUG) {
                die "Length must be non-negative" if $length < 0;
            }
            return $orig->($length);
        }
    },
    Bit_free => {
        args => ['Bit_T*'],
        ret  => 'opaque',
    },
    Bit_load => {
        args => ['int', 'opaque'],
        ret  => 'Bit_T',
        wrapper => sub {
            my $orig = shift;
            my ($length, $buffer) = @_;
            if (DEBUG) {
                die "Length must be non-negative" if $length < 0;
                die "Buffer cannot be null" if !defined $buffer;
            }
            return $orig->($length, $buffer);
        }
    },
    Bit_extract => {
        args => ['Bit_T', 'opaque'],
        ret  => 'int',
    },
    Bit_buffer_size => {
        args => ['int'],
        ret  => 'int',
        wrapper => sub {
            my $orig = shift;
            my ($length) = @_;
            if (DEBUG) {
                die "Length must be non-negative" if $length < 0;
            }
            return $orig->($length);
        }
    },
    Bit_length => {
        args => ['Bit_T'],
        ret  => 'int',
    },
    Bit_count => {
        args => ['Bit_T'],
        ret  => 'int',
    },
    Bit_aset => {
        args => ['Bit_T', 'int[]', 'int'],
        ret  => 'void',
    },
    Bit_bset => {
        args => ['Bit_T', 'int'],
        ret  => 'void',
    },
    Bit_aclear => {
        args => ['Bit_T', 'int[]', 'int'],
        ret  => 'void',
    },
    Bit_bclear => {
        args => ['Bit_T', 'int'],
        ret  => 'void',
    },
    Bit_clear => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'void',
    },
    Bit_get => {
        args => ['Bit_T', 'int'],
        ret  => 'int',
    },
    Bit_not => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'void',
    },
    Bit_put => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'int',
    },
    Bit_set => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'void',
    },
    Bit_eq => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
    Bit_leq => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
    Bit_lt => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
    Bit_diff => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'Bit_T',
    },
    Bit_inter => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'Bit_T',
    },
    Bit_minus => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'Bit_T',
    },
    Bit_union => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'Bit_T',
    },
    Bit_diff_count => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
    Bit_inter_count => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
    Bit_minus_count => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
    Bit_union_count => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
    },
);

for my $name (keys %functions) {
    my $spec = $functions{$name};
    $ffi->attach(
        $name => $spec->{args},
        $spec->{ret},
        (exists $spec->{wrapper} ? (wrapper => $spec->{wrapper}) : ())
    );
}

1;

__END__

=head1 NAME

Bit::Set - A Perl interface to the bit.h C library for bitsets.

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use Bit::Set;

  # Create a new bitset
  my $set = Bit::Set::Bit_new(1024);

  # Set some bits
  Bit::Set::Bit_bset($set, 1);
  Bit::Set::Bit_bset($set, 2);
  Bit::Set::Bit_bset($set, 5);

  # Get the population count
  my $count = Bit::Set::Bit_count($set);
  print "Population count: $count\n"; # 3

  # Free the bitset
  Bit::Set::Bit_free(\$set);

=head1 DESCRIPTION

This module provides a procedural Perl interface to the C library C<bit.h>,
for creating and manipulating bitsets. It uses C<FFI::Platypus> to wrap the C
functions and C<Alien::Bit> to locate and link to the C library.

=head1 FUNCTIONS

=head2 Bit_new(length)

Creates a new bitset of the given length.

=head2 Bit_free(set)

Frees the memory associated with the bitset.

=head2 Bit_load(length, buffer)

Loads a bitset from an external buffer.

=head2 Bit_extract(set, buffer)

Extracts a bitset into an external buffer.

=head2 Bit_buffer_size(length)

Returns the size in bytes required to store a bitset of the given length.

=head2 Bit_length(set)

Returns the length (capacity) of the bitset in bits.

=head2 Bit_count(set)

Returns the number of set bits (population count) in the bitset.

=head2 Bit_aset(set, indices, n)

Sets an array of bits in the bitset.

=head2 Bit_bset(set, index)

Sets a single bit in the bitset.

=head2 Bit_aclear(set, indices, n)

Clears an array of bits in the bitset.

=head2 Bit_bclear(set, index)

Clears a single bit in the bitset.

=head2 Bit_clear(set, lo, hi)

Clears a range of bits in the bitset.

=head2 Bit_get(set, index)

Gets the value of a bit at a given index.

=head2 Bit_not(set, lo, hi)

Inverts a range of bits in the bitset.

=head2 Bit_put(set, n, val)

Sets the nth bit to the given value.

=head2 Bit_set(set, lo, hi)

Sets a range of bits in the bitset.

=head2 Bit_eq(s, t)

Checks if two bitsets are equal.

=head2 Bit_leq(s, t)

Checks if bitset C<s> is a subset of or equal to bitset C<t>.

=head2 Bit_lt(s, t)

Checks if bitset C<s> is a proper subset of bitset C<t>.

=head2 Bit_diff(s, t)

Returns a new bitset that is the difference of two bitsets.

=head2 Bit_inter(s, t)

Returns a new bitset that is the intersection of two bitsets.

=head2 Bit_minus(s, t)

Returns a new bitset that is the symmetric difference of two bitsets.

=head2 Bit_union(s, t)

Returns a new bitset that is the union of two bitsets.

=head2 Bit_diff_count(s, t)

Returns the population count of the difference of two bitsets.

=head2 Bit_inter_count(s, t)

Returns the population count of the intersection of two bitsets.

=head2 Bit_minus_count(s, t)

Returns the population count of the symmetric difference of two bitsets.

=t_union_count(s, t)

Returns the population count of the union of two bitsets.

=head1 AUTHOR

GitHub Copilot

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Christos Argyropoulos.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
