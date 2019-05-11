#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::MockModule;

use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::WWW::LogicBoxes::Domain qw( create_domain );
use Test::WWW::LogicBoxes qw( create_api );

use WWW::LogicBoxes::Domain;

my $logic_boxes = create_api;

subtest 'Resend Email Verification For Domain That Does Not Exist - Throws Exception' => sub {
    throws_ok {
        $logic_boxes->resend_verification_email( id => 999999999 );
    } qr/No such domain exists/;
};

subtest 'Resend Email Verification For Domain That Does Not Need It - Throws Exception' => sub {
    my $mocked_domain_status = Test::MockModule->new('WWW::LogicBoxes::Domain');
    $mocked_domain_status->mock(
        'verification_status',
        sub {
            return 'Verified';
        }
    );
    my $domain = create_domain();
    throws_ok {
        $logic_boxes->resend_verification_email( id => $domain->id );
    } qr/Domain already verified/;
};

subtest 'Resend Email Verification For Domain Requiring Verification - Successful' => sub {
    my $domain = create_domain();

    lives_ok {
        $logic_boxes->resend_verification_email( id => $domain->id );
    };
};

done_testing;
