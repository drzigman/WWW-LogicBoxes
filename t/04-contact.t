#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;
use Test::Exception;
use Faker::Factory;
use MooseX::Params::Validate;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::WWW::LogicBoxes qw(create_api);

use WWW::LogicBoxes::Contact;

my $fake = Faker::Factory->new(locale => 'en_US')->create;

subtest "Create a US Contact" => sub {
    my $api     = create_api( );

    my $contact;
        lives_ok {
            $contact = WWW::LogicBoxes::Contact->new({
            name         => $fake->name,
            company      => $fake->company,
            email        => $fake->email_address,
            address1     => $fake->street_address,
            address2     => $fake->street_address,
            city         => $fake->city,
            state        => $fake->state_name,
            country      => 'USA',
            zipcode      => $fake->postal_code,
            phone_number => '18005551212',
            fax_number   => '18005551212',
            customer_id  => ...,
        });
    } "Lives through contact object creation";

    my $created_contact;
    lives_ok {
        $created_contact = $api->create_contact({ contact => $contact });
    } "Lives through remote contact creation";

    #TODO: Fetch the contact back from LogicBoxes and test that

    ok($created_contact->has_id, "An id has been set");
    like($created_contact->id, qr/^\d+$/, "The id is numeric");
    note("Contact ID: " . $created_contact->id);

    cmp_ok($created_contact->name,      'eq', $contact->name, "Correct name");
    cmp_ok($created_contact->company,   'eq', $contact->company, "Correct company");
    cmp_ok($created_contact->email,     'eq', $contact->email, "Correct email");
    cmp_ok($created_contact->address1,  'eq', $contact->address1, "Correct address1");
    cmp_ok($created_contact->address2,  'eq', $contact->address2, "Correct address2");
    ok(!$created_contact->has_address3, "No address2");
    cmp_ok($created_contact->city,      'eq', $contact->city, "Correct city");
    cmp_ok($created_contact->state,     'eq', $contact->state, "Correct state");
    cmp_ok($created_contact->country,   'eq', $contact->country, "Correct country");
    cmp_ok($created_contact->zipcode,   'eq', $contact->zipcode, "Correct zipcode");
    cmp_ok($created_contact->phone_number->format, 'eq', $contact->phone_number->format, "Correct phone_number");
    cmp_ok($created_contact->fax_number->format,   'eq', $contact->fax_number->format, "Correct fax_number");
    cmp_ok($created_contact->type,      'eq', $contact->type, "Correct type");
    cmp_ok($created_contact->owner_id,  '==', $contact->owner_id, "Correct owner_id");

};

done_testing;
