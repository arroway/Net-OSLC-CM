package Net::OSLC::CM;
use Any::Moose;

use Net::OSLC::CM::Catalog;
use Net::OSLC::CM::Connection;
use Net::OSLC::CM::Parser;
use Net::OSLC::CM::ServiceProvider;
use RDF::Trine;
use RDF::Query;
use HTTP::MessageParser;

our $VERSION = '0.01';

has url => (
  isa => 'Str',
  is => 'ro'
);

has connection => (
  isa => 'Net::OSLC::CM::Connection',
  is => 'rw',
  lazy => 1,
  default => sub {
    my $self = shift;
    my $m = Net::OSLC::CM::Connection->new(url => $self->url);
    return $m;
  }
);

has catalog => (
  isa => 'Net::OSLC::CM::Catalog',
  is => 'rw'
);

has parser => (
  isa => 'Net::OSLC::CM::Parser',
  is => 'rw',
);

=head1
OSLC CM service providers must provide a Service Provider Resource, and *MAY* provide a Service Provider Catalog Resource.
Get an OSLC Service Provider Catalog Document from a Service Provider Catalog Resource (via GET method)
An OSLC Service Provider Catalog Document describes a catalog whose entries describe service providers or out-of-line subcatalogs.

=cut

sub get_provider_resources {
  my $self = shift;
  
  $self->create_catalog;
  $self->parser( 
    Net::OSLC::CM::Parser->new(cm => $self) 
  );
  
  $self->get_provider_catalog_resource;
  $self->get_service_providers;
}

sub get_provider_catalog_resource {
  my $self =shift;
  
  my $body_catalog = $self->catalog->get_catalog($self->connection);
  my $model =  $self->catalog->parse_catalog($self->parser, $body_catalog);
  $self->catalog->query_providers($self->parser, $model);
}

sub create_catalog {
  my $self = shift;
  my $catalog_url = "";

  if ($self->url =~ m/\/$/){
    $catalog_url = $self->url . "catalog";
  }
  else {
    $catalog_url =  $self->url . "/catalog";
  }
   
  $self->catalog(
    Net::OSLC::CM::Catalog->new(
      url => $catalog_url,
      cm => $self)
  );
}

sub get_service_providers {
  my $self =shift;

  my $provider = Net::OSLC::CM::ServiceProvider->new(cm => $self);
  my $body_provider = $provider->get_service_provider($self->connection, $self->catalog);
  my $model =  $provider->parse_service_provider($self->parser, $body_provider);
  $provider->query_base($self->parser, $model);

  #we wanna create in sd every ticket that is not present (easiest part) or that is changed 
  #from the distant bugtracker
  #
  #for each entry in $self>catalog-data, 
  #create a new ServiceProvider if necessary
  #deal with it (check if we have the ticket in sd)
  #delete it if we don't want anything
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
