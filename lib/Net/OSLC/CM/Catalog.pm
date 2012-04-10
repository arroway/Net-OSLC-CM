package Net::OSLC::CM::Catalog;

use Any::Moose;

has cm => (
  isa => 'Net::OSLC::CM',
  is => 'rw',
);

has url => (
  isa => 'Str',
  is => 'rw',
);

has providers => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);
 

sub get_catalog {
  my $self = shift;
  my $connection = shift;

  # The service provider should provide a catalog in RDF or HTML.
  # We ask for the XML version. 
  my $http_response = (
    $connection->connection->get(
      $self->url,
      'Accept' => 'application/rdf+xml')
  );

  my $body = $connection->get_http_body($http_response);
  return $body;  
}

sub parse_catalog {
  my $self = shift;
  my $parser = shift;
  my $body = shift;

  my $model = $parser->parse_xml_ressources($self->url, $body);
  return $model;
}


sub query_providers {
  my $self = shift;
  my $parser = shift;
  my $model = shift;

  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  $parser->query_rdf($model, $rdf_query, $self->providers);

  my $i = 0;
  for ( $i=0; $i < @{$self->providers}; $i++){
    if ( ${$self->providers}[$i] =~ m/{ url=<(.*)> }/){
      my $provider = $1;
      #TODO: deal with the general case
      $provider =~ s/localhost/192.168.56.101/;
      ${$self->providers}[$i] = $provider;
    }


  }

}

1;
