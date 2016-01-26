#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Deep;
use MooseX::Params::Validate;
use String::Random qw( random_string );

use FindBin;
use lib "$FindBin::Bin/../../../../lib";
use Test::WWW::LogicBoxes qw( create_api );
use Test::WWW::LogicBoxes::Customer qw( create_customer );
use Test::WWW::LogicBoxes::Contact qw( create_contact );

use WWW::LogicBoxes::Types qw( DomainRegistration );

use WWW::LogicBoxes::Domain;
use WWW::LogicBoxes::DomainRequest::Registration;

use DateTime;

my $logic_boxes        = create_api();
my $customer           = create_customer();
my $registrant_contact = create_contact( customer_id => $customer->id );
my $admin_contact      = create_contact( customer_id => $customer->id );
my $technical_contact  = create_contact( customer_id => $customer->id );
my $billing_contact    = create_contact( customer_id => $customer->id );

subtest 'Register Available Domain - Without Privacy' => sub {
    my $request;
    lives_ok {
        $request = WWW::LogicBoxes::DomainRequest::Registration->new(
            name        => 'test-' . random_string('nnccnnccnnccnnccnnccnncc') . '.com',
            years       => 1,
            customer_id => $customer->id,
            ns          => [ 'ns1.logicboxes.com', 'ns2.logicboxes.com' ],
            registrant_contact_id => $registrant_contact->id,
            admin_contact_id      => $admin_contact->id,
            technical_contact_id  => $technical_contact->id,
            billing_contact_id    => $billing_contact->id,
        );
    } 'Lives through creating request object';

    test_domain_registration( $request );
};

subtest 'Register Available Domain - With Privacy' => sub {
    my $request;
    lives_ok {
        $request = WWW::LogicBoxes::DomainRequest::Registration->new(
            name        => 'test-' . random_string('nnccnnccnnccnnccnnccnncc') . '.com',
            years       => 1,
            customer_id => $customer->id,
            ns          => [ 'ns1.logicboxes.com', 'ns2.logicboxes.com' ],
            is_private  => 1,
            registrant_contact_id => $registrant_contact->id,
            admin_contact_id      => $admin_contact->id,
            technical_contact_id  => $technical_contact->id,
            billing_contact_id    => $billing_contact->id,
        );
    } 'Lives through creating request object';

    test_domain_registration( $request );
};

subtest 'Attempt to Register Unavailable Domain' => sub {
    my $request;
    lives_ok {
        $request = WWW::LogicBoxes::DomainRequest::Registration->new(
            name        => 'google.com',
            years       => 1,
            customer_id => $customer->id,
            ns          => [ 'ns1.logicboxes.com', 'ns2.logicboxes.com' ],
            is_private  => 1,
            registrant_contact_id => $registrant_contact->id,
            admin_contact_id      => $admin_contact->id,
            technical_contact_id  => $technical_contact->id,
            billing_contact_id    => $billing_contact->id,
        );
    } 'Lives through creating request object';

    my $domain;
    throws_ok {
        $domain = $logic_boxes->register_domain( request => $request );
    } qr/Domain google\.com already registered/, 'Throws registering an existing domain';
};

done_testing;

sub test_domain_registration {
    my ( $request ) = pos_validated_list( \@_, { isa => DomainRegistration } );

    my $domain;
    lives_ok {
        $domain = $logic_boxes->register_domain( request => $request );
    } 'Lives through domain registration';

    subtest 'Inspect Created Domain' => sub {
        if( isa_ok( $domain, 'WWW::LogicBoxes::Domain' ) ) {
            note( 'Domain ID: ' . $domain->id );

            cmp_ok( $domain->name,                'eq', $request->name, 'Correct name' );
            cmp_ok( $domain->customer_id,         '==', $customer->id, 'Correct customer_id' );
            cmp_ok( $domain->status,              'eq', 'Active', 'Correct status' );
            cmp_ok( $domain->verification_status, 'eq', 'Pending', 'Correct verification_status' );

            ok( $domain->is_locked, 'Correct is_locked' );
            cmp_ok( $domain->is_private, '==', $request->is_private, 'Correct is_private' );

            my $now = DateTime->now( time_zone => 'UTC' );
            cmp_ok( $domain->created_date->ymd,    'eq', $now->ymd, 'Correct created_date' );
            cmp_ok( $domain->expiration_date->ymd, 'eq', $now->clone->add( years => 1 )->ymd, 'Correct expiration_date' );

            is_deeply( $domain->ns, $request->ns, 'Correct ns' );

            cmp_ok( $domain->registrant_contact_id, '==', $registrant_contact->id, 'Correct registrant_contact_id' );
            cmp_ok( $domain->admin_contact_id,      '==', $admin_contact->id, 'Correct admin_contact_id' );
            cmp_ok( $domain->technical_contact_id,  '==', $technical_contact->id, 'Correct technical_contact_id' );
            cmp_ok( $domain->billing_contact_id,    '==', $billing_contact->id, 'Correct billing_contact_id' );
        }
    };

    return;
}
