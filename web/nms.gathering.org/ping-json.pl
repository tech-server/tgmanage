#! /usr/bin/perl
use CGI;
use DBI;
use JSON::XS;
use lib '../../include';
use nms;
my $cgi = CGI->new;

my $dbh = nms::db_connect();

my $q = $dbh->prepare("SELECT DISTINCT ON (switch) switch, latency_ms FROM ping WHERE updated >= NOW() - INTERVAL '15 secs' ORDER BY switch, updated DESC;");
$q->execute();

my %json = ();
while (my $ref = $q->fetchrow_hashref()) {
	$json{'switches'}{$ref->{'switch'}} = $ref->{'latency_ms'};
}

my $lq = $dbh->prepare("SELECT DISTINCT ON (linknet) linknet, latency1_ms, latency2_ms FROM linknet_ping WHERE updated >= NOW() - INTERVAL '15 secs' ORDER BY linknet, updated DESC;");
$lq->execute();
while (my $ref = $lq->fetchrow_hashref()) {
	$json{'linknets'}{$ref->{'linknet'}} = [ $ref->{'latency1_ms'}, $ref->{'latency2_ms'} ];
}

$q->execute();
print $cgi->header(-type=>'text/json; charset=utf-8');
print JSON::XS::encode_json(\%json);
