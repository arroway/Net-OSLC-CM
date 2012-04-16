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
  my @providers = $self->get_service_providers;
  
  my @tickets = $self->get_tickets;
  return @tickets;
}

#then do your search
sub get_tickets {
   
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

For a given Catalog, gets Service Providers resources and properties: 
queryCapability, resourceShape and creationFactory.

Returns a list of Service Providers objects.
=cut

=head3 Query Capability

Enables clients to query across a collection of resources via HTTP GET or POST.
To perform an HTTP GET query, an OSLC client starts with the base URI 
as defined by the oslc:queryBase property of a Query Capability, and 
appends to it query parameters in a syntax supported by the service.

=cut

=head3 Resource Shape

In some cases, to create resources and to query those that already exist
within an OSLC Service, OSLC clients needs a way to learn which properties
are commonly used in or required by the service. Resource Shape Resources 
meet this need by providing a machine-readable definition of an OSLC resource 
type. 
A Resource Shape describes the properties that are allowed or required by 
one type of resource. Resource Shapes are intended to provide simple "hints" 
to clients at resource creation, update or query time.

=cut

=head3 Creation Factory

Enables clients to create new resources via HTTP POST.

=cut


sub get_service_providers {
  my $self =shift;
  my @providers= [];

  my $i = 0;
  for( $i=0; $i < @{$self->catalog->providers_url}; $i++){

    my $url = ${$self->catalog->providers_url}[$i];
    if (defined($url)){
      my $provider = Net::OSLC::CM::ServiceProvider->new(
                      cm => $self,
                      url => $url);
      
      $self->_get_service_provider($provider);
      push(@providers, $provider);                         
    }
  }
  return @providers;
}

sub _get_service_provider {
  
  my $self = shift;
  my $provider = shift;

  my $body_provider = $provider->get_service_provider($self->connection, $self->catalog);
  my $model =  $provider->parse_service_provider($self->parser, $body_provider);

  $provider->query_resource($self->parser, $model, 
                              "queryCapability", 
                              "queryBase", 
                              $provider->queryBase);
  
  $provider->query_resource($self->parser, $model, 
                              "queryCapability", 
                              "resourceShape", 
                              $provider->resourceShape);
 
  $provider->query_resource($self->parser, $model, 
                              "creationFactory", 
                               "resourceShape", 
                               $provider->creationFactory);

}

1;

__END__
