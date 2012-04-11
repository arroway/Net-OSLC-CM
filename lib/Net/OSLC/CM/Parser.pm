package Net::OSLC::CM::Parser;

use Any::Moose;
use RDF::Trine;
use RDF::Query;

has cm => (
  isa => 'Net::OSLC::CM',
  is => 'rw'
);

sub parse_xml_ressources {
  my $self = shift;
  my ($base_uri, $rdf_data) = @_;

  # we only want rdf data from the body of the HTTP response
  $rdf_data =~ m/(<rdf.*RDF>)/;
  #print $rdf_data;

  my $store = RDF::Trine::Store::Memory->new();
  my $parser = RDF::Trine::Parser->new('rdfxml');
  my $model = RDF::Trine::Model->new($store);

  $parser->parse_into_model( $base_uri, $rdf_data, $model );
  return $model;
} 

sub query_rdf {
  my $self = shift;
  my ($model, $rdf_query, $result_storage) = @_;

  my $query = RDF::Query->new('
    PREFIX oslc:    <http://open-services.net/ns/core#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>'
    . $rdf_query);

  my $iterator = $query->execute( $model );
  while (my $row = $iterator->next) {
     print $row;
     push(@{$result_storage}, $row);
  }
}

1;
