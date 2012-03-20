package Net::OSLC::CM;
use Any::Moose;

use Net::OSLC::CM::Connection;
use RDF::Trine::Parser::RDFXML;
use HTTP::Request::Common;
use HTTP::Request;

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
  isa => 'HTTP::Response',
  is => 'rw'
);

=head1
OSLC CM service providers must provide a Service Provider Resource, amd may provide a Service Provider Catalog Resource.
Get an OSLC Service Provider Catalog Document from a Service Provider Catalog Resource (via GET method)
An OSLC Service Provider Catalog Document describes a catalog whose entries describe service providers or out-of-line subcatalogs.

This document is RDF/XML.
=cut

sub parse_provider_resource{
  my $self = shift;
  $self->get_provider_catalog;
}

sub get_provider_catalog{
  my $self =shift;
  my $catalog_url = $self->url . "/catalog";
  $self->catalog(
    $self->connection->request(GET $catalog_url)
  );
}


1;
__END__

=head1 NAME

Net::OSLC::CM - Interact with an OSLC Service Provider Catalog, respecting specifications of OSLC Change Management v.2

=head1 SYNOPSIS

  use Net::OSLC::CM;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Net::OSLC, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Stephanie Ouillon, E<lt>stephanie.ouillon@telecom-sudparis.eu<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Stephanie Ouillon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
