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
use Test::WWW::LogicBoxes::Contact qw( create_contact );

use WWW::LogicBoxes::Contact;

my $logic_boxes = create_api();
my $customer    = create_customer();

subtest 'Update An Uncreated Contact' => sub {
    my $contact = WWW::LogicBoxes::Contact->new(
        name         => 'Edsger Dijkstra',
        company      => 'University of Texas at Ausitn',
        email        => 'test-' . random_string('ccnnccnnccnnccnnccnnccnn') . '@testing.com',
        address1     => 'University of Texas',
        city         => 'Austin',
        state        => 'Texas',
        country      => 'US',
        zipcode      => '78713',
        phone_number => '18005551212',
        customer_id  => $customer->id,
    );

    throws_ok {
        $logic_boxes->update_contact( contact => $contact );
    } qr/Contact does not exist/, 'Correctly throws on uncreated contact';
};

subtest 'Update A Contact That Does Not Exist' => sub {
    my $contact = WWW::LogicBoxes::Contact->new(
        id           => 999999999,
        name         => 'Edsger Dijkstra',
        company      => 'University of Texas at Ausitn',
        email        => 'test-' . random_string('ccnnccnnccnnccnnccnnccnn') . '@testing.com',
        address1     => 'University of Texas',
        city         => 'Austin',
        state        => 'Texas',
        country      => 'US',
        zipcode      => '78713',
        phone_number => '18005551212',
        customer_id  => $customer->id,
    );

    throws_ok {
        $logic_boxes->update_contact( contact => $contact );
    } qr/Invalid Contact ID/, 'Correctly throws on uncreated contact';
};

subtest 'Update A Contact - Modified Fields' => sub {
    my $contact = create_contact( customer_id => $customer->id );

    my $updated_contact = WWW::LogicBoxes::Contact->new(
        id           => $contact->id,
        name         => 'Nico Habermann',
        company      => 'Free University of Amsterdam',
        email        => 'test-' . random_string('ccnnccnnccnnccnnccnnccnn') . '@testing.com',
        address1     => 'Computer Science Building',
        city         => 'Amsterdam',
        state        => 'North Holland',
        country      => 'NL',
        zipcode      => '78713',
        phone_number => '+31205989898 ',
        customer_id  => $customer->id,
    );

    lives_ok {
        $logic_boxes->update_contact( contact => $updated_contact );
    } 'Lives through updating contact';

    my $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );

    is_deeply( $retrieved_contact, $updated_contact, 'Contact correctly updated' );
};

subtest 'Update A Contact - Remove Optional Fields' => sub {
    my $contact = create_contact(
        customer_id => $customer->id,
        address2    => 'Suite 300',
        address3    => 'PO Box 12345',
        fax_number  => '18005551212',
    );

    my $updated_contact = WWW::LogicBoxes::Contact->new(
        id           => $contact->id,
        name         => $contact->name,
        company      => $contact->company,
        email        => $contact->email,
        address1     => $contact->address1,
        city         => $contact->city,
        state        => $contact->state,
        country      => $contact->country,
        zipcode      => $contact->zipcode,
        phone_number => $contact->phone_number,
        customer_id  => $customer->id,
    );

    lives_ok {
        $logic_boxes->update_contact( contact => $updated_contact );
    } 'Lives through updating contact';

    my $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );

    is_deeply( $retrieved_contact, $updated_contact, 'Contact correctly updated' );
    ok( !$retrieved_contact->has_address2, 'Correctly lacks address2' );
    ok( !$retrieved_contact->has_address3, 'Correctly lacks address3' );
    ok( !$retrieved_contact->has_fax_number, 'Correctly lacks fax_number' );
};

done_testing;
