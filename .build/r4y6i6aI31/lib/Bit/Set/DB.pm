package Bit::Set::DB;

use strict;
use warnings;

use FFI::Platypus 1.00;
use Alien::Bit;

our $VERSION = '0.01';

# Set up the FFI object
my $ffi = FFI::Platypus->new(
    api => 1,
    lib => [ Alien::Bit->dynamic_libs ],
);

# Define opaque types
$ffi->type('opaque' => 'Bit_DB_T');
$ffi->type('opaque' => 'Bit_T');

# Define the SETOP_COUNT_OPTS record
my $builder = $ffi->record_builder('SETOP_COUNT_OPTS');
$builder->field('num_cpu_threads' => 'sint');
$builder->field('device_id' => 'sint');
$builder->field('upd_1st_operand' => 'bool');
$builder->field('upd_2nd_operand' => 'bool');
$builder->field('release_1st_operand' => 'bool');
$builder->field('release_2nd_operand' => 'bool');
$builder->field('release_counts' => 'bool');
$builder->build;

$ffi->type('record(SETOP_COUNT_OPTS)' => 'SETOP_COUNT_OPTS_t');

# Define a helper for debug checks
use constant DEBUG => $ENV{DEBUG};

# Function definitions for FFI attachment
my %functions = (
    # Creation / Destruction
    BitDB_new => {
        args => ['int', 'int'],
        ret  => 'Bit_DB_T',
        check => sub {
            my ($length, $num) = @_;
            die "Length and number of bitsets must be non-negative" if $length < 0 || $num < 0;
        }
    },
    BitDB_free => {
        args => ['Bit_DB_T*'],
        ret  => 'opaque',
    },

    # Properties
    BitDB_length => {
        args => ['Bit_DB_T'],
        ret  => 'int',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },
    BitDB_nelem => {
        args => ['Bit_DB_T'],
        ret  => 'int',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },
    BitDB_count_at => {
        args => ['Bit_DB_T', 'int'],
        ret  => 'int',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },
    BitDB_count => {
        args => ['Bit_DB_T'],
        ret  => 'int*',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },

    # Manipulation
    BitDB_get_from => {
        args => ['Bit_DB_T', 'int'],
        ret  => 'Bit_T',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },
    BitDB_put_at => {
        args => ['Bit_DB_T', 'int', 'Bit_T'],
        ret  => 'void',
        check => sub { die "Bit DB or bitset cannot be null" if !defined $_[0] || !defined $_[2]; }
    },
    BitDB_extract_from => {
        args => ['Bit_DB_T', 'int', 'opaque'],
        ret  => 'int',
        check => sub { die "Bit DB or buffer cannot be null" if !defined $_[0] || !defined $_[2]; }
    },
    BitDB_replace_at => {
        args => ['Bit_DB_T', 'int', 'opaque'],
        ret  => 'void',
        check => sub { die "Bit DB or buffer cannot be null" if !defined $_[0] || !defined $_[2]; }
    },
    BitDB_clear => {
        args => ['Bit_DB_T'],
        ret  => 'void',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },
    BitDB_clear_at => {
        args => ['Bit_DB_T', 'int'],
        ret  => 'void',
        check => sub { die "Bit DB cannot be null" if !defined $_[0]; }
    },

    # SETOP Count Store CPU
    BitDB_inter_count_store_cpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_union_count_store_cpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_diff_count_store_cpu  => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_minus_count_store_cpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },

    # SETOP Count Store GPU
    BitDB_inter_count_store_gpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_union_count_store_gpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_diff_count_store_gpu  => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_minus_count_store_gpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'], ret  => 'int*' },

    # SETOP Count CPU
    BitDB_inter_count_cpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_union_count_cpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_diff_count_cpu  => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_minus_count_cpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },

    # SETOP Count GPU
    BitDB_inter_count_gpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_union_count_gpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_diff_count_gpu  => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
    BitDB_minus_count_gpu => { args => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'], ret  => 'int*' },
);

# Attach all functions
for my $name (sort keys %functions) {
    my $spec = $functions{$name};
    my @attach_args = ($name, $spec->{args}, $spec->{ret});

    if (DEBUG && exists $spec->{check}) {
        my $checker = $spec->{check};
        push @attach_args, wrapper => sub {
            my $orig = shift;
            $checker->(@_);
            return $orig->(@_);
        };
    }
    
    # Add a check for the SETOP functions
    if (DEBUG && $name =~ /_count(?:_store)?_(?:cpu|gpu)$/) {
        push @attach_args, wrapper => sub {
            my $orig = shift;
            my ($db1, $db2) = @_;
            die "Bit DBs cannot be null" if !defined $db1 || !defined $db2;
            return $orig->(@_);
        };
    }

    $ffi->attach(@attach_args);
}

# Verification
my @c_functions = qw(
    BitDB_new BitDB_free BitDB_length BitDB_nelem BitDB_count_at BitDB_count
    BitDB_get_from BitDB_put_at BitDB_extract_from BitDB_replace_at BitDB_clear BitDB_clear_at
    BitDB_inter_count_store_cpu BitDB_union_count_store_cpu BitDB_diff_count_store_cpu BitDB_minus_count_store_cpu
    BitDB_inter_count_store_gpu BitDB_union_count_store_gpu BitDB_diff_count_store_gpu BitDB_minus_count_store_gpu
    BitDB_inter_count_cpu BitDB_union_count_cpu BitDB_diff_count_cpu BitDB_minus_count_cpu
    BitDB_inter_count_gpu BitDB_union_count_gpu BitDB_diff_count_gpu BitDB_minus_count_gpu
);

my %perl_functions;
@perl_functions{keys %functions} = ();
for my $c_func (@c_functions) {
    die "FATAL: C function '$c_func' not implemented in Bit::Set::DB"
        unless exists $perl_functions{$c_func};
}

1;

__END__

=head1 NAME

Bit::Set::DB - Perl interface for bitset containers from the 'bit' C library

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

  # Free the database and the bitset
  Bit::Set::DB::BitDB_free(\$db);
  Bit::Set::Bit_free(\$set);

=head1 DESCRIPTION

This module provides a procedural Perl interface to the C library C<bit.h>,
for creating and manipulating containers of bitsets (BitDB). It uses
C<FFI::Platypus> to wrap the C functions and C<Alien::Bit> to locate and link
to the C library.

The API is a direct mapping of the C functions. For detailed semantics of each
function, please refer to the C<bit.h> header file documentation.

Runtime checks on arguments are performed if the C<DEBUG> environment variable
is set to a true value.

=head1 FUNCTIONS

=head2 Creation and Destruction

=over 4

=item B<BitDB_new(length, num_of_bitsets)>

Creates a new bitset container for C<num_of_bitsets> bitsets, each of C<length>.

=item B<BitDB_free(db_ref)>

Frees the memory associated with the bitset container. Expects a reference to the scalar holding the DB object.

=back

=head2 Properties

=over 4

=item B<BitDB_length(set)>

Returns the length of bitsets in the container.

=item B<BitDB_nelem(set)>

Returns the number of bitsets in the container.

=item B<BitDB_count_at(set, index)>

Returns the population count of the bitset at the given C<index>.

=item B<BitDB_count(set)>

Returns a pointer to an array of population counts for all bitsets in the container.

=back

=head2 Manipulation

=over 4

=item B<BitDB_get_from(set, index)>

Returns a bitset from the container at the given C<index>.

=item B<BitDB_put_at(set, index, bitset)>

Puts a C<bitset> into the container at the given C<index>.

=item B<BitDB_extract_from(set, index, buffer)>

Extracts a bitset from the container at C<index> into a C<buffer>.

=item B<BitDB_replace_at(set, index, buffer)>

Replaces a bitset in the container at C<index> with the contents of a C<buffer>.

=item B<BitDB_clear(set)>

Clears all bitsets in the container.

=item B<BitDB_clear_at(set, index)>

Clears the bitset at a given C<index> in the container.

=back

=head2 Set Operation Counts

These functions perform set operations between two bitset containers. The C<opts>
parameter is a hash reference corresponding to the C<SETOP_COUNT_OPTS> struct.

Example for C<opts>:

  my $opts = {
      num_cpu_threads => 4,
      device_id       => 0,
      # ... other flags
  };

=over 4

=item B<BitDB_inter_count_cpu(db1, db2, opts)>
=item B<BitDB_union_count_cpu(db1, db2, opts)>
=item B<BitDB_diff_count_cpu(db1, db2, opts)>
=item B<BitDB_minus_count_cpu(db1, db2, opts)>

Perform the respective set operation count on the CPU.

=item B<BitDB_inter_count_gpu(db1, db2, opts)>
=item B<BitDB_union_count_gpu(db1, db2, opts)>
=item B<BitDB_diff_count_gpu(db1, db2, opts)>
=item B<BitDB_minus_count_gpu(db1, db2, opts)>

Perform the respective set operation count on the GPU.

=item B<BitDB_inter_count_store_cpu(db1, db2, buffer, opts)>
=item B<BitDB_union_count_store_cpu(db1, db2, buffer, opts)>
=item B<BitDB_diff_count_store_cpu(db1, db2, buffer, opts)>
=item B<BitDB_minus_count_store_cpu(db1, db2, buffer, opts)>

Perform the respective set operation count on the CPU and store results in C<buffer>.

=item B<BitDB_inter_count_store_gpu(db1, db2, buffer, opts)>
=item B<BitDB_union_count_store_gpu(db1, db2, buffer, opts)>
=item B<BitDB_diff_count_store_gpu(db1, db2, buffer, opts)>
=item B<BitDB_minus_count_store_gpu(db1, db2, buffer, opts)>

Perform the respective set operation count on the GPU and store results in C<buffer>.

=back

=head1 AUTHOR

GitHub Copilot, guided by a senior Perl engineer.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Christos Argyropoulos.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
