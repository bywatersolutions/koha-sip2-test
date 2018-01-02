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

my $ref = $parser->XMLin( @ARGV ? shift : 'SIPconfig.xml' );

my $hostname = $ARGV[0];

$hostname //= 'XXXX';

for my $listener ( keys( %{ $ref->{listeners} } ) ) {
    my ( $port, $network_protocol ) =
      split( '/', $ref->{listeners}->{$listener}->{port} );
    my $timeout = $ref->{listeners}->{$listener}->{timeout};

    print("\nlistener: $listener\n") if $ENV{DEBUG};
    print("port: $port\n")           if $ENV{DEBUG};
    print("timeout: $timeout\n")     if $ENV{DEBUG};

    for my $account ( keys( %{ $ref->{accounts} } ) ) {
        my $sipcommand =
            "/kohaclone/misc/sip_cli_emulator.pl "
          . "--address $hostname "
          . "--port $port "
          . "--sip_user $ref->{accounts}->{$account}->{id} "
          . "--sip_pass $ref->{accounts}->{$account}->{password} "
          . "--location $ref->{accounts}->{$account}->{institution} "
          . "--terminator $ref->{accounts}->{$account}->{terminator} ";
        print "\n" . $sipcommand . "\n";
        system $sipcommand;
    }
}

print Dumper($ref) if $ENV{DEBUG};
print Dumper( { 'server-params' => $ref->{'server-params'} } ) if $ENV{DEBUG};
print Dumper( { 'xmlns'         => $ref->{'xmlns'} } )         if $ENV{DEBUG};
print Dumper( { 'error-detect'  => $ref->{'error-detect'} } )  if $ENV{DEBUG};
