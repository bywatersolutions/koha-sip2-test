#!/usr/bin/perl
#
# This file reads a SIPServer xml-format configuration file and dumps it
# to stdout.  Just to see what the structures look like.
#
# The 'new XML::Simple' option must agree exactly with the configuration
# in Sip::Configuration.pm
#
use Modern::Perl;

use Data::Dumper;
use Term::SimpleColor;
use XML::Simple qw(:strict);
use YAML;

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
my $hostname     = $data->{opac_url};
$hostname =~ s/bywatersolutions.com/bywatersolutions.io/;
my $sip_accounts = $data->{sip_accounts};

my @ports =
  map { ref $_ eq 'HASH' ? $_->{port} : $_ }
  ref $data->{sip_port} eq 'ARRAY'
  ? @{ $data->{sip_port} }
  : ( $data->{sip_port} );

my $xml = $parser->XMLin( '<xml>' . $sip_accounts . '</xml>' );

my $logins = $xml->{login};

foreach my $port ( @ports ) {
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
        print cyan "\n" . $sipcommand . "\n";
        my $output = qx/$sipcommand/;
        my $success = index($output, "Login Failed!") == -1;
        if ( $success ) {
            print green $output;
        } else {
            print red $output;
        }

        $sipcommand =
            "/kohaclone/misc/sip_cli_emulator.pl "
          . "--address $hostname "
          . "--port $port "
          . "--sip_user $sip_user "
          . "--sip_pass $sip_pass "
          . "--location $location "
          . "--terminator $terminator "
          . "--message patron_information "
          . "--summary '   Y      ' "
          . "--patron bwssupport ";
        print cyan "\n" . $sipcommand . "\n";
        $output = qx/$sipcommand/;
        $success = index($output, "Login Failed!") == -1;
        if ( $success ) {
            print green $output;
        } else {
            print red $output;
        }
    }
}

print Dumper($xml) if $ENV{DEBUG};
print Dumper( { 'server-params' => $xml->{'server-params'} } ) if $ENV{DEBUG};
print Dumper( { 'xmlns'         => $xml->{'xmlns'} } )         if $ENV{DEBUG};
print Dumper( { 'error-detect'  => $xml->{'error-detect'} } )  if $ENV{DEBUG};
