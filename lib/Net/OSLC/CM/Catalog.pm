package Net::OSLC::CM::Catalog;

use Any::Moose;

=head1 NAME

Net::OSLC::CM::Catalog - Service Provider Catalog Ressource

=head1 DESCRIPTION

The Catalog enables OSLC clients to find Service Providers offered. 
These catalogs may contain other nested catalogs as well as 
service providers.

=head1 TODO
This current implementation assumes such a Catalog exists, and that it 
references Service Providers only (not other catalogs).

=cut

has cm => (
  isa => 'Net::OSLC::CM',
  is => 'rw',
);

has url => (
  isa => 'Str',
  is => 'rw',
);

has providers_url => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);
 

=head2 get_catalog connection

Perfoms a GET HTTP request to get xml data from the Service Provider Catalog
of an OSLC service.
At the moment, I assume that document actually exists (according to OSLC-CM
specifications, this may not be always the case)

=cut

sub get_catalog {
  my $self = shift;
  my $connection = shift;

  # The service provider should provide a catalog in RDF or HTML.
  # We ask for the XML version. 

  my $request = HTTP::Request->new(GET => $self->url);

  $request->header('Accept' => 'application/rdf+xml');
  $request->authorization_basic($connection->username, $connection->password);

  my $http_response = $connection->connection->request($request);
  
  if ($http_response->is_success) {
    my $body = $connection->get_http_body($http_response);
    return $body;
  }
  else {
    print $http_response->status_line . "\n";
    return;
  }
}
=head2 parse_catalog parser xml_data

Parses xml data that we got when we request the Service Provider
Catalog ressource.
Parsing the data into a RDF model, we'll retrieve the URIs of every Service
Provider that is referenced. 

=cut

sub parse_catalog {
  my $self = shift;
  my $parser = shift;
  my $body = shift;

  my $model = $parser->parse_xml_ressources($self->url, $body);
  return $model;
}

=head2 query_providers parser rdf_model

Performs a SPARQL query to get the URIs of every Service Provider that 
is referenced in the Service Providers Catalog.
We store the result in $self->providers. 

=cut

sub query_providers {
  my $self = shift;
  my $parser = shift;
  my $model = shift;
  my $arrayref = [];

  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  $parser->query_rdf($model, $rdf_query, $arrayref);

  my $i = 0;
  for ( $i=0; $i < @{$arrayref}; $i++){
    if ( ${$arrayref}[$i] =~ m/{ url=<(.*)> }/){
      my $provider = $1;
      if ($provider =~ m/http:\/\/(.*)/ and $provider !~ m/$self->url/){
        #TODO: deal with the general case
        #$provider =~ s/localhost/192.168.56.101/;
        push($self->providers_url,$provider);
      }
    }


  }

}

1;
