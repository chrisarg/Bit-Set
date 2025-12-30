#!/usr/bin/env -S perl -Ilib -Iblib/arch
use Test::More tests => 1;
use POSIX 'dup2';
dup2 fileno(STDERR), fileno(STDOUT);
use strict;
use warnings;
use Benchmark ':all';
use base 'sealed';
use sealed 'deparse';

use Bit::Set ':all';
use Bit::Set::OO;


use constant SIZE_OF_TEST_BIT => 65536;
use constant SIZEOF_BITDB     => 45;

my @b;

cmpthese 2_000_000, {
  bsoo => sub {
    my $b = Bit::Set->new(SIZE_OF_TEST_BIT);
    $b->bset(2);
    $b->put(3, 1);
    die unless $b->get(2) == 1;
    die unless $b->get(3) == 1;
#    push @b, $b;
#    if (@b >= 1_000_000) {
#      undef $b;
#      pop @b while @b;
#    }
    undef $b;
  },

  sealed => sub :Sealed {
    my Bit::Set $b;
    $b = $b->new(SIZE_OF_TEST_BIT);
    $b->bset(2);
    $b->put(3, 1);
    die unless $b->get(2) == 1;
    die unless $b->get(3) == 1;
#    push @b, $b;
#    if (@b >= 1_000_000) {
#      undef $b;
#      pop @b while @b;
#    }
    undef $b;
  },

  bs => sub {
    my $b = Bit_new(SIZE_OF_TEST_BIT);
    Bit_bset($b,2);
    Bit_put($b,3,1);
    die unless Bit_get($b, 2) == 1;
    die unless Bit_get($b, 3) == 1;
#    push @b, $b;
#    if (@b >= 1_000_000) {
#      undef $b;
#      Bit_free(\ pop @b) while @b;
#    }
    Bit_free(\$b);
  },

};

ok(1);

cmpthese 2_000, {
  T_alloc => sub :Sealed {
    my Bit::Set $b;
    push @b, $b->new(SIZE_OF_TEST_BIT, 10000);
    pop @b while @b;
  },

  new_loop => sub :Sealed {
    my Bit::Set $b;
    push @b, $b->new(SIZE_OF_TEST_BIT) for 1..10000;
    pop @b while @b;
  },

};

__END__
