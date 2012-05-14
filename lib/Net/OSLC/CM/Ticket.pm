package Net::OSLC::CM::Ticket;
use Any::Moose;

use Net::OSLC::CM::Connection;
use Net::OSLC::CM::Parser;
use Net::OSLC::CM::ServiceProvider;
use RDF::Helper;

has model => (isa => 'RDF::Trine::Model', is => 'rw');

has url =>(isa => 'Str', is => 'rw');

has contributor => (isa => 'Str', is => 'rw');
has creator => (isa => 'Str', is => 'rw');
has created => (isa => 'DateTime', is => 'rw');
has changeRequest => (isa => 'Str', is => 'rw');
has description => (isa => 'Str', is => 'rw');
has identifier => (isa => 'Str', is => 'rw');
has modified => (isa => 'DateTime', is => 'rw');
has status => (isa => 'Str', is => 'rw');
has subject => (isa => 'Str', is => 'rw');
has title => (isa => 'Str', is => 'rw');
#has bugz_product => (isa => 'Str', is => 'rw');
#has bugz_component => (isa => 'Str', is => 'rw');

#search and update a ticket
sub load {
  my $self = shift;
  my ($parser) = @_;

  my $rdf = RDF::Helper->new(
    BaseInterface => 'RDF:Trine',
    namespaces => { 
      dcterms => 'http://purl.org/dc/terms/',
      rdf => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      oslc => 'http://open-services.net/ns/core#',
      oslc_cm => 'ttp://open-services.net/ns/cm#',
    } 
 );

  $rdf->model($self->model); 
  my @stmts = $rdf->get_triples();
  
  for(my $i = 0; $i < @stmts; $i++){
    my $subject = $stmts[$i][0];
    my $predicate = $stmts[$i][1];
    my $object = $stmts[$i][2];
    
    print "subject: " . $subject . " - predicate :" . $predicate . " - object: " . $object . "\n";
  }
  #foreach (@stmts){
  #    print "answer  $_ \n";
  #}
 
  #print join("\n",@stmts),"\n";


#  my @properties = $self->meta->get_attribute_list;
#  foreach my $property (@properties){
#    $self->load_property($parser, $property);
#  }
 
  # my $rdf_query = "SELECT ?identifier ?title WHERE 
  #                    {
  #                    ?t dcterms:identifier   ?identifier .
  #                    ?t dcterms:title        ?title .
  #                    
  #                    }"; 
  #my $result = [];
  #$parser->query_rdf($self->model, $rdf_query, $result);

}

sub get_ticket {
  my $self = shift;
  my $connection = shift;

  print $self->url . "\n";

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

sub parse_ticket {
  my $self = shift;
  my ($parser, $body) = @_ ;

  my $model = $parser->parse_xml_ressources($self->url, $body);
  $self->model($model);
  return $self->model;
}

sub load_property {
  my $self = shift;
  my ($parser) = @_;
  my $property = shift;

  my $rdf_query = "SELECT DISTINCT ?x WHERE 
                      {
                      ?t dcterms:identifier ?x .
                      }"; 
  my $result = [];
  $parser->query_rdf($self->model, $rdf_query, $result);
}

#update

1;
