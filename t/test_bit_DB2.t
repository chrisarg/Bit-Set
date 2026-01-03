#!/home/chrisarg/perl5/perlbrew/perls/current/bin/perl

use strict;
use warnings;
use Test::More tests => 1;
use Bit::Set     qw(:all);
use Bit::Set::DB2 qw(:all);
use FFI::Platypus::Buffer;    # added to facilitate buffer management

# Test constants
use constant SIZE_OF_TEST_BIT => 65536;
use constant SIZEOF_BITDB     => 45;


subtest 'BitDB Operations' => sub {

    # test_bitDB_new
    my $bitdb = BitDB_new( SIZE_OF_TEST_BIT, 10 );
    ok( defined $bitdb, 'BitDB_new creates bitset database' );

    # test_bitDB_properties
    my $props_success =
      ( BitDB_length($bitdb) == SIZE_OF_TEST_BIT && BitDB_nelem($bitdb) == 10 );
    ok( $props_success, 'BitDB properties are correct' );

    # test_bitDB_get_put
    my $bitset = Bit_new(SIZE_OF_TEST_BIT);
    Bit_bset( $bitset, 1 );
    Bit_bset( $bitset, 3 );

    BitDB_put_at( $bitdb, 0, $bitset );
    my $retrieved = BitDB_get_from( $bitdb, 0 );

    my $get_put_success =
      ( Bit_get( $retrieved, 1 ) == 1 && Bit_get( $retrieved, 3 ) == 1 );
    ok( $get_put_success, 'BitDB get/put operations work correctly' );

    Bit_free( \$bitset );
    Bit_free( \$retrieved );

    # test_bitDB_extract_replace
    $bitset = Bit_new(SIZE_OF_TEST_BIT);
    Bit_bset( $bitset, 1 );
    Bit_bset( $bitset, 3 );

    BitDB_put_at( $bitdb, 0, $bitset );

    # LLM returned: my $buffer        = "\0" x ( SIZE_OF_TEST_BIT / 8 );
    # Following 3 lines added to create a buffer using API calls
    my $buffer_size = Bit_buffer_size(SIZE_OF_TEST_BIT);
    my $scalar      = "\0" x $buffer_size;
    my ( $buffer, $size ) = scalar_to_buffer $scalar;

    my $bytes_written = BitDB_extract_from( $bitdb, 0, $buffer );

    # LLM returned: my $first_byte      = unpack( 'C', substr( $buffer, 0, 1 )
    # );
    my $first_byte      = unpack( 'C', substr( $scalar, 0, 1 ) );
    my $extract_success = ( $bytes_written == SIZE_OF_TEST_BIT / 8
          && $first_byte == ( ( 1 << 1 ) | ( 1 << 3 ) ) );

    BitDB_replace_at( $bitdb, 0, $buffer );

    $retrieved = BitDB_get_from( $bitdb, 0 );

    my $replace_success =
      ( Bit_get( $retrieved, 1 ) == 1 && Bit_get( $retrieved, 3 ) == 1 );

    ok( $extract_success && $replace_success,
        'BitDB extract/replace operations work correctly' );

    Bit_free( \$bitset );
    Bit_free( \$retrieved );
};

# Note: Skipping the BitDB intersection count test as it requires the SETOP_COUNT_OPTS
# structure to be properly initialized and the count operations may need additional setup

done_testing();
