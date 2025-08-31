package Bit::Set;

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

# Define the opaque type for the bitset
$ffi->type('opaque' => 'Bit_T');

# Define a helper for debug checks
use constant DEBUG => $ENV{DEBUG};

# Function definitions for FFI attachment
# This table-driven approach keeps the code DRY and easy to extend.
my %functions = (
    # Creation / Destruction
    Bit_new => {
        args => ['int'],
        ret  => 'Bit_T',
        check => sub {
            my ($length) = @_;
            die "Length must be non-negative" if $length < 0;
        }
    },
    Bit_free => {
        args => ['Bit_T*'],
        ret  => 'opaque',
    },
    Bit_load => {
        args => ['int', 'opaque'],
        ret  => 'Bit_T',
        check => sub {
            my ($length, $buffer) = @_;
            die "Length must be non-negative" if $length < 0;
            die "Buffer cannot be null" if !defined $buffer;
        }
    },
    Bit_extract => {
        args => ['Bit_T', 'opaque'],
        ret  => 'int',
        check => sub {
            my ($set, $buffer) = @_;
            die "Bit set cannot be null" if !defined $set;
            die "Buffer cannot be null" if !defined $buffer;
        }
    },

    # Properties
    Bit_buffer_size => {
        args => ['int'],
        ret  => 'int',
        check => sub {
            my ($length) = @_;
            die "Length must be non-negative" if $length < 0;
        }
    },
    Bit_length => {
        args => ['Bit_T'],
        ret  => 'int',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_count => {
        args => ['Bit_T'],
        ret  => 'int',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },

    # Manipulation
    Bit_aset => {
        args => ['Bit_T', 'int[]', 'int'],
        ret  => 'void',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_bset => {
        args => ['Bit_T', 'int'],
        ret  => 'void',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_aclear => {
        args => ['Bit_T', 'int[]', 'int'],
        ret  => 'void',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_bclear => {
        args => ['Bit_T', 'int'],
        ret  => 'void',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_clear => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'void',
        check => sub {
            my ($set, $lo, $hi) = @_;
            die "Bit set cannot be null" if !defined $set;
            die "low bit must be >= 0" if $lo < 0;
            die "low bit must be <= high bit" if $lo > $hi;
        }
    },
    Bit_get => {
        args => ['Bit_T', 'int'],
        ret  => 'int',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_not => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'void',
        check => sub {
            my ($set, $lo, $hi) = @_;
            die "Bit set cannot be null" if !defined $set;
            die "low bit must be >= 0" if $lo < 0;
            die "low bit must be <= high bit" if $lo > $hi;
        }
    },
    Bit_put => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'int',
        check => sub { die "Bit set cannot be null" if !defined $_[0]; }
    },
    Bit_set => {
        args => ['Bit_T', 'int', 'int'],
        ret  => 'void',
        check => sub {
            my ($set, $lo, $hi) = @_;
            die "Bit set cannot be null" if !defined $set;
            die "low bit must be >= 0" if $lo < 0;
            die "low bit must be <= high bit" if $lo > $hi;
        }
    },

    # Comparison
    Bit_eq => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
        check => sub { die "Bit sets cannot be null" if !defined $_[0] || !defined $_[1]; }
    },
    Bit_leq => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
        check => sub { die "Bit sets cannot be null" if !defined $_[0] || !defined $_[1]; }
    },
    Bit_lt => {
        args => ['Bit_T', 'Bit_T'],
        ret  => 'int',
        check => sub { die "Bit sets cannot be null" if !defined $_[0] || !defined $_[1]; }
    },

    # Set Operations
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

    # Set Operation Counts
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

    $ffi->attach(@attach_args);
}

# Verification: Ensure all expected functions are implemented.
my @c_functions = qw(
    Bit_new Bit_free Bit_load Bit_extract Bit_buffer_size Bit_length Bit_count
    Bit_aset Bit_bset Bit_aclear Bit_bclear Bit_clear Bit_get Bit_not Bit_put Bit_set
    Bit_eq Bit_leq Bit_lt
    Bit_diff Bit_inter Bit_minus Bit_union
    Bit_diff_count Bit_inter_count Bit_minus_count Bit_union_count
);

my %perl_functions;
@perl_functions{keys %functions} = ();
for my $c_func (@c_functions) {
    die "FATAL: C function '$c_func' not implemented in Bit::Set"
        unless exists $perl_functions{$c_func};
}


1;

__END__

=head1 NAME

Bit::Set - Perl interface for the high-performance 'bit' C library

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use Bit::Set;

  # Create a new bitset of 1024 bits
  my $set = Bit::Set::Bit_new(1024);

  # Set some bits
  Bit::Set::Bit_bset($set, 1);
  Bit::Set::Bit_bset($set, 2);
  Bit::Set::Bit_bset($set, 5);

  # Get the population count
  my $count = Bit::Set::Bit_count($set);
  print "Population count: $count\n"; # Should be 3

  # Free the bitset
  Bit::Set::Bit_free(\$set);

=head1 DESCRIPTION

This module provides a procedural Perl interface to the C library C<bit.h>,
for creating and manipulating bitsets. It uses C<FFI::Platypus> to wrap the C
functions and C<Alien::Bit> to locate and link to the C library.

The API is a direct mapping of the C functions. For detailed semantics of each
function, please refer to the C<bit.h> header file documentation.

Runtime checks on arguments are performed if the C<DEBUG> environment variable
is set to a true value.

=head1 FUNCTIONS

=head2 Creation and Destruction

=over 4

=item B<Bit_new(length)>

Creates a new bitset of C<length> bits.

=item B<Bit_free(set_ref)>

Frees the memory associated with the bitset. Expects a reference to the scalar holding the bitset object.

=item B<Bit_load(length, buffer)>

Loads a bitset of C<length> from an external C<buffer>.

=item B<Bit_extract(set, buffer)>

Extracts a bitset from C<set> into an external C<buffer>.

=back

=head2 Properties

=over 4

=item B<Bit_buffer_size(length)>

Returns the size in bytes required to store a bitset of C<length>.

=item B<Bit_length(set)>

Returns the length (capacity) of the bitset in bits.

=item B<Bit_count(set)>

Returns the number of set bits (population count) in the bitset.

=back

=head2 Bit Manipulation

=over 4

=item B<Bit_aset(set, indices, n)>

Sets an array of C<n> bits in the bitset from C<indices>.

=item B<Bit_bset(set, index)>

Sets a single bit at C<index> in the bitset.

=item B<Bit_aclear(set, indices, n)>

Clears an array of C<n> bits in the bitset from C<indices>.

=item B<Bit_bclear(set, index)>

Clears a single bit at C<index> in the bitset.

=item B<Bit_clear(set, lo, hi)>

Clears a range of bits in the bitset from C<lo> to C<hi> (inclusive).

=item B<Bit_get(set, index)>

Gets the value of a bit at a given C<index>.

=item B<Bit_not(set, lo, hi)>

Inverts a range of bits in the bitset from C<lo> to C<hi> (inclusive).

=item B<Bit_put(set, n, val)>

Sets the C<n>-th bit to C<val>.

=item B<Bit_set(set, lo, hi)>

Sets a range of bits in the bitset from C<lo> to C<hi> (inclusive).

=back

=head2 Comparison

=over 4

=item B<Bit_eq(s, t)>

Checks if two bitsets C<s> and C<t> are equal.

=item B<Bit_leq(s, t)>

Checks if bitset C<s> is a subset of or equal to bitset C<t>.

=item B<Bit_lt(s, t)>

Checks if bitset C<s> is a proper subset of bitset C<t>.

=back

=head2 Set Operations

=over 4

=item B<Bit_diff(s, t)>

Returns a new bitset that is the symmetric difference of C<s> and C<t>.

=item B<Bit_inter(s, t)>

Returns a new bitset that is the intersection of C<s> and C<t>.

=item B<Bit_minus(s, t)>

Returns a new bitset that is the difference of C<s> and C<t>.

=item B<Bit_union(s, t)>

Returns a new bitset that is the union of C<s> and C<t>.

=back

=head2 Set Operation Counts

=over 4

=item B<Bit_diff_count(s, t)>

Returns the population count of the symmetric difference of C<s> and C<t>.

=item B<Bit_inter_count(s, t)>

Returns the population count of the intersection of C<s> and C<t>.

=item B<Bit_minus_count(s, t)>

Returns the population count of the difference of C<s> and C<t>.

=item B<Bit_union_count(s, t)>

Returns the population count of the union of C<s> and C<t>.

=back

=head1 AUTHOR

GitHub Copilot, guided by a senior Perl engineer.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Christos Argyropoulos.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
