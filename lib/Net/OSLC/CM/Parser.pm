package Net::OSLC::CM::Parser;

use Any::Moose;
use RDF::Trine;
use RDF::Query;

=head1 NAME

Net::OSLC::CM::Parser - RDF Parser

=head1 DESCRIPTION

Utility for parsing xml ressources into a RDF model and 
performing SPARQL queries in a given model.

=cut

has cm => (
  isa => 'Net::OSLC::CM',
  is => 'rw'
);

=head2 parse_xml_ressources base_uri rdfxml_data

The argument rdfxml data is the body of the performed GET HTTP request.
Through the regex, we retrive only the XML data we're interested in, 
and we parse it intod a RDF model located in memory.

=cut

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

=head2 query_rdf model rdf_query result_storage

Executes a given SPARQL query and store the result in the given argument.

=cut

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
