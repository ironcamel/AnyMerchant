package AnyMerchant;
use strict;
use warnings;

# VERSION

use Carp qw(croak);
use Scalar::Util qw(blessed);

sub gateway {
    my ($class, $gateway, %args) = @_;
    croak 'gateway is required' unless $gateway;
    my $gw_class = "AnyMerchant::Gateway::$gateway";
    eval "require $gw_class";
    my $gw = $gw_class->new(%args);
    my $required_role = 'AnyMerchant::Gateway';
    croak "gateway must implement the role $required_role"
        unless blessed $gw and $gw->can('does') and $gw->does($required_role);
    return $gw;
}

# ABSTRACT: A generic and consistent interface for online payment services

=head1 SYNOPSIS

    my $gateway = AnyMerchant->gateway('Balanced', password => 'abc123');

=head1 DESCRIPTION

AnyMerchant is a generic and consistent interface for online payment services.
It is an alternative to L<Business::OnlinePayment>.
The interface for AnyMerchant is based on ruby's
L<Active Merchant|https://github.com/Shopify/active_merchant>.
See L<AnyMerchant::Gateway> for a description of the interface that gateways
should implement.

=head1 METHODS

=head2 gateway

    my $gateway = AnyMerchant->gateway('Balanced', password => 'abc123');

This is a static factory method that creates an AnyMerchant::Gateway::* object,
validates its interface, and returns it.
In the above example, an AnyMerchant::Gateway::Balanced object is returned.

=cut

1;
