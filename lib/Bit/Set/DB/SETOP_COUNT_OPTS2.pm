package Bit::Set::DB::SETOP_COUNT_OPTS2;

use strict;
use warnings;

require XSLoader;
XSLoader::load('Bit::Set::DB::SETOP_COUNT_OPTS2');

1;

__END__

=head1 NAME

Bit::Set::DB::SETOP_COUNT_OPTS2 - Configuration options for set operations

=head1 SYNOPSIS

    use Bit::Set::DB::SETOP_COUNT_OPTS2;

    # Create with default options
    my $opts = Bit::Set::DB::SETOP_COUNT_OPTS2->new();

    # Create with custom options
    my $opts = Bit::Set::DB::SETOP_COUNT_OPTS2->new({
        device_id => 1,
        upd_1st_operand => 1,
        upd_2nd_operand => 0,
        release_1st_operand => 1,
        release_2nd_operand => 1,
        release_counts => 0
    });

    # Or using key-value pairs
    my $opts = Bit::Set::DB::SETOP_COUNT_OPTS2->new(
        device_id => 0,
        upd_1st_operand => 1
    );

=head1 DESCRIPTION

This class provides configuration options for set operations in the Bit::Set::DB2 module.
It controls various aspects of set operation behavior including device selection,
operand update policies, and memory management.

=head1 METHODS

=head2 new([%options])

Creates a new SETOP_COUNT_OPTS2 object. Can be called with no arguments for defaults,
or with a hash reference of options, or with key-value pairs.

=head2 device_id([$value])

Gets or sets the device ID for operations (0 = CPU, 1 = GPU, etc.).

=head2 upd_1st_operand([$value])

Gets or sets whether to update the first operand during operations.

=head2 upd_2nd_operand([$value])

Gets or sets whether to update the second operand during operations.

=head2 release_1st_operand([$value])

Gets or sets whether to release the first operand after operations.

=head2 release_2nd_operand([$value])

Gets or sets whether to release the second operand after operations.

=head2 release_counts([$value])

Gets or sets whether to release count results after operations.

=head1 SEE ALSO

L<Bit::Set::DB2>, L<Bit::Set::DB>, L<Bit::Set>

=head1 AUTHOR

Bit::Set development team

=cut