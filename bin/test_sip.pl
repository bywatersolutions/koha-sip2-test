#!/usr/bin/perl
#
# This file reads a SIPServer xml-format configuration file and dumps it
# to stdout.  Just to see what the structures look like.
#
# The 'new XML::Simple' option must agree exactly with the configuration
# in Sip::Configuration.pm
#
use Modern::Perl;
use English;

use XML::Simple qw(:strict);
use YAML;
use Data::Dumper;

my $parser = new XML::Simple(
    KeyAttr => {
        login       => '+id',
        institution => '+id',
        service     => '+port',
    },
    GroupTags => {
        listeners    => 'service',
        accounts     => 'login',
        institutions => 'institution',
    },
    ForceArray => [ 'service', 'login', 'institution' ],
    ValueAttr  => {
        'error-detect' => 'enabled',
        'min_servers'  => 'value',
        'max_servers'  => 'value'
    }
);

my $file = shift or die "Usage $0 FILENAME\n";
my $data = YAML::LoadFile($file);

my $description  = $data->{description};
my $hostname     = $data->{staff_url};
my $port         = $data->{port};
my $sip_accounts = $data->{sip_accounts};

my $xml = $parser->XMLin( '<xml>' . $sip_accounts . '</xml>' );

my $logins = $xml->{login};

for my $key ( keys %{$logins} ) {
    my $sip_user   = $logins->{$key}->{id};
    my $sip_pass   = $logins->{$key}->{password};
    my $location   = $logins->{$key}->{institution};
    my $terminator = $logins->{$key}->{terminator};

    my $sipcommand =
        "/kohaclone/misc/sip_cli_emulator.pl "
      . "--address $hostname "
      . "--port $port "
      . "--sip_user $sip_user "
      . "--sip_pass $sip_pass "
      . "--location $location "
      . "--terminator $terminator ";
    print "\n" . $sipcommand . "\n";
    system $sipcommand;
}

print Dumper($xml) if $ENV{DEBUG};
print Dumper( { 'server-params' => $xml->{'server-params'} } ) if $ENV{DEBUG};
print Dumper( { 'xmlns'         => $xml->{'xmlns'} } )         if $ENV{DEBUG};
print Dumper( { 'error-detect'  => $xml->{'error-detect'} } )  if $ENV{DEBUG};
