package Bit::Set::DB;

use strict;
use warnings;
use FFI::Platypus 2.00;
use Alien::Bit;

our $VERSION = '0.01';

# FFI setup
my $ffi = FFI::Platypus->new(api => 2);
$ffi->lib(Alien::Bit->dynamic_libs);

# Define opaque types
$ffi->type('opaque' => 'Bit_DB_T');

# Nested package for SETOP_COUNT_OPTS
{
    package Bit::Set::DB::SETOP_COUNT_OPTS;
    use parent 'FFI::Platypus::Record';
    record_layout(
        'int' => 'num_cpu_threads',
        'int' => 'device_id',
        'bool' => 'upd_1st_operand',
        'bool' => 'upd_2nd_operand',
        'bool' => 'release_1st_operand',
        'bool' => 'release_2nd_operand',
        'bool' => 'release_counts',
    );
}

# Register the record type
$ffi->type('record(Bit::Set::DB::SETOP_COUNT_OPTS)' => 'SETOP_COUNT_OPTS');

# Table-driven function attachments
my %functions = (
    BitDB_new => {
        signature => ['int', 'int'] => 'Bit_DB_T',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_new: length or num invalid" if $_[0] < 0 || $_[0] > 2**31 - 1 || $_[1] < 0; } },
    },
    BitDB_free => {
        signature => ['Bit_DB_T*'] => 'opaque',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_free: set NULL" unless $_[0]; } },
    },
    BitDB_length => {
        signature => ['Bit_DB_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_length: set NULL" unless $_[0]; } },
    },
    BitDB_nelem => {
        signature => ['Bit_DB_T'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_nelem: set NULL" unless $_[0]; } },
    },
    BitDB_count_at => {
        signature => ['Bit_DB_T', 'int'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_count_at: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    BitDB_count => {
        signature => ['Bit_DB_T'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_count: set NULL" unless $_[0]; } },
    },
    BitDB_clear_at => {
        signature => ['Bit_DB_T', 'int'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_clear_at: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    BitDB_clear => {
        signature => ['Bit_DB_T'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_clear: set NULL" unless $_[0]; } },
    },
    BitDB_get_from => {
        signature => ['Bit_DB_T', 'int'] => 'Bit_T',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_get_from: set NULL or index invalid" unless $_[0] && $_[1] >= 0; } },
    },
    BitDB_put_at => {
        signature => ['Bit_DB_T', 'int', 'Bit_T'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_put_at: set NULL or index invalid" unless $_[0] && $_[1] >= 0 && $_[2]; } },
    },
    BitDB_extract_from => {
        signature => ['Bit_DB_T', 'int', 'opaque'] => 'int',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_extract_from: set NULL, index invalid, or buffer NULL" unless $_[0] && $_[1] >= 0 && $_[2]; } },
    },
    BitDB_replace_at => {
        signature => ['Bit_DB_T', 'int', 'opaque'] => 'void',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_replace_at: set NULL, index invalid, or buffer NULL" unless $_[0] && $_[1] >= 0 && $_[2]; } },
    },
    BitDB_inter_count_store_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_inter_count_store_cpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_inter_count_store_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_inter_count_store_gpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_inter_count_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_inter_count_cpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_inter_count_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_inter_count_gpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_union_count_store_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_union_count_store_cpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_union_count_store_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_union_count_store_gpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_union_count_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_union_count_cpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_union_count_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_union_count_gpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_diff_count_store_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_diff_count_store_cpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_diff_count_store_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_diff_count_store_gpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_diff_count_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_diff_count_cpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_diff_count_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_diff_count_gpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_minus_count_store_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_minus_count_store_cpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_minus_count_store_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'int*', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_minus_count_store_gpu: sets NULL or lengths differ" unless $_[0] && $_[1] && $_[2]; } },
    },
    BitDB_minus_count_cpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_minus_count_cpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
    BitDB_minus_count_gpu => {
        signature => ['Bit_DB_T', 'Bit_DB_T', 'SETOP_COUNT_OPTS'] => 'int*',
        check => sub { if ($ENV{DEBUG}) { die "BitDB_minus_count_gpu: sets NULL or lengths differ" unless $_[0] && $_[1]; } },
    },
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

Bit::Set::DB - Procedural Perl API for Bit_DB_T functions from bit.h

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    use Bit::Set::DB;

    my $db = BitDB_new(1024, 10);
    # ... use functions

=head1 FUNCTIONS

All functions from bit.h are implemented with exact names. See bit.h for details.

=head1 AUTHOR

Generated by senior Perl engineer.

=cut

1;
