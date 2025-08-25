package Bit::Set;
$Bit::Set::VERSION = '0.01';
use strict;
use warnings;

use Alien::Bit;
use FFI::Platypus;
use FFI::Platypus::Memory qw(malloc free);
use FFI::Platypus::Buffer qw(scalar_to_buffer buffer_to_scalar);

BEGIN {
    use constant DEBUG => $ENV{DEBUG} // 0;
}

=head1 NAME

Bit::Set - Provides an interface to the Bit libraries for bitset manipulations

=head1 VERSION

version 0.01

=cut

# Create FFI::Platypus object
my $ffi = FFI::Platypus->new( api => 2 );

# Add path to our dynamic library
$ffi->lib( Alien::Bit->dynamic_libs );

# Define opaque types for our bitset pointers
$ffi->type( 'opaque'  => 'Bit_T' );
$ffi->type( 'opaque*' => 'Bit_T_Ptr' );

$ffi->attach(
    Bit_debug => ['Bit_T_Ptr'] => 'void' => sub {
        my ( $xsub, $self ) = @_;
        $xsub->( \$self->{_handle} );
    }
);

# Define our Bit_T functions
$ffi->attach(
    Bit_new => ['int'] => 'Bit_T' => sub {
        my ( $xsub, $self, $length ) = @_;
        if (DEBUG) {
            die "Length must be a positive integer"
              unless defined $length && $length > 0;
        }

        my $bit_set = $xsub->($length);
        if (DEBUG) {
            die "Failed to create bit set" unless $bit_set;
        }
        return bless { _handle => $bit_set }, $self;
    }
);

$ffi->attach(
    Bit_free => ['Bit_T_Ptr'] => 'opaque' => sub {
        my ( $xsub, $self ) = @_;
        my $ptr = \$self->{_handle};
        return $xsub->($ptr);
    }
);

$ffi->attach(
    Bit_length => ['Bit_T'] => 'int' => sub {
        my ( $xsub, $self ) = @_;
        return $xsub->( $self->{_handle} );
    }
);

$ffi->attach(
    Bit_count => ['Bit_T'] => 'int' => sub {
        my ( $xsub, $self ) = @_;
        return $xsub->( $self->{_handle} );
    }
);

$ffi->attach( Bit_buffer_size => ['int'] => 'int' );

$ffi->attach(
    Bit_bset => [ 'Bit_T', 'int' ] => 'void' => sub {
        my ( $xsub, $self, $index ) = @_;
        if(DEBUG) {
            die "Index must be non-negative" unless defined $index && $index >= 0;
        }
        $xsub->( $self->{_handle}, $index );
    }
);

$ffi->attach(
    Bit_bclear => [ 'Bit_T', 'int' ] => 'void' => sub {
        my ( $xsub, $self, $index ) = @_;
        if (DEBUG) {
            die "Index must be non-negative" unless defined $index && $index >= 0;
        }
        $xsub->( $self->{_handle}, $index );
    }
);

$ffi->attach(
    Bit_get => [ 'Bit_T', 'int' ] => 'int' => sub {
        my ( $xsub, $self, $index ) = @_;
        if (DEBUG) {
            die "Index must be non-negative" unless defined $index && $index >= 0;
        }
        return $xsub->( $self->{_handle}, $index );
    }
);

$ffi->attach(
    Bit_set => [ 'Bit_T', 'int', 'int' ] => 'void' => sub {
        my ( $xsub, $self, $lo, $hi ) = @_;
        if (DEBUG) {
            die "Low index must be non-negative" unless defined $lo && $lo >= 0;
            die "High index must be greater than or equal to low index"
              unless defined $hi && $hi >= $lo;
        }
        $xsub->( $self->{_handle}, $lo, $hi );
    }
);

$ffi->attach(
    Bit_clear => [ 'Bit_T', 'int', 'int' ] => 'void' => sub {
        my ( $xsub, $self, $lo, $hi ) = @_;
        if (DEBUG) {
            die "Low index must be non-negative" unless defined $lo && $lo >= 0;
            die "High index must be greater than or equal to low index"
              unless defined $hi && $hi >= $lo;
        }
        $xsub->( $self->{_handle}, $lo, $hi );
    }
);

# Comparison operations
$ffi->attach(
    Bit_eq => [ 'Bit_T', 'Bit_T' ] => 'int' => sub {
        my ( $xsub, $self, $other ) = @_;
        if (DEBUG) {
            die "Other bitset must be a Bit::Set object"
              unless ref $other eq ref $self;
        }
        return $xsub->( $self->{_handle}, $other->{_handle} );
    }
);

# Set operations
$ffi->attach(
    Bit_union => [ 'Bit_T', 'Bit_T' ] => 'Bit_T' => sub {
        my ( $xsub, $self, $other ) = @_;
        if (DEBUG) {
            die "Other bitset must be a Bit::Set object"
              unless ref $other eq ref $self;
        }
        my $result_handle = $xsub->( $self->{_handle}, $other->{_handle} );
        return bless { _handle => $result_handle }, ref $self;
    }
);

$ffi->attach(
    Bit_inter => [ 'Bit_T', 'Bit_T' ] => 'Bit_T' => sub {
        my ( $xsub, $self, $other ) = @_;
        if (DEBUG) {
            die "Other bitset must be a Bit::Set object"
              unless ref $other eq ref $self;
        }
        my $result_handle = $xsub->( $self->{_handle}, $other->{_handle} );
        return bless { _handle => $result_handle }, ref $self;
    }
);

# Count operations
$ffi->attach(
    Bit_inter_count => [ 'Bit_T', 'Bit_T' ] => 'int' => sub {
        my ( $xsub, $self, $other ) = @_;
        if (DEBUG) {
            die "Other bitset must be a Bit::Set object"
              unless ref $other eq ref $self;
        }
        return $xsub->( $self->{_handle}, $other->{_handle} );
    }
);

# Constructor and destructor
sub new {
    my ( $class, $length ) = @_;
    return $class->Bit_new($length);
}

sub DESTROY {
    my ($self) = @_;
    $self->Bit_free() if defined $self->{_handle};
}

# Convenient accessor methods
sub length {
    my ($self) = @_;
    return $self->Bit_length();
}

sub count {
    my ($self) = @_;
    return $self->Bit_count();
}

sub get {
    my ( $self, $index ) = @_;
    return $self->Bit_get($index);
}

sub set {
    my ( $self, $index ) = @_;
    $self->Bit_bset($index);
    return $self;
}

sub clear {
    my ( $self, $index ) = @_;
    $self->Bit_bclear($index);
    return $self;
}

sub set_range {
    my ( $self, $lo, $hi ) = @_;
    $self->Bit_set( $lo, $hi );
    return $self;
}

sub clear_range {
    my ( $self, $lo, $hi ) = @_;
    $self->Bit_clear( $lo, $hi );
    return $self;
}

sub equals {
    my ( $self, $other ) = @_;
    return $self->Bit_eq($other) ? 1 : 0;
}

sub union {
    my ( $self, $other ) = @_;
    return $self->Bit_union($other);
}

sub intersection {
    my ( $self, $other ) = @_;
    return $self->Bit_inter($other);
}

sub intersection_count {
    my ( $self, $other ) = @_;
    return $self->Bit_inter_count($other);
}

1;
