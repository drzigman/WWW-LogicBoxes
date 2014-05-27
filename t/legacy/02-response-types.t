#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::WWW::LogicBoxes qw(create_api);

use WWW::LogicBoxes;

lives_ok {
    my $logic_boxes = create_api( { response_type => 'xml' } );
    my $response = $logic_boxes->domains__available(
        {
            'domain-name' => [ "google", "cnn" ],
            'tlds'        => [ "com",    "net" ]
        }
    );
}
'Test Response Type of XML';

lives_ok {
    my $logic_boxes = create_api( { response_type => 'xml_simple' } );
    my $response = $logic_boxes->domains__available(
        {
            'domain-name' => [ "google", "cnn" ],
            'tlds'        => [ "com",    "net" ]
        }
    );
}
'Test Response Type of XML Simple';

lives_ok {
    my $logic_boxes = create_api( { response_type => 'json' } );
    my $response = $logic_boxes->domains__available(
        {
            'domain-name' => [ "google", "cnn" ],
            'tlds'        => [ "com",    "net" ]
        }
    );
}
"Test Response Type of JSON";

done_testing;
