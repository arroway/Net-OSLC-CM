package Net::OSLC::CM::ServiceProvider;

use Any::Moose;

has cm => (
  isa => 'Net::OSLC::CM',
  is => 'rw',
);

has url => (
  isa => 'Str',
  is => 'rw',
);  

has services => (
  isa => 'ArrayRef',
  is => 'rw',
);

sub get_service_provider {
  my $self = shift;
  my $connection = shift;

  $self->url(${$self->cm->catalog->providers}[1]);
  
  my $http_response = (
    $connection->connection->get(
    $self->url,
    'Accept' => 'application/rdf+xml') 
  );

  my $body = $connection->get_http_body($http_response);
  return $body;
}

sub parse_service_provider {
  my $self = shift;
  my ($parser, $body) = @_;

  print $body;
  my $model = $parser->parse_xml_ressources($self->url, $body);
  
  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  $parser->query_rdf($model, $rdf_query, $self->services);  
}

1;
