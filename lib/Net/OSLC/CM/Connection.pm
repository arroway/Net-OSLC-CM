package Net::OSLC::CM::Connection;
use Any::Moose;

use LWP::UserAgent;
use HTTP::MessageParser;


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


sub get_http_body {
  my $self = shift;
  my $http_response = shift;

  # parse_response() returns body as a string reference
  my ( $HTTP_version, $status_Code, $reason_phrase, $headers, $body )
          = HTTP::MessageParser->parse_response($http_response->as_string());

  return $$body;
 
}

1;
