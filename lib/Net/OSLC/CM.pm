package Net::OSLC::CM;
use Any::Moose;

use Net::OSLC::CM::Connection;
use RDF::Trine;
use HTTP::Request::Common;
use HTTP::Request;
use HTTP::Response::Parser;


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
  isa => 'Str',
  is => 'rw'
);

=head1
OSLC CM service providers must provide a Service Provider Resource, and *MAY* provide a Service Provider Catalog Resource.
Get an OSLC Service Provider Catalog Document from a Service Provider Catalog Resource (via GET method)
An OSLC Service Provider Catalog Document describes a catalog whose entries describe service providers or out-of-line subcatalogs.

This document is RDF/XML.
=cut

sub parse_provider_resource {
  my $self = shift;
  #$self->get_provider_catalog_resource;

  #testing parsing a SPC Document which URI we know
  $self->get_provider_catalog_document( $self->url . "/provider?productId=1");
}


#XXX:if not xml?
sub get_provider_catalog_resource {
  my $self =shift;
  my $catalog_url = $self->url . "/catalog";
  
  my $http_response = ($self->connection->request(GET $catalog_url));
  $self->catalog($self->get_http_message($http_response));
  $self->parse_ressources($catalog_url, $self->catalog);
  
}

sub get_provider_catalog_document {
  my $self = shift;
  my $document_url = shift;

  my $http_response = ($self->connection->request(GET $document_url));
  my $document = $self->get_http_message($http_response);
  $self->parse_ressources($document);
}

sub get_http_message {
  my $self = shift;
  my $http_response = shift;

  print $http_response->as_string();
  my $res = HTTP::Response::Parser->parse_http_response($http_response->as_string());

  if($res == -1){
    print 'Parsing HTTP message - Response is incomplete';
  } elsif ($res == -2){
    print 'Parsing HTTP message - response is broken';
  } else { 
    return $res->{_msg};
  }  
}

sub parse_ressources {
  my $self = shift;
  my ($base_uri, $document) = shift;
 
  my $parser = RDF::Trine::Parser->new('rdfxml');
  my $model = RDF::Trine::Model->temporary_model;
  $parser->parse_into_model( $base_uri, $document, $model );
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
