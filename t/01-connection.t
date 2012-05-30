#! /usr/bin/env/ perl -Tw

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Net-OSLC.t'

use strict;
use warnings;

use Test::More tests => 14;
use Net::OSLC::CM::Connection;
use File::Temp qw/tempdir/;

BEGIN { use_ok('Net::OSLC::CM::Connection') };

require_ok('LWP::UserAgent');
require_ok('HTTP::MessageParser');
require_ok('HTTP::Response');

my $test_url = "http://192.168.56.101:8282/bugz";
my $username = 'stephanie@minet.net';
my $password = "password";

my $connection = Net::OSLC::CM::Connection->new( 
  url => $test_url,
  username => $username,
  password => $password 
);

#Checks the new created CM object is correct
ok(defined $connection,                   'Net::OSLC::CM::Connection cm attribute is defined');
ok($connection->isa('Net::OSLC::CM::Connection'),'connection is the right class');

#Checks the Connection attribute
ok(defined $connection->url,                  'connection url $connection->url is defined');
is($connection->url, $test_url,               'registered url \'' . $connection->url . '\' is correct');
ok(defined $connection->username,             'username $connection->username is defined');
is($connection->username, $username,          'registered username \'' . $connection->username . '\' is correct');
ok(defined $connection->password,             'password $connection->password is defined');
is($connection->password, $password,          'registered password \'' . $connection->password . '\' is correct');

#Gets local data to test functions
local $/=undef;
open CATALOG, "data/catalog.html" or die "Couldn't open file: $!";
my $catalog = <CATALOG>;
close CATALOG;
my $http_response = HTTP::Response->parse($catalog);

#Parsing the HTTP response to get the body (that should be XML/RDF data)
my $body = $connection->get_http_body($http_response);
ok(defined $body,                               'HTTP body of the request is defined');
my $is_xml = 0;
if ($body =~ m/^<\?xml version="1\.0"(.*)/){
  $is_xml = 1;
}
is($is_xml, 1,                                  'we get XML data version 1.0');

