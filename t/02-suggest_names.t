#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;
use Test::Exception;
use String::Random qw(random_string);
use MooseX::Params::Validate;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::WWW::LogicBoxes qw(create_api);

use List::Util qw(first);

use WWW::LogicBoxes::Domain;

subtest "Suggest Names for Single TLD - No Hyphen - No Related - 1 Result" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com' ],
        hyphen      => 0,
        related     => 0,
        num_results => 1,
    });
};

subtest "Suggest Names for Single TLD - No Hyphen - No Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com' ],
        hyphen      => 0,
        related     => 0,
        num_results => 5,
    });
};

subtest "Suggest Names for Single TLD - With Hyphen - No Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com' ],
        hyphen      => 1,
        related     => 0,
        num_results => 5,
    });
};

subtest "Suggest Names for Single TLD - No Hyphen - With Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com' ],
        hyphen      => 0,
        related     => 1,
        num_results => 5,
    });
};

subtest "Suggest Names for Single TLD - With Hyphen - With Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com' ],
        hyphen      => 1,
        related     => 1,
        num_results => 5,
    });
};

subtest "Suggest Names for Multiple TLD - No Hyphen - No Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com', 'org', 'net' ],
        hyphen      => 0,
        related     => 0,
        num_results => 5,
    });
};

subtest "Suggest Names for Multiple TLD - With Hyphen - No Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com', 'org', 'net' ],
        hyphen      => 1,
        related     => 0,
        num_results => 5,
    });
};

subtest "Suggest Names for Multiple TLD - No Hyphen - With Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com', 'org', 'net' ],
        hyphen      => 0,
        related     => 1,
        num_results => 5,
    });
};

subtest "Suggest Names for Multiple TLD - With Hyphen - With Related - 5 Results" => sub {
    test_suggest_names({
        phrase      => 'fast sports car',
        tlds        => [ 'com', 'org', 'net' ],
        hyphen      => 1,
        related     => 1,
        num_results => 5,
    });
};

done_testing;

sub test_suggest_names {
    my (%args) = validated_hash(
        \@_,
        phrase      => { isa => 'Str' },
        tlds        => { isa => 'ArrayRef[Str]' },
        hyphen      => { isa => 'Bool' },
        related     => { isa => 'Bool' },
        num_results => { isa => 'Int' },
    );

    my $api = create_api({ response_type => 'json' });

    my $domains = $api->suggest_names({
        phrase      => $args{phrase},
        tlds        => $args{tlds},
        hyphen      => $args{hyphen},
        related     => $args{related},
        num_results => $args{num_results},
    });

    cmp_ok(scalar @{ $domains }, '==', $args{num_results} * scalar @{ $args{tlds} },
        "Correct number of results");

    for my $domain (@{ $domains }) {
        note("Suggested Domain: " . $domain->name);

        isa_ok($domain, 'WWW::LogicBoxes::Domain');
        cmp_ok($domain->tld, '~~', $args{tlds}, "tld is in list of requested tlds");

        if( !$args{hyphen} ) {
            ok( index($domain->name, '-') == -1, "No hyphens in domain name" );
        }

    }

    return;
}

