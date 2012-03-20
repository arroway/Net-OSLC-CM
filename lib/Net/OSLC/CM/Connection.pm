package Net::OSLC::CM::Connection;
use Any::Moose;

use URI;
use LWP::UserAgent;

has uri => (
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
