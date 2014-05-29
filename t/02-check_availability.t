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

subtest "Single SLD - Single TLD - Available" => sub {
    my $sld = random_string('cccccccccnnnccnncccncccnncc');
    my $tld = 'com';

    test_check_availability({
        slds => [ $sld ],
        tlds => [ $tld ],
        is_available => 1,
    });
};

subtest "Single SLD - Single TLD - Not Available" => sub {
    my $sld = 'google';
    my $tld = 'com';

    test_check_availability({
        slds => [ $sld ],
        tlds => [ $tld ],
        is_available => 0,
    });
};

subtest "Single SLD - Multiple TLD - Available" => sub {
    my $sld  = random_string('cccccccccnnnccnncccncccnncc');
    my @tlds = ('com', 'net', 'org');

    test_check_availability({
        slds => [ $sld ],
        tlds => \@tlds,
        is_available => 1,
    });
};

subtest "Single SLD - Multiple TLD - Not Available" => sub {
    my $sld  = 'google';
    my @tlds = ('com', 'net', 'org');

    test_check_availability({
        slds => [ $sld ],
        tlds => \@tlds,
        is_available => 0,
    });
};

subtest "Multiple SLD - Single TLD - Available" => sub {
    my @slds = (
        random_string('cccccccccnnnccnncccncccnncc'),
        random_string('cccccccccnnnccnncccncccnncc'),
        random_string('cccccccccnnnccnncccncccnncc'),
    );
    my $tld  = 'com';

    test_check_availability({
        slds => \@slds,
        tlds => [ $tld ],
        is_available => 1,
    });
};

subtest "Multiple SLD - Single TLD - Not Available" => sub {
    my @slds = ( 'google', 'cnn', 'yahoo' );
    my $tld  = 'com';

    test_check_availability({
        slds => \@slds,
        tlds => [ $tld ],
        is_available => 0,
    });
};

subtest "Multiple SLD - Multiple TLD - Available" => sub {
    my @slds = (
        random_string('cccccccccnnnccnncccncccnncc'),
        random_string('cccccccccnnnccnncccncccnncc'),
        random_string('cccccccccnnnccnncccncccnncc'),
    );
    my @tlds = ( 'com', 'net', 'org' );

    test_check_availability({
        slds => \@slds,
        tlds => \@tlds,
        is_available => 1,
    });

};

subtest "Multiple SLD - Multiple TLD - Not Available" => sub {
    my @slds = ( 'google', 'cnn', 'yahoo' );
    my @tlds = ( 'com', 'net', 'org' );

    test_check_availability({
        slds => \@slds,
        tlds => \@tlds,
        is_available => 0,
    });
};

done_testing;

sub test_check_availability {
    my (%args) = validated_hash(
        \@_,
        slds => { isa => 'ArrayRef[Str]' },
        tlds => { isa => 'ArrayRef[Str]' },
        is_available => { isa => 'Bool' },
    );

    my $api = create_api({ response_type => 'json' });

    my $domains = $api->check_availability({
        slds => $args{slds},
        tlds => $args{tlds},
    });

    for my $sld (@{ $args{slds} }) {
        for my $tld (@{ $args{tlds} }) {
            subtest "$sld.$tld Availability Check" => sub {
                my $domain = first { $_->name eq "$sld.$tld" } @{ $domains };

                if( ok(defined $domain, "$sld.$tld Found in Response") ) {
                    ok($domain->isa('WWW::LogicBoxes::Domain'), "Domain isa WWW::LogicBoxes::Domain");
                    cmp_ok($domain->name, 'eq', "$sld.$tld", "Correct name");
                    cmp_ok($domain->is_available, '==', $args{is_available}, "Correct is_available");
                }
            };
        }
    }

    return;
}
