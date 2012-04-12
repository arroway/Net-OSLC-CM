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
  default => sub {[]},
);

has queryBase => (
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


=head2 query_base

To perform an HTTP GET query, an OSLC client starts with the base URI 
as defined by the oslc:queryBase property of a Query Capability, and 
appends to it query parameters in a syntax supported by the service.

=cut

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
