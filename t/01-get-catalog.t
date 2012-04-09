#! /usr/bin/env/ perl -Tw

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Net-OSLC.t'

use strict;
use warnings;

use Test::More tests => 16;
use Net::OSLC::CM;
use Net::OSLC::CM::Connection;

BEGIN { use_ok('Net::OSLC::CM') };
BEGIN { use_ok('Net::OSLC::CM::Connection') };

require_ok('LWP::UserAgent');

my $test_url = "http://192.168.56.101:8282/bugz";
my $cm = Net::OSLC::CM->new( url => $test_url );

ok(defined $cm,                                   'Net::OSLC::CM new object is defined');
ok($cm->isa('Net::OSLC::CM'),                     'and is the right class');
ok(defined $cm->url,                              'connection url $cm->url is defined');
is($cm->url, $test_url,                           'registered url \'' . $cm->url . '\' is correct');

ok(defined $cm->connection,                       'Net::OSLC::CM::Connection cm attribute is defined');
ok($cm->connection->isa('Net::OSLC::CM::Connection'),'connection attribute is the right class');

$cm->get_provider_resources;
my $test_url_catalog = $test_url . "/catalog";
ok(defined $cm->catalog,                          'new Catalog object is defined');
ok($cm->catalog->isa('Net::OSLC::CM::Catalog'),   'and is the right class');
is($cm->catalog->url, $test_url_catalog,          'registered catalog url \'' . $cm->catalog->url . '\'is correct');

ok(defined $cm->parser,                           'new Parser object is defined');
ok($cm->parser->isa('Net::OSLC::CM::Parser'),     'and is the right class');

my $body = $cm->catalog->get_catalog($cm->connection);
ok(defined $body,                                 'http request body to GET the catalog is not empty');

my @test_data_catalog = ("http://localhost:8282/bugz/catalog",
  "http://localhost:8282/bugz/provider?productId=1",
  "http://localhost:8282/bugz/provider?productId=2",
  "http://localhost:8282/bugz/provider?productId=3");

is(@{$cm->catalog->data}, @test_data_catalog,         'test data in the catalog is correct');








