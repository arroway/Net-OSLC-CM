package Net::OSLC::CM::ServiceProvider;

use Any::Moose;

has uri => (
  isa => 'Str',
  is => 'rw',
);  

sub get_service_provider {
  my $self = shift;
  my $connection = shift;
  my $catalog = shift;

  $self->uri(${$catalog->data}[2]);
  
  my $http_response = (
      $connection->connection->get(
       $self->uri,
      'Accept' => 'application/rdf+xml') 
  );

  print $http_response;
  my $body = $connection->get_http_body($http_response);
  return $body;
}

sub parse_service_provider {
  my $self = shift;
  my ($parser, $body) = @_;

  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  print $body;

  $parser->parse_xml_ressources($self->uri, $body, $rdf_query);
}

1;
