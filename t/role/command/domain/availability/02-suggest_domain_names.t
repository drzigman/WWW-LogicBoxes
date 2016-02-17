#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use String::Random qw(random_string);
use MooseX::Params::Validate;

use FindBin;
use lib "$FindBin::Bin/../../../../lib";
use Test::WWW::LogicBoxes qw(create_api);

use WWW::LogicBoxes::Types qw( Bool Int Str Strs );
use WWW::LogicBoxes::DomainAvailability;

use List::Util qw(first);

my $logic_boxes = create_api();

subtest 'Suggest Names for Single TLD - exact match - 1 Result' => sub {
    test_suggest_names({
        keyword      => 'ajshdhjshjdhdjhjshdhdiwidjiwjdijdijwdijsidjwijdijs',
        tld_only        => [ 'com' ],
        exact_match      => 1,
    });
};
subtest 'Suggest Names for Single TLD' => sub {
    test_suggest_names({
        keyword      => 'fast sports car',
        tld_only        => [ 'com' ],
        exact_match      => 0,
    });
};
subtest 'Suggest Names for Multiple TLDs' => sub {
    test_suggest_names({
        keyword      => 'fast sports car',
        tld_only        => [ 'com' ],
        exact_match      => 0,
    });
};
subtest 'Suggest Names for Multiple TLDs' => sub {
    test_suggest_names({
        keyword      => 'dsadsdasdsadsadasdasdijfkomfpmoidmoindjoduhsuhdsdsdw',
        tld_only        => [ 'com', 'org'],
        exact_match      => 1,
    });
};

done_testing;

sub test_suggest_names {
    my (%args) = validated_hash(
        \@_,
        keyword      => { isa => Str  },
        tld_only        => { isa => Strs },
        exact_match      => { isa => Bool },
       
    );

    my $domain_availabilities;
    lives_ok {
        $domain_availabilities = $logic_boxes->suggest_domain_names({
            keyword      => $args{keyword},
            tld_only        => $args{tld_only},
            exact_match      => $args{exact_match},
        });
    } 'Lives through retrieving domain suggestions';

    for my $domain_availability (@{ $domain_availabilities }) {
        subtest 'Inspecting Suggested Domain - ' . $domain_availability->name => sub {
            isa_ok($domain_availability, 'WWW::LogicBoxes::DomainAvailability');
            ok(( grep { $_ eq $domain_availability->tld } @{ $args{tld_only} } ), 'tld is in list of requested tlds');
            if ($args{exact_match}) {
                ok(index($domain_availability->name, $args{'keyword'}) != -1, 'The name matches and its an exact match only tld is changed');
            }
            
        };
    }

    return;
}

