package AnyMerchant::Gateway;
use Moo::Role;

requires qw(authorize capture charge refund void);

=head1 DESCRIPTION

This role defines the interface for all C<AnyMerchant::Gateway::* classes>.

=head1 METHODS

=head2 authorize

Authorize a transaction.

=head2 capture

Capture an authorized transaction.

=head2 debit

Debit a credit card or bank account.

=head2 refund

Refund a transaction.

=head2 void

Void a transaction.

=cut

1;
