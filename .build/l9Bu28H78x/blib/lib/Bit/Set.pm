package Bit::Set;

use strict;
use warnings;
use FFI::Platypus 2.00;
use Alien::Bit;

our $VERSION = '0.01';

# FFI setup
my $ffi = FFI::Platypus->new(api => 2);
$ffi->lib(Alien::Bit->dynamic_libs);

# Define opaque types
$ffi->type('opaque' => 'Bit_T');

# Table-driven function attachments
my %functions = (
    Bit_new => {
        signature => ['int'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "Bit_new: length must be >= 0 and <= INT_MAX" if $_[0] < 0 || $_[0] > 2**31 - 1; } },
    },
    Bit_free => {
        signature => ['Bit_T*'] => 'opaque',
        check => sub { if ($ENV{DEBUG}) { die "Bit_free: set is NULL" unless $_[0]; } },
    },
    Bit_load => {
        signature => ['int', 'opaque'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "Bit_load: length invalid or buffer NULL" if $_[0] < 0 || $_[0] > 2**31 - 1 || !$_[1]; } },
    },
    Bit_extract => {
        signature => ['Bit_T', 'opaque'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_extract: set NULL or buffer NULL" unless $_[0] && $_[1]; } },
    },
    Bit_buffer_size => {
        signature => ['int'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_buffer_size: length invalid" if $_[0] < 0 || $_[0] > 2**31 - 1; } },
    },
    Bit_length => {
        signature => ['Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_length: set NULL" unless $_[0]; } },
    },
    Bit_count => {
        signature => ['Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_count: set NULL" unless $_[0]; } },
    },
    Bit_aset => {
        signature => ['Bit_T', 'int[]', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_aset: set NULL or indices invalid" unless $_[0] && $_[1] && $_[2] >= 0; } },
    },
    Bit_bset => {
        signature => ['Bit_T', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_bset: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    Bit_aclear => {
        signature => ['Bit_T', 'int[]', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_aclear: set NULL or indices invalid" unless $_[0] && $_[1] && $_[2] >= 0; } },
    },
    Bit_bclear => {
        signature => ['Bit_T', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_bclear: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    Bit_clear => {
        signature => ['Bit_T', 'int', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_clear: set NULL or range invalid" unless $_[0] && $_[1] >= 0 && $_[2] >= $_[1]; } },
    },
    Bit_get => {
        signature => ['Bit_T', 'int'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_get: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    Bit_not => {
        signature => ['Bit_T', 'int', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_not: set NULL or range invalid" unless $_[0] && $_[1] >= 0 && $_[2] >= $_[1]; } },
    },
    Bit_put => {
        signature => ['Bit_T', 'int', 'int'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_put: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    Bit_set => {
        signature => ['Bit_T', 'int', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "Bit_set: set NULL or range invalid" unless $_[0] && $_[1] >= 0 && $_[2] >= $_[1]; } },
    },
    Bit_eq => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_eq: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_leq => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_leq: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_lt => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_lt: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_diff => {
        signature => ['Bit_T', 'Bit_T'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "Bit_diff: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_inter => {
        signature => ['Bit_T', 'Bit_T'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "Bit_inter: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_minus => {
        signature => ['Bit_T', 'Bit_T'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "Bit_minus: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_union => {
        signature => ['Bit_T', 'Bit_T'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "Bit_union: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_diff_count => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_diff_count: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_inter_count => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_inter_count: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_minus_count => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_minus_count: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    Bit_union_count => {
        signature => ['Bit_T', 'Bit_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "Bit_union_count: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    }
);

# Attach functions with checks
for my $name (keys %functions) {
    my $spec = $functions{$name};
    $ffi->attach($name => $spec->{signature}, sub {
        my $sub = shift;
        $spec->{check}->(@_) if $ENV{DEBUG};
        return $sub->(@_);
    });
}

our @EXPORT = keys %functions;

# POD Documentation
=head1 NAME

Bit::Set - Procedural Perl API for Bit_T functions from bit.h

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    use Bit::Set;

    my $bitset = Bit_new(1024);
    Bit_bset($bitset, 0);
    print Bit_count($bitset);  # 1

=head1 FUNCTIONS

All functions from bit.h are implemented with exact names. See bit.h for details.

=head1 AUTHOR

Generated by senior Perl engineer.

=cut

1;
