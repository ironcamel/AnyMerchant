package AnyMerchant::Gateway;
use Moo::Role;

use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(from_json to_json);
use LWP::UserAgent;

requires qw(charge authorize capture credit void);

has login    => (is => 'ro');

has password => (is => 'ro');

has base_url => (is => 'ro');

has retries  => (is => 'ro', default => 0);

has logger   => (is => 'ro');

has ua => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $ua = LWP::UserAgent->new();
        $ua->timeout(10);
        return $ua;
    },
);

sub get {
    my ($self, $path) = @_;
    return $self->_req(GET $path);
}

sub post {
    my ($self, $path, $params) = @_;
    return $self->_req(POST $path, content => to_json $params);
}

sub put {
    my ($self, $path, $params) = @_;
    return $self->_req(PUT $path, content => to_json $params);
}

# Prefix the path param of the http methods with the base_url
around qw(get post put) => sub {
    my $orig = shift;
    my $self = shift;
    my $path = shift;
    die 'Path is missing' unless $path;
    my $url = $self->_url($path);
    return $self->$orig($url, @_);
};

sub _req {
    my ($self, $req) = @_;
    $req->authorization_basic($self->password);
    $req->header(content_type => 'application/json');
    $self->_log_request($req);
    my $res = $self->ua->request($req);
    $self->_log_response($res);
    my $retries = $self->retries;
    while ($res->code =~ /^5/ and $retries--) {
        sleep 1;
        $res = $self->ua->request($req);
        $self->_log_response($res);
    }
    return undef if $res->code =~ /404|410/;
    die $res unless $res->is_success;
    return $res->content ? from_json($res->content) : 1;
}

sub _url {
    my ($self, $path) = @_;
    return $path =~ /^http/ ? $path : $self->base_url . $path;
}

sub _log_request {
    my ($self, $req) = @_;
    return unless $self->logger;
    $self->_log($req->method . ' => ' . $req->uri);
    my $content = $req->content;
    return unless length $content;
    eval { $content = to_json from_json $content };
    $self->_log($content);
}

sub _log_response {
    my ($self, $res) = @_;
    return unless $self->logger;
    $self->_log($res->status_line);
    my $content = $res->content;
    eval { $content = to_json from_json $content };
    $self->_log($content);
}

sub _log {
    my ($self, $msg) = @_;
    return unless $self->logger;
    $self->logger->DEBUG("BP: $msg");
}

1;

__END__

=head1 DESCRIPTION

This role defines the interface for all C<AnyMerchant::Gateway::* classes>.

=head1 METHODS

The param C<$amount> is an integer representing cents.
An amount of 1000 corresponds to $10.00.

The param C<$source> refers to either a credit card or a bank account.
It may be a proper object or a hashref.

=head2 charge

    charge($amount, $source, %params)

Charge a credit card or debit a bank account.

=head2 authorize

    authorize($amount, $source, %params)

Authorize a transaction.

=head2 capture

    capture($amount, $id, %params)

Capture an authorized transaction.

=head2 credit

    credit($amount, $target, %params)

Credit account.

=head2 void

    void($id, %params)

Void a transaction.

=cut
