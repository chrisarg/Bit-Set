package Bit::Set::SETOP_COUNT_OPTS;
$Bit::Set::SETOP_COUNT_OPTS::VERSION = '0.01';
use strict;
use warnings;

use parent 'FFI::Platypus::Record';

record_layout_1(
    'num_cpu_threads'     => 'sint',
    'device_id'           => 'sint',
    'upd_1st_operand'     => 'bool',
    'upd_2nd_operand'     => 'bool',
    'release_1st_operand' => 'bool',
    'release_2nd_operand' => 'bool',
    'release_counts'      => 'bool',
);

1;
