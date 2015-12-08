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

use WWW::LogicBoxes::Customer;

my $fake = Faker::Factory->new(locale => 'en_US')->create;

subtest "Create a US Customer" => sub {
    my $api     = create_api( );

    my $customer;
        lives_ok {
            $customer = WWW::LogicBoxes::Customer->new({
            username     => lc $fake->email_address,
            password     => "ABADPASSW1",
            name         => $fake->name,
            company      => $fake->company,
            address1     => $fake->street_address,
            address2     => $fake->street_address,
            city         => $fake->city,
            state        => $fake->state_name,
            country      => 'US',
            zipcode      => $fake->postal_code,
            phone_number        => '18005551212',
            fax_number          => '18005551212',
            mobile_phone_number => '18005551212',
            alt_phone_number    => '18005551212',
        });
    } "Lives through customer object creation";

    my $created_customer;
    lives_ok {
        $created_customer = $api->create_customer({ customer => $customer });
    } "Lives through remote customer creation";

    ok($created_customer->has_id, "An id has been set");
    like($created_customer->id, qr/^\d+$/, "The id is numeric");
    note("Contact ID: " . $created_customer->id);

    my $retrieved_customer = $api->get_customer_by_id($created_customer->id);
    isa_ok($retrieved_customer, 'WWW::LogicBoxes::Customer');

    cmp_ok($retrieved_customer->id,        '==', $created_customer->id, "Correct id");
    cmp_ok($retrieved_customer->name,      'eq', $created_customer->name, "Correct name");
    cmp_ok($retrieved_customer->company,   'eq', $created_customer->company, "Correct company");
    cmp_ok($retrieved_customer->username,  'eq', $created_customer->username, "Correct username");
    cmp_ok($retrieved_customer->address1,  'eq', $created_customer->address1, "Correct address1");
    cmp_ok($retrieved_customer->address2,  'eq', $created_customer->address2, "Correct address2");
    ok(!$retrieved_customer->has_address3, "No address3");
    cmp_ok($retrieved_customer->city,      'eq', $created_customer->city, "Correct city");
    cmp_ok($retrieved_customer->state,     'eq', $created_customer->state, "Correct state");
    cmp_ok($retrieved_customer->country,   'eq', $created_customer->country, "Correct country");
    cmp_ok($retrieved_customer->zipcode,   'eq', $created_customer->zipcode, "Correct zipcode");

    cmp_ok($retrieved_customer->phone_number->format,
        'eq', $created_customer->phone_number->format, "Correct phone_number");
    cmp_ok($retrieved_customer->fax_number->format,
        'eq', $created_customer->fax_number->format, "Correct fax_number");
    cmp_ok($retrieved_customer->mobile_phone_number->format,
        'eq', $created_customer->mobile_phone_number->format, "Correct mobile_phone_number");
    cmp_ok($retrieved_customer->alt_phone_number->format,
        'eq', $created_customer->alt_phone_number->format, "Correct alt_phone_number");

    cmp_ok($retrieved_customer->language_preference, 'eq',
        $created_customer->language_preference, "Correct language_preference");
};

done_testing;
