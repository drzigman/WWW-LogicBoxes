#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/../../../lib";
use Test::WWW::LogicBoxes qw( create_api );
use Test::WWW::LogicBoxes::Contact qw( create_contact );

use WWW::LogicBoxes::Contact;

my $logic_boxes = create_api();

subtest 'Get Contact By ID That Does Not Exist' => sub {
    my $retrieved_contact;
    lives_ok {
        $retrieved_contact = $logic_boxes->get_contact_by_id( 9999999999 );
    } 'Lives through retrieving_contact';

    ok( !defined $retrieved_contact, 'Correctly does not return a contact' );
};

subtest 'Get Valid Contact By ID' => sub {
    my $contact = create_contact();

    my $retrieved_contact;
    lives_ok {
        $retrieved_contact = $logic_boxes->get_contact_by_id( $contact->id );
    } 'Lives through retrieving contact';

    is_deeply( $retrieved_contact, $contact, 'Correct contact' );
};

done_testing;
