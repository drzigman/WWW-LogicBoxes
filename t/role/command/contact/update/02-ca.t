#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use String::Random qw( random_string );

use FindBin;
use lib "$FindBin::Bin/../../../../lib";
use Test::WWW::LogicBoxes qw( create_api );
use Test::WWW::LogicBoxes::Customer qw( create_customer );
use Test::WWW::LogicBoxes::Contact qw( create_ca_contact );

use WWW::LogicBoxes::Contact::CA;
use WWW::LogicBoxes::Contact::CA::Agreement;

subtest 'Update CA Contact' => sub {
    my $logic_boxes = create_api();
    my $customer    = create_customer();
    my $agreement   = $logic_boxes->get_ca_registrant_agreement();

    subtest 'Change Name' => sub {
        my $contact = create_ca_contact(
            customer_id => $customer->id,
        );

        my $updated_contact = WWW::LogicBoxes::Contact::CA->new(
            ( map { $_ => $contact->$_ }
                qw( id company email address1 city state country zipcode phone_number customer_id cpr ) ),
            name => 'New Name',
        );

        throws_ok {
            $logic_boxes->update_contact( contact => $updated_contact );
        } qr/The name of CA Contacts can not be modified/, 'Throws on changing name';
    };

    subtest 'Change Email' => sub {
        my $contact = create_ca_contact(
            customer_id => $customer->id,
        );

        my $updated_contact = WWW::LogicBoxes::Contact::CA->new(
            ( map { $_ => $contact->$_ }
                qw( id name company address1 city state country zipcode phone_number customer_id cpr ) ),
            email => 'my_new_email@testing.com',
        );

        lives_ok {
            $logic_boxes->update_contact( contact => $updated_contact );
        } 'Lives through updating contact';

        my $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );
        if( isa_ok( $retrieved_contact, 'WWW::LogicBoxes::Contact::CA' ) ) {
            cmp_ok( $retrieved_contact->email, 'eq', $updated_contact->email, 'Correct email' );
        }
    };

    subtest 'Change Address' => sub {
        my $contact = create_ca_contact(
            customer_id => $customer->id,
        );

        my $updated_contact = WWW::LogicBoxes::Contact::CA->new(
            ( map { $_ => $contact->$_ }
                qw( id name company email phone_number customer_id cpr ) ),
            address1 => '123 Change Str',
            address2 => 'Suite: 2600',
            city     => 'Miami',
            state    => 'Florida',
            country  => 'US',
            zipcode  => '33326',
        );

        lives_ok {
            $logic_boxes->update_contact( contact => $updated_contact );
        } 'Lives through updating contact';

        my $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );
        if( isa_ok( $retrieved_contact, 'WWW::LogicBoxes::Contact::CA' ) ) {
            for my $attribute (qw( address1 address2 city state country zipcode )) {
                cmp_ok( $retrieved_contact->$attribute, 'eq', $updated_contact->$attribute, "Correct $attribute" );
            }
        }
    };

    subtest 'Change Phone and Fax Number' => sub {
        my $contact = create_ca_contact(
            customer_id => $customer->id,
        );

        my $updated_contact = WWW::LogicBoxes::Contact::CA->new(
            ( map { $_ => $contact->$_ }
                qw( id name company email address1 city state country zipcode customer_id cpr ) ),
            phone_number => '18005553333',
            fax_number   => '18005554444',
        );

        lives_ok {
            $logic_boxes->update_contact( contact => $updated_contact );
        } 'Lives through updating contact';

        my $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );
        if( isa_ok( $retrieved_contact, 'WWW::LogicBoxes::Contact::CA' ) ) {
            cmp_ok( $retrieved_contact->phone_number, 'eq', $updated_contact->phone_number, 'Correct phone_number' );
            cmp_ok( $retrieved_contact->fax_number, 'eq', $updated_contact->fax_number, 'Correct fax_number' );
        }
    };

    subtest 'Change CPR Code' => sub {
        my $contact = create_ca_contact(
            customer_id => $customer->id,
            cpr         => 'ABO',
        );

        my $updated_contact = WWW::LogicBoxes::Contact::CA->new(
            ( map { $_ => $contact->$_ }
                qw( id name company email address1 city state country zipcode phone_number customer_id ) ),
            cpr => 'CCT'
        );

        throws_ok {
            $logic_boxes->update_contact( contact => $updated_contact );
        } qr/The CPR of a CA Contact can not be changed/, 'Throws on changing cpr';
    };
};

done_testing;
