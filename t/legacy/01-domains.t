#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use String::Random qw( random_string );

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::WWW::LogicBoxes qw(create_api);

use JSON qw( decode_json );

my $logic_boxes = create_api();

subtest 'Test Unavailable Domains' => sub {
    my $response;
    lives_ok {
        $response = $logic_boxes->domains__available(
            {
                'domain-name' => [ "google", "cnn" ],
                'tlds'        => [ "com",    "net" ]
            }
        );
    }
    'Check the availability of a domain';

    my $json;
    lives_ok {
        $json = decode_json( $response );
    } 'Lives through decoding json';

    for my $domain ( 'google.com', 'google.net', 'cnn.com', 'cnn.net' ) {
        cmp_ok( $json->{$domain}{status}, 'eq', 'regthroughothers', "$domain correctly registered" );
    }
};

subtest 'Test Available Domains' => sub {
    my $slds = [
        'test-' . random_string('nnccnnccnnccnnccnncc'),
        'test-' . random_string('nnccnnccnnccnnccnncc'),
    ];
    my $tlds = [ 'com', 'net' ];

    my $response;
    lives_ok {
        $response = $logic_boxes->domains__available(
            {
                'domain-name' => $slds,
                'tlds'        => $tlds,
            }
        );
    }
    'Check the availability of a domain';

    my $json;
    lives_ok {
        $json = decode_json( $response );
    } 'Lives through decoding json';

    for my $sld (@{ $slds }) {
        for my $tld (@{ $tlds }) {
            my $domain = sprintf('%s.%s', $sld, $tld );
            cmp_ok( $json->{$domain}{status}, 'eq', 'available', "$domain correctly available" );
        }
    }
};

subtest 'Suggest Domain Names' => sub {
    my $response;

    lives_ok {
        $response = $logic_boxes->domains__suggest_names(
            {
                'keyword'        => 'car',
                'tlds'           => [ 'com', 'net', 'org' ],
                'no-of-results'  => 10,
                'hypehn-allowed' => 'false',
                'add-related'    => 'true',
            }
        );
    }
    'Check the name suggestion functionality';

    my $json;
    lives_ok {
        $json = decode_json( $response );
    } 'Lives through decoding json';

    for my $sld ( keys $json ) {
        for my $tld (qw( com net org )) {
            my $domain = sprintf('%s.%s', $sld, $tld );
            my $status = $json->{$sld}{$tld};
            ok( $status eq 'available' || $status eq 'notavailable', "$domain is $status" );
        }
    }
};

done_testing;
