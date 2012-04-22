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

}


#update

1;
