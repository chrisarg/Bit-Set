package Bit::Set::DB;
$Bit::Set::DB::VERSION = '0.01';
use strict;
use warnings;
use FFI::Platypus;
use FFI::Platypus::Memory qw(malloc free);
use FFI::Platypus::Buffer qw(scalar_to_buffer buffer_to_scalar);
use Bit::Set;
use Alien::Bit;

=head1 NAME

Bit::Set::DB - Provides an interface for bitset manipulations in contiguous memory buffers (containers)

=head1 VERSION

version 0.01

=cut

# Create FFI::Platypus object
my $ffi = FFI::Platypus->new(api => 2);

# Add path to our dynamic library
$ffi->lib(Alien::Bit->dynamic_libs);

# Define opaque types for our bitset pointers
$ffi->type('opaque' => 'Bit_T');
$ffi->type('opaque' => 'Bit_T_DB');
$ffi->type('opaque*' => 'Bit_T_DB_Ptr');

# Define struct for SETOP_COUNT_OPTS
$ffi->type('record(SETOP_COUNT_OPTS)' => [
    num_cpu_threads => 'int',
    device_id => 'int',
    upd_1st_operand => 'bool',
    upd_2nd_operand => 'bool',
    release_1st_operand => 'bool',
    release_2nd_operand => 'bool',
    release_counts => 'bool'
]);

# Define Bit_T_DB functions
$ffi->attach(BitDB_new => ['int', 'int'] => 'Bit_T_DB' => sub {
    my ($xsub, $self, $length, $num_of_bitsets) = @_;
    die "Length must be a positive integer" unless defined $length && $length > 0;
    die "Number of bitsets must be a positive integer" unless defined $num_of_bitsets && $num_of_bitsets > 0;
    my $db = $xsub->($length, $num_of_bitsets);
    die "Failed to create bitset DB" unless $db;
    return bless { _handle => $db }, $self;
});

$ffi->attach(BitDB_free => ['Bit_T_DB_Ptr'] => 'opaque' => sub {
    my ($xsub, $self) = @_;
    my $ptr = \$self->{_handle};
    return $xsub->($ptr);
});

$ffi->attach(BitDB_length => ['Bit_T_DB'] => 'int' => sub {
    my ($xsub, $self) = @_;
    return $xsub->($self->{_handle});
});

$ffi->attach(BitDB_nelem => ['Bit_T_DB'] => 'int' => sub {
    my ($xsub, $self) = @_;
    return $xsub->($self->{_handle});
});

$ffi->attach(BitDB_count_at => ['Bit_T_DB', 'int'] => 'int' => sub {
    my ($xsub, $self, $index) = @_;
    die "Index must be non-negative" unless defined $index && $index >= 0;
    return $xsub->($self->{_handle}, $index);
});

$ffi->attach(BitDB_clear => ['Bit_T_DB'] => 'void' => sub {
    my ($xsub, $self) = @_;
    $xsub->($self->{_handle});
});

$ffi->attach(BitDB_clear_at => ['Bit_T_DB', 'int'] => 'void' => sub {
    my ($xsub, $self, $index) = @_;
    die "Index must be non-negative" unless defined $index && $index >= 0;
    $xsub->($self->{_handle}, $index);
});

$ffi->attach(BitDB_get_from => ['Bit_T_DB', 'int'] => 'Bit_T' => sub {
    my ($xsub, $self, $index) = @_;
    die "Index must be non-negative" unless defined $index && $index >= 0;
    my $bit_handle = $xsub->($self->{_handle}, $index);
    return bless { _handle => $bit_handle }, 'Bit::Set';
});

$ffi->attach(BitDB_put_at => ['Bit_T_DB', 'int', 'Bit_T'] => 'void' => sub {
    my ($xsub, $self, $index, $bitset) = @_;
    die "Index must be non-negative" unless defined $index && $index >= 0;
    die "Bitset must be a Bit::Set object" unless ref $bitset eq 'Bit::Set';
    $xsub->($self->{_handle}, $index, $bitset->{_handle});
});

# CPU-specific intersection count function
$ffi->attach(BitDB_inter_count_cpu => ['Bit_T_DB', 'Bit_T_DB', 'SETOP_COUNT_OPTS'] => 'int*' => sub {
    my ($xsub, $self, $other, $opts) = @_;
    die "Other must be a Bit::Set::DB object" unless ref $other eq ref $self;
    $opts ||= { 
        num_cpu_threads => 1, 
        device_id => -1, 
        upd_1st_operand => 0, 
        upd_2nd_operand => 0,
        release_1st_operand => 0,
        release_2nd_operand => 0,
        release_counts => 0
    };
    return $xsub->($self->{_handle}, $other->{_handle}, $opts);
});

# Constructor and destructor
sub new {
    my ($class, $length, $num_of_bitsets) = @_;
    return $class->BitDB_new($length, $num_of_bitsets);
}

sub DESTROY {
    my ($self) = @_;
    $self->BitDB_free() if defined $self->{_handle};
}

# Convenient accessor methods
sub length {
    my ($self) = @_;
    return $self->BitDB_length();
}

sub num_of_bitsets {
    my ($self) = @_;
    return $self->BitDB_nelem();
}

sub count_at {
    my ($self, $index) = @_;
    return $self->BitDB_count_at($index);
}

sub clear {
    my ($self) = @_;
    $self->BitDB_clear();
    return $self;
}

sub clear_at {
    my ($self, $index) = @_;
    $self->BitDB_clear_at($index);
    return $self;
}

sub get_bitset {
    my ($self, $index) = @_;
    return $self->BitDB_get_from($index);
}

sub put_bitset {
    my ($self, $index, $bitset) = @_;
    $self->BitDB_put_at($index, $bitset);
    return $self;
}

sub intersection_count_cpu {
    my ($self, $other, $opts) = @_;
    return $self->BitDB_inter_count_cpu($other, $opts);
}

1;
