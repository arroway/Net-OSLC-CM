package Net::OSLC::CM;
use Any::Moose;

use Net::OSLC::CM::Connection;
use RDF::Trine;
use RDF::Query;
use HTTP::MessageParser;

our $VERSION = '0.01';

has url => (
  isa => 'Str',
  is => 'ro'
);

has connection => (
  isa => 'LWP::UserAgent',
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $m = Net::OSLC::CM::Connection->new(url => $self->url);
    return $m->connection;
  }
);

has catalog => (
  isa => 'ArrayRef',
  is => 'rw',
  default => sub { [] },
);

=head1
OSLC CM service providers must provide a Service Provider Resource, and *MAY* provide a Service Provider Catalog Resource.
Get an OSLC Service Provider Catalog Document from a Service Provider Catalog Resource (via GET method)
An OSLC Service Provider Catalog Document describes a catalog whose entries describe service providers or out-of-line subcatalogs.

=cut

sub parse_provider_resource {
  my $self = shift;
  
  $self->get_provider_catalog_resource;
  
  #testing parsing a SPC Document which URI we know
  #$self->get_provider_catalog_document( $self->url . "/provider?productId=1");
}

sub get_provider_catalog_resource {
  my $self =shift;
  my $catalog_url = $self->url . "/catalog";
  
  # The service provider should provide a catalog in RDF or HTML.
  # We ask for the XML version. 
  my $http_response = (
    $self->connection->get(
      $catalog_url, 
      'Accept' => 'application/rdf+xml')
  );

  my $body = $self->get_http_body($http_response);
  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  $self->parse_xml_ressources($catalog_url, $body, $rdf_query);  
}

sub get_provider_catalog_document {
  my $self = shift;
  my $document_url = shift;

  my $http_response = ($self->connection->request(GET $document_url));
  my $body = $self->get_http_body($http_response);
  my $rdf_query = "SELECT DISTINCT ?url WHERE  { ?url dcterms:title ?u }";
  $self->parse_xml_ressources($document_url, $body, $rdf_query);
}


sub get_http_body {
  my $self = shift;
  my $http_response = shift;

  # parse_response() returns body as a string reference
  my ( $HTTP_version, $status_Code, $reason_phrase, $headers, $body )
          = HTTP::MessageParser->parse_response($http_response->as_string());

  return $$body;
 
}

sub parse_xml_ressources {
  my $self = shift;
  my ($base_uri, $rdf_data, $rdf_query) = @_;

  # we only want rdf data from the body of the HTTP response
  $rdf_data =~ m/(<rdf.*RDF>)/;
  #print $rdf_data;

  my $store = RDF::Trine::Store::Memory->new();
  my $parser = RDF::Trine::Parser->new('rdfxml');
  my $model = RDF::Trine::Model->new($store);

  $parser->parse_into_model( $base_uri, $rdf_data, $model );
  $self->query_rdf($model, $rdf_query);
} 

sub query_rdf {
  my $self = shift;
  my ($model, $rdf_query) = @_;

  my $query = RDF::Query->new('
    PREFIX oslc:    <http://open-services.net/ns/core#>
    PREFIX dcterms: <http://purl.org/dc/terms/>
    PREFIX rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>'
    . $rdf_query);
  
   my $iterator = $query->execute( $model );
   while (my $row = $iterator->next) {
     if ($row =~ m/{ url=<(.*)> }/){
       push(@{$self->catalog}, $1);
     }
   }
   print @{$self->catalog};
   
}

1;

__END__

=head1 NAME

Net::OSLC::CM - Interact with an OSLC Service Provider Catalog, respecting specifications of OSLC Change Management v.2

=head1 SYNOPSIS


=head1 DESCRIPTION


=head2 EXPORT

=head1 SEE ALSO

=head1 AUTHOR

Stephanie Ouillon, E<lt>stephanie.ouillon@telecom-sudparis.eu<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Stephanie Ouillon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
