package Net::OSLC::CM::Connection;
use Any::Moose;

use LWP::UserAgent;

=head1 
Connection to a server with the given url.
Will probably deal with authentication later on.
=cut

has url => (
  isa => 'Str',
  is  => 'ro'
);

has connection => (
  isa => 'LWP::UserAgent', 
  is => 'rw',
  lazy =>1,
  default => sub {
    my $self = shift;
    my $connection = LWP::UserAgent->new();
    return $connection;
  }
);

1;
