package Net::OSLC::CM::Ticket;
use Any::Moose;

use Net::OSLC::CM::Connection;
use Net::OSLC::CM::Parser;
use Net::OSLC::CM::ServiceProvider;

has url =>(isa => 'Str', is => 'rw');

has contributor => (isa => 'Str', is => 'rw');
has creator => (isa => 'Str', is => 'rw');
has created => (isa => 'DateTime', is => 'rw');
has changeRequest => (isa => 'Str', is => 'rw');
has description => (isa => 'Str', is => 'rw');
has identifier => (isa => 'Str', is => 'rw');
has modified => (isa => 'DateTime', is => 'rw');
has status => (isa => 'Str', is => 'rw');
has subject => (isa => 'Str', is => 'rw');
has title => (isa => 'Str', is => 'rw');
#has bugz_product => (isa => 'Str', is => 'rw');
#has bugz_component => (isa => 'Str', is => 'rw');

#search and update a ticket
sub load {
  my $self = shift;

  my @properties = $self->meta->get_attribute_list;
  foreach my $property (@properties){
    load_property($property);
  } 

}

sub get_ticket {
  my $self = shift;
  my $connection = shift;

  print $self->url . "\n";

  my $request = HTTP::Request->new(GET => $self->url);

  $request->header('Accept' => 'application/rdf+xml');
  $request->authorization_basic($connection->username, $connection->password);

  my $http_response = $connection->connection->request($request);
  
  if ($http_response->is_success) {
    my $body = $connection->get_http_body($http_response);
    return $body; 
   }
   else {
     print $http_response->status_line . "\n";
     return;
   }
}


#update

1;
