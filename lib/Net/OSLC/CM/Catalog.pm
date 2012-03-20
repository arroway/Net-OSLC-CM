package Net::OSLC::CM::Catalog.pm

use Any::Moose;
use RDF::Trine::Parser::RDFXML;
use HTTP::Request::Common;

==head1
OSLC CM service providers must provide a Service Provider Resource, amd may provide a Service Provider Catalog Resource.
Get an OSLC Service Provider Catalog Document from a Service Provider Catalog Resource (via GET method)
An OSLC Service Provider Catalog Document describes a catalog whose entries describe service providers or out-of-line subcatalogs.

This document is RDF/XML.
==cut



sub parse{
  my $self = shift;
   

}
