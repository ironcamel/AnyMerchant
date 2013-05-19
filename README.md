# SYNOPSIS

    my $gateway = AnyMerchant->gateway('Balanced', password => 'abc123');

# DESCRIPTION

AnyMerchant is a generic and consistent interface for online payment services.
It is an alternative to [Business::OnlinePayment](http://search.cpan.org/perldoc?Business::OnlinePayment).
The interface for AnyMerchant is based on ruby's
[Active Merchant](https://github.com/Shopify/active\_merchant).
See [AnyMerchant::Gateway](http://search.cpan.org/perldoc?AnyMerchant::Gateway) for a description of the interface that gateways
should implement.

# METHODS

## gateway

    my $gateway = AnyMerchant->gateway('Balanced', password => 'abc123');

This is a static factory method that creates an AnyMerchant::Gateway::\* object,
validates its interface, and returns it.
In the above example, an AnyMerchant::Gateway::Balanced object is returned.
