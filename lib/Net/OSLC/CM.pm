package Net::OSLC::CM;
use Any::Moose;

use Net::OSLC::CM::Catalog;
use Net::OSLC::CM::Connection;
use Net::OSLC::CM::Parser;
use Net::OSLC::CM::ServiceProvider;
use RDF::Trine;
use RDF::Query;
use HTTP::MessageParser;

our $VERSION = '0.01';

=head1 NAME

Net::OSLC::CM - module to help implement a OSLC client for Change Management

=cut

has url => (
  isa => 'Str',
  is => 'ro'
);

has connection => (
  isa => 'Net::OSLC::CM::Connection',
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $m = Net::OSLC::CM::Connection->new(url => $self->url);
    return $m;
  }
);

has catalog => (
  isa => 'Net::OSLC::CM::Catalog',
  is => 'rw'
);

has parser => (
  isa => 'Net::OSLC::CM::Parser',
  is => 'rw',
);

=head2 get_oslc_resources

OSLC CM service providers must provide a Service Provider Resource, 
and *MAY* provide a Service Provider Catalog Resource.
Gets an OSLC Service Provider Catalog Document from a Service Provider 
Catalog Resource (via GET method) and Service Providers resources.
An OSLC Service Provider Catalog Document describes a catalog whose entries describe service providers or out-of-line subcatalogs.

=cut

sub get_oslc_resources {
  my $self = shift;
  
  $self->create_catalog;
  $self->parser( 
    Net::OSLC::CM::Parser->new(cm => $self) 
  );
  
  $self->get_provider_catalog_resource;
  $self->get_service_providers;
}

=head2 get_provider_catalog_resource

Gets if it exists the Service Provider Catalog and performs a query to get the referenced Service Providers .

=cut
 
sub get_provider_catalog_resource {
  my $self =shift;
  
  my $body_catalog = $self->catalog->get_catalog($self->connection);
  my $model =  $self->catalog->parse_catalog($self->parser, $body_catalog);
  $self->catalog->query_providers($self->parser, $model);
}

=head2 create_catalog

Creates an instance of the Net::OSLC::CM:Catalog class.

=cut

sub create_catalog {
  my $self = shift;
  my $catalog_url = "";

  if ($self->url =~ m/\/$/){
    $catalog_url = $self->url . "catalog";
  }
  else {
    $catalog_url =  $self->url . "/catalog";
  }
   
  $self->catalog(
    Net::OSLC::CM::Catalog->new(
      url => $catalog_url,
      cm => $self)
  );
}

=head2 get_service_providers

Gets Service Providers information.

=cut

sub get_service_providers {
  my $self =shift;

  my $provider = Net::OSLC::CM::ServiceProvider->new(cm => $self);
  my $body_provider = $provider->get_service_provider($self->connection, $self->catalog);
  my $model =  $provider->parse_service_provider($self->parser, $body_provider);
  $provider->query_base($self->parser, $model);

  #we wanna create in sd every ticket that is not present (easiest part) or that is changed 
  #from the distant bugtracker
  #
  #for each entry in $self>catalog-data, 
  #create a new ServiceProvider if necessary
  #deal with it (check if we have the ticket in sd)
  #delete it if we don't want anything
}


1;

__END__
