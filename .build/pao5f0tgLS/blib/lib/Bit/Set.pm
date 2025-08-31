#!/home/chrisarg/perl5/perlbrew/perls/current/bin/perl
package Bit::Set;

use strict;
use warnings;

use FFI::Platypus;
use Alien::Bit;

our $VERSION = '0.01';

# Set up the FFI object
my $ffi = FFI::Platypus->new( api => 2 );
$ffi->lib( Alien::Bit->dynamic_libs );

# Define opaque types
$ffi->type( 'opaque' => 'Bit_T' );

# Define a helper for debug checks that can be stripped at compile time
# LLM provided this: use constant DEBUG => $ENV{DEBUG};
BEGIN {
    use constant DEBUG =>$ENV{DEBUG} //0;
    if (DEBUG) {
        print "* Debugging is enabled\n";
    } else {
        print "* Debugging is disabled\n";
    }
}
# Function definitions for FFI attachment - table-driven approach
my %functions = (

    # Creation / Destruction / Properties
    Bit_new => {
        args  => ['int'],
        ret   => 'Bit_T',
        check => sub {
            my ($length) = @_;
            die "Bit_new: length must be >= 0 and <= INT_MAX"
              if $length < 0 || $length > 2147483647;
        }
    },
    Bit_free => {
        args => ['Bit_T*'],
        ret  => 'opaque',
    },
    Bit_load => {
        args  => [ 'int', 'opaque' ],
        ret   => 'Bit_T',
        check => sub {
            my ( $length, $buffer ) = @_;
            die "Bit_load: length must be >= 0 and <= INT_MAX"
              if $length < 0 || $length > 2147483647;
            die "Bit_load: buffer cannot be NULL" if !defined $buffer;
        }
    },
    Bit_extract => {
        args  => [ 'Bit_T', 'opaque' ],
        ret   => 'int',
        check => sub {
            my ( $set, $buffer ) = @_;
            die "Bit_extract: set cannot be NULL"    if !defined $set;
            die "Bit_extract: buffer cannot be NULL" if !defined $buffer;
        }
    },
    Bit_buffer_size => {
        args  => ['int'],
        ret   => 'int',
        check => sub {
            my ($length) = @_;
            die "Bit_buffer_size: length must be >= 0 and <= INT_MAX"
              if $length < 0 || $length > 2147483647;
        }
    },
    Bit_length => {
        args  => ['Bit_T'],
        ret   => 'int',
        check => sub {
            my ($set) = @_;
            die "Bit_length: set cannot be NULL" if !defined $set;
        }
    },
    Bit_count => {
        args  => ['Bit_T'],
        ret   => 'int',
        check => sub {
            my ($set) = @_;
            die "Bit_count: set cannot be NULL" if !defined $set;
        }
    },

    # Manipulation functions
    Bit_aset => {
        args  => [ 'Bit_T', 'int[]', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $indices, $n ) = @_;
            die "Bit_aset: set cannot be NULL"           if !defined $set;
            die "Bit_aset: indices array cannot be NULL" if !defined $indices;
            die "Bit_aset: n must be >= 0"               if $n < 0;
        }
    },
    Bit_bset => {
        args  => [ 'Bit_T', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $index ) = @_;
            die "Bit_bset: set cannot be NULL" if !defined $set;
            die "Bit_bset: index must be >= 0" if $index < 0;
        }
    },
    Bit_aclear => {
        args  => [ 'Bit_T', 'int[]', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $indices, $n ) = @_;
            die "Bit_aclear: set cannot be NULL"           if !defined $set;
            die "Bit_aclear: indices array cannot be NULL" if !defined $indices;
            die "Bit_aclear: n must be >= 0"               if $n < 0;
        }
    },
    Bit_bclear => {
        args  => [ 'Bit_T', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $index ) = @_;
            die "Bit_bclear: set cannot be NULL" if !defined $set;
            die "Bit_bclear: index must be >= 0" if $index < 0;
        }
    },
    Bit_clear => {
        args  => [ 'Bit_T', 'int', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $lo, $hi ) = @_;
            die "Bit_clear: set cannot be NULL" if !defined $set;
            die "Bit_clear: lo must be >= 0"    if $lo < 0;
            die "Bit_clear: hi must be >= lo"   if $hi < $lo;
        }
    },
    Bit_get => {
        args  => [ 'Bit_T', 'int' ],
        ret   => 'int',
        check => sub {
            my ( $set, $index ) = @_;
            die "Bit_get: set cannot be NULL" if !defined $set;
            die "Bit_get: index must be >= 0" if $index < 0;
        }
    },
    Bit_not => {
        args  => [ 'Bit_T', 'int', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $lo, $hi ) = @_;
            die "Bit_not: set cannot be NULL" if !defined $set;
            die "Bit_not: lo must be >= 0"    if $lo < 0;
            die "Bit_not: hi must be >= lo"   if $hi < $lo;
        }
    },
    Bit_put => {
        args  => [ 'Bit_T', 'int', 'int' ],
        ret   => 'int',
        check => sub {
            my ( $set, $n, $val ) = @_;
            die "Bit_put: set cannot be NULL" if !defined $set;
            die "Bit_put: n must be >= 0"     if $n < 0;
        }
    },
    Bit_set => {
        args  => [ 'Bit_T', 'int', 'int' ],
        ret   => 'void',
        check => sub {
            my ( $set, $lo, $hi ) = @_;
            die "Bit_set: set cannot be NULL" if !defined $set;
            die "Bit_set: lo must be >= 0"    if $lo < 0;
            die "Bit_set: hi must be >= lo"   if $hi < $lo;
        }
    },

    # Comparison functions
    Bit_eq => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_eq: bitsets cannot be NULL" if !defined $s || !defined $t;
        }
    },
    Bit_leq => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_leq: bitsets cannot be NULL" if !defined $s || !defined $t;
        }
    },
    Bit_lt => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_lt: bitsets cannot be NULL" if !defined $s || !defined $t;
        }
    },

    # Set operations
    Bit_diff => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'Bit_T',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_diff: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
    Bit_inter => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'Bit_T',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_inter: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
    Bit_minus => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'Bit_T',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_minus: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
    Bit_union => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'Bit_T',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_union: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },

    # Set operation counts
    Bit_diff_count => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_diff_count: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
    Bit_inter_count => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_inter_count: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
    Bit_minus_count => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_minus_count: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
    Bit_union_count => {
        args  => [ 'Bit_T', 'Bit_T' ],
        ret   => 'int',
        check => sub {
            my ( $s, $t ) = @_;
            die "Bit_union_count: bitsets cannot be NULL"
              if !defined $s || !defined $t;
        }
    },
);

# Attach all functions
for my $name ( sort keys %functions ) {
    my $spec        = $functions{$name};
    my @attach_args = ( $name, $spec->{args}, $spec->{ret} );

    if ( DEBUG )
    { ##  if (DEBUG && exists $spec->{check}) { -> LLM version, break into nested ifs
        if ( exists $spec->{check} ) {
            my $checker = $spec->{check};
            push @attach_args, wrapper => sub { # as created by the LLM
                my $orig = shift;
                $checker->(@_);
                return $orig->(@_);
            };
        }
    }

    $ffi->attach(@attach_args);
}

# Verification that all C functions are mapped (excluding macros and Bit_map)
my @c_functions = qw(
  Bit_new Bit_free Bit_load Bit_extract Bit_buffer_size Bit_length Bit_count
  Bit_aset Bit_bset Bit_aclear Bit_bclear Bit_clear Bit_get Bit_not Bit_put Bit_set
  Bit_eq Bit_leq Bit_lt
  Bit_diff Bit_inter Bit_minus Bit_union
  Bit_diff_count Bit_inter_count Bit_minus_count Bit_union_count
);

my %perl_functions;
@perl_functions{ keys %functions } = ();
for my $c_func (@c_functions) {
    die "FATAL: C function '$c_func' not implemented in Bit::Set"
      unless exists $perl_functions{$c_func};
}

# LLM forgot to export the Bit::Set functions
use Exporter 'import';
our @EXPORT_OK   = keys %functions;
our %EXPORT_TAGS = ( all => [@EXPORT_OK] );

1;

__END__

=head1 NAME

Bit::Set - Perl interface for bitset functions from the 'bit' C library

=head1 VERSION

version 0.01

=head1 SYNOPSIS

  use Bit::Set;

  # Create a new bitset
  my $set = Bit_new(1024);

  # Set some bits
  Bit_bset($set, 0);
  Bit_bset($set, 42);

  # Get population count
  my $count = Bit_count($set);

  # Free the bitset
  Bit_free(\$set);

=head1 DESCRIPTION

This module provides a procedural Perl interface to the C library 'bit.h',
for creating and manipulating bitsets. It uses C<FFI::Platypus> to wrap the
C functions and C<Alien::Bit> to locate and link to the C library.

The API is a direct mapping of the C functions. For detailed semantics of each
function, please refer to the C<bit.h> header file documentation.

Runtime checks on arguments are performed if the C<DEBUG> environment variable
is set to a true value.

=head1 FUNCTIONS

=head2 Creation and Destruction

=over 4

=item B<Bit_new(length)>

Creates a new bitset with the specified capacity in bits.

=item B<Bit_free(set_ref)>

Frees the memory associated with the bitset. Expects a reference to the scalar holding the bitset.

=item B<Bit_load(length, buffer)>

Loads an externally allocated bitset into a new Bit_T structure.

=item B<Bit_extract(set, buffer)>

Extracts the bitset from a Bit_T into an externally allocated buffer.

=back

=head2 Properties

=over 4

=item B<Bit_buffer_size(length)>

Returns the number of bytes needed to store a bitset of given length.

=item B<Bit_length(set)>

Returns the length (capacity) of the bitset in bits.

=item B<Bit_count(set)>

Returns the population count (number of set bits) of the bitset.

=back

=head2 Manipulation

=over 4

=item B<Bit_aset(set, indices, n)>

Sets an array of bits specified by indices.

=item B<Bit_bset(set, index)>

Sets a single bit at the specified index to 1.

=item B<Bit_aclear(set, indices, n)>

Clears an array of bits specified by indices.

=item B<Bit_bclear(set, index)>

Clears a single bit at the specified index to 0.

=item B<Bit_clear(set, lo, hi)>

Clears a range of bits from lo to hi (inclusive).

=item B<Bit_get(set, index)>

Returns the value of the bit at the specified index.

=item B<Bit_not(set, lo, hi)>

Inverts a range of bits from lo to hi (inclusive).

=item B<Bit_put(set, n, val)>

Sets the nth bit to val and returns the previous value.

=item B<Bit_set(set, lo, hi)>

Sets a range of bits from lo to hi (inclusive) to 1.

=back

=head2 Comparisons

=over 4

=item B<Bit_eq(s, t)>

Returns 1 if bitsets s and t are equal, 0 otherwise.

=item B<Bit_leq(s, t)>

Returns 1 if bitset s is a subset of or equal to t, 0 otherwise.

=item B<Bit_lt(s, t)>

Returns 1 if bitset s is a proper subset of t, 0 otherwise.

=back

=head2 Set Operations

=over 4

=item B<Bit_diff(s, t)>

Returns a new bitset containing the difference of s and t.

=item B<Bit_inter(s, t)>

Returns a new bitset containing the intersection of s and t.

=item B<Bit_minus(s, t)>

Returns a new bitset containing the symmetric difference of s and t.

=item B<Bit_union(s, t)>

Returns a new bitset containing the union of s and t.

=back

=head2 Set Operation Counts

=over 4

=item B<Bit_diff_count(s, t)>

Returns the population count of the difference of s and t without creating a new bitset.

=item B<Bit_inter_count(s, t)>

Returns the population count of the intersection of s and t without creating a new bitset.

=item B<Bit_minus_count(s, t)>

Returns the population count of the symmetric difference of s and t without creating a new bitset.

=item B<Bit_union_count(s, t)>

Returns the population count of the union of s and t without creating a new bitset.

=back

=head1 AUTHOR

GitHub Copilot, guided by a senior Perl engineer.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2025 by Christos Argyropoulos.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
