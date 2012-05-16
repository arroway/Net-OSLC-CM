package Net::OSLC::CM::Util;

use DateTime;

=head2 XSDToDateTime datetime
Converts a date/time at the XSD format (XML date format) into a DateTime format.
Returns a DateTime object.
=cut

sub XSDToDateTime {
  my $self = shift;
  my $XSDTime = shift;
  my $dt = undef;

  my ($y, $m, $d, $h, $mi, $s) = ($XSDTime =~ 
    m/^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})Z/) ;

  my ($other, $z, $zh, $zm) = ($XSDTime =~ m/(.*)Z([+|-]{1})([0-9]{2}):([0-9]{2})/);

  if(!defined($z) and !defined($zh) and !defined($zm)){
    $z = "+";
    $zh = "00";
    $zm = "00";
  }
  
  #print "test: " . $y . " " . $m  . " " . $d . " " . $h . " " . $mi . " " . $s . " " . $z . " " . $zh . " " . $zm . "\n";  

  if (defined($y) and defined($m) and defined($d) and 
      defined($h) and defined($mi) and defined($s) and 
      defined($z) and defined($zh) and defined($zm)){

     $dt = DateTime->new(
       year => $y,
       month => $m, 
       day => $d, 
       hour => $h, 
       minute => $mi,
       second => $s,
       time_zone => $z . $zh . $zm
     );

  } else {
    print "Error at parsing XSD Time data\n";
  }
  return $dt;
}

1;
