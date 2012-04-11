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
  default => sub {[]},
);

has queryBase => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);

sub get_service_provider {
  my $self = shift;
  my $connection = shift;

  $self->url(${$self->cm->catalog->providers}[2]);
  print "\n" . $self->url . "\n";

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
  
  my $model = $parser->parse_xml_ressources($self->url, $body);
  
}

sub query_base {
  my $self = shift;
  my ($parser, $model) = @_;

  my $rdf_query = "SELECT ?y WHERE  
                    {
                    ?z oslc:queryCapability ?x .
                    ?x oslc:queryBase ?y .
                    }";
  $parser->query_rdf($model, $rdf_query, $self->queryBase);

  if ( ${$self->queryBase}[0] =~ m/{ y=<(.*)> }/){
    my $queryBase = $1;
    #TODO: deal with the general case
    $queryBase =~ s/localhost/192.168.56.101/;
    ${$self->queryBase}[0] = $queryBase;
    }
  print ${$self->queryBase}[0];
}

1;
