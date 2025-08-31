package Bit::Set::DB;

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

# Define the opaque type for the bitset database
$ffi->type('opaque' => 'Bit_DB_T');
$ffi->type('opaque' => 'Bit_T');

# Define the SETOP_COUNT_OPTS struct
$ffi->record('SETOP_COUNT_OPTS')->
  field('num_cpu_threads' => 'sint')->
  field('device_id' => 'sint')->
  field('upd_1st_operand' => 'bool')->
  field('upd_2nd_operand' => 'bool')->
  field('release_1st_operand' => 'bool')->
  field('release_2nd_operand' => 'bool')->
  field('release_counts' => 'bool');

# Define a helper for debug checks
use constant DEBUG => $ENV{DEBUG};

# Functions to attach
my %functions = (
    BitDB_new => {
        args => ['int', 'int'],
        ret  => 'Bit_DB_T',
        wrapper => sub {
            my $orig = shift;
            my ($length, $num_of_bitsets) = @_;
            if (DEBUG) {
                die "Length and number of bitsets must be non-negative" if $length < 0 || $num_of_bitsets < 0;
            }
            return $orig->($length, $num_of_bitsets);
        }
    },
    BitDB_free => {
        args => ['Bit_DB_T*'],
        ret  => 'opaque',
    },
    BitDB_length => {
        args => ['Bit_DB_T'],
        ret  => 'int',
    },
    BitDB_nelem => {
        args => ['Bit_DB_T'],
        ret  => 'int',
    },
    BitDB_count_at => {
        args => ['Bit_DB_T', 'int'],
        ret  => 'int',
    },
    BitDB_count => {
        args => ['Bit_DB_T'],
        ret  => 'int*',
    },
    BitDB_get_from => {
        args => ['Bit_DB_T', 'int'],
        ret  => 'Bit_T',
    },
    BitDB_put_at => {
        args => ['Bit_DB_T', 'int', 'Bit_T'],
        ret  => 'void',
    },
    BitDB_extract_from => {
        args => ['Bit_DB_T', 'int', 'opaque'],
        ret  => 'int',
    },
    BitDB_replace_at => {
        args => ['Bit_DB_T', 'int', 'opaque'],
        ret  => 'void',
    },
    BitDB_clear => {
        args => ['Bit_DB_T'],
        ret  => 'void',
    },
    BitDB_clear_at => {
        args => ['Bit_DB_T', 'int'],
        ret  => 'void',
    },
    BitDB_inter_count_store_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_inter_count_store_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_inter_count_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_inter_count_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_union_count_store_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_union_count_store_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_union_count_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_union_count_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_diff_count_store_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_diff_count_store_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_diff_count_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_diff_count_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_minus_count_store_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_minus_count_store_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_minus_count_cpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
    },
    BitDB_minus_count_gpu => {
        args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'],
        ret  => 'int*',
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

Bit::Set::DB - A Perl interface to the bit.h C library for bitset containers.

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use Bit::Set::DB;
  use Bit::Set;

  # Create a new bitset database
  my $db = Bit::Set::DB::BitDB_new(1024, 10);

  # Create a bitset and add it to the database
  my $set = Bit::Set::Bit_new(1024);
  Bit::Set::Bit_bset($set, 42);
  Bit::Set::DB::BitDB_put_at($db, 0, $set);

  # ...

  # Free the database
  Bit::Set::DB::BitDB_free(\$db);
  Bit::Set::Bit_free(\$set);


=head1 DESCRIPTION

This module provides a procedural Perl interface to the C library C<bit.h>,
for creating and manipulating containers of bitsets (BitDB). It uses
C<FFI::Platypus> to wrap the C functions and C<Alien::Bit> to locate and link
to the C library.

=head1 FUNCTIONS

=head2 BitDB_new(length, num_of_bitsets)

Creates a new bitset container.

=head2 BitDB_free(set)

Frees the memory associated with the bitset container.

=head2 BitDB_length(set)

Returns the length of bitsets in the container.

=head2 BitDB_nelem(set)

Returns the number of bitsets in the container.

=head2 BitDB_count_at(set, index)

Returns the population count of the bitset at the given index.

=head2 BitDB_count(set)

Returns an array of population counts for all bitsets in the container.

=head2 BitDB_get_from(set, index)

Returns a bitset from the container at the given index.

=head2 BitDB_put_at(set, index, bitset)

Puts a bitset into the container at the given index.

=head2 BitDB_extract_from(set, index, buffer)

Extracts a bitset from the container at the given index into a buffer.

=head2 BitDB_replace_at(set, index, buffer)

Replaces a bitset in the container at a given index with the contents of a buffer.

=head2 BitDB_clear(set)

Clears all bitsets in the container.

=head2 BitDB_clear_at(set, index)

Clears the bitset at a given index in the container.

=head2 BitDB_inter_count_store_cpu(bit, bits, buffer, opts)

Performs intersection count on the CPU and stores the result in a buffer.

=head2 BitDB_inter_count_store_gpu(bit, bits, buffer, opts)

Performs intersection count on the GPU and stores the result in a buffer.

=head2 BitDB_inter_count_cpu(bit, bits, opts)

Performs intersection count on the CPU and returns the result.

=head2 BitDB_inter_count_gpu(bit, bits, opts)

Performs intersection count on the GPU and returns the result.

=head2 BitDB_union_count_store_cpu(bit, bits, buffer, opts)

Performs union count on the CPU and stores the result in a buffer.

=head2 BitDB_union_count_store_gpu(bit, bits, buffer, opts)

Performs union count on the GPU and stores the result in a buffer.

=head2 BitDB_union_count_cpu(bit, bits, opts)

Performs union count on the CPU and returns the result.

=head2 BitDB_union_count_gpu(bit, bits, opts)

Performs union count on the GPU and returns the result.

=head2 BitDB_diff_count_store_cpu(bit, bits, buffer, opts)

Performs difference count on the CPU and stores the result in a buffer.

=head2 BitDB_diff_count_store_gpu(bit, bits, buffer, opts)

Performs difference count on the GPU and stores the result in a buffer.

=head2 BitDB_diff_count_cpu(bit, bits, opts)

Performs difference count on the CPU and returns the result.

=head2 BitDB_diff_count_gpu(bit, bits, opts)

Performs difference count on the GPU and returns the result.

=head2 BitDB_minus_count_store_cpu(bit, bits, buffer, opts)

Performs symmetric difference count on the CPU and stores the result in a buffer.

=head2 BitDB_minus_count_store_gpu(bit, bits, buffer, opts)

Performs symmetric difference count on the GPU and stores the result in a buffer.

=head2 BitDB_minus_count_cpu(bit, bits, opts)

Performs symmetric difference count on the CPU and returns the result.

=head2 BitDB_minus_count_gpu(bit, bits, opts)

Performs symmetric difference count on the GPU and returns the result.

=head1 AUTHOR

GitHub Copilot

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Christos Argyropoulos.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
