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

  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  
  $parser->parse_xml_ressources($self->url, $body, $rdf_query, $self->cm->catalog->providers);
  print @{$self->cm->catalog->providers} . "\n";
}

1;
