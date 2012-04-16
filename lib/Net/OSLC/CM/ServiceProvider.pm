package Net::OSLC::CM::ServiceProvider;

use Any::Moose;

=head1 NAME

Net::OSLC::CM::ServiceProvider

=head1 DESCRIPTION

=cut

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
  default => sub { [] },
);

has queryBase => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);

has resourceShape => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);

has creationFactory => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);

=head2 get_service_provider connection

Performs a GET HTTP request to get xml data for a given Service Provider.

=cut

sub get_service_provider {
  my $self = shift;
  my $connection = shift;
  
  print "\n" . $self->url . "\n";

  my $http_response = (
    $connection->connection->get(
    $self->url,
    'Accept' => 'application/rdf+xml') 
  );

  my $body = $connection->get_http_body($http_response);
  return $body;
}

=head2 parse_service_provider parser rdf_data

Parses xml data that we got from HTTP request for a given Service Provider.
Parsing the data into a RDF model, we'll retrieve the information we need to perform queries
and change requests. 

=cut

sub parse_service_provider {
  my $self = shift;
  my ($parser, $body) = @_;
  
  my $model = $parser->parse_xml_ressources($self->url, $body);
  
}

=head2 query_resource

Performs a query in an OSLC service to find properties such as
queryCapability or resourceShape. 

=cut 

sub query_resource {
  my $self = shift;
  my ($parser, $model, $resource, $property, $result) = @_;

  my $rdf_query = "SELECT ?y WHERE
                    {
                    ?z oslc:" . $resource . " ?x .
                    ?x oslc:" . $property . " ?y .
                    }";
                    
  $parser->query_rdf($model, $rdf_query, $result);
  
  my $i = 0;
  for ( $i=0; $i < @{$result}; $i++){
    if ( ${$result}[$i] =~ m/{ y=<(.*)> }/){
      my $res = $1;
      #TODO: deal with the general case
      $res =~ s/localhost/192.168.56.101/;
      ${$result}[$i] = $res;
      print ${$result}[$i] . "\n";
    }
  }
}

=head2

Once we found the resources, we can request the RDF data.
=cut

sub discover_oslc_resources {
  my $self = shift;
  my $connection = shift;

  #by default, if nothing is specified but the queryBase, the service provides all the properties
  my $queryBase = ${$self->queryBase}[1];

  my $http_response = (
    $connection->connection->get(
    "http://192.168.56.101:8282/bugz/creationshape?productId=1",
    'Accept' => 'application/rdf+xml') 
  );

  my $body = $connection->get_http_body($http_response);
  return $body;
}


1;
