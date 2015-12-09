package Test::WWW::LogicBoxes::Contact;

use strict;
use warnings;

use Test::More;
use Test::Exception;
use String::Random qw( random_string );
use MooseX::Params::Validate;

use Test::WWW::LogicBoxes qw( create_api );
use Test::WWW::LogicBoxes::Customer qw( create_customer );

use WWW::LogicBoxes::Types qw( ContactType Int EmailAddress PhoneNumber Str );
use WWW::LogicBoxes::Customer;
use WWW::LogicBoxes::Contact;

use Exporter 'import';
our @EXPORT_OK = qw( create_contact );

sub create_contact {
    my ( %args ) = validated_hash(
        \@_,
        name         => { isa => Str,          optional => 1 },
        company      => { isa => Str,          optional => 1 },
        email        => { isa => EmailAddress, optional => 1 },
        address1     => { isa => Str,          optional => 1 },
        address2     => { isa => Str,          optional => 1 },
        address3     => { isa => Str,          optional => 1 },
        city         => { isa => Str,          optional => 1 },
        state        => { isa => Str,          optional => 1 },
        country      => { isa => Str,          optional => 1 },
        zipcode      => { isa => Str,          optional => 1 },
        phone_number => { isa => PhoneNumber,  optional => 1 },
        fax_number   => { isa => PhoneNumber,  optional => 1 },
        customer_id  => { isa => Int,          optional => 1 },
        type         => { isa => ContactType,  optional => 1 },
    );

    $args{name}         //= 'Edsger Dijkstra';
    $args{company}      //= 'University of Texas at Ausitn';
    $args{email}        //= 'test-' . random_string('ccnnccnnccnnccnnccnnccnn') . '@testing.com';
    $args{address1}     //= 'University of Texas';
    $args{city}         //= 'Austin';
    $args{state}        //= 'Texas';
    $args{country}      //= 'US';
    $args{zipcode}      //= '78713';
    $args{phone_number} //= '18005551212';
    $args{customer_id}  //= create_customer()->id;

    my $api = create_api( );

    my $contact;
    subtest 'Create Contact' => sub {
        lives_ok {
            $contact = WWW::LogicBoxes::Contact->new( %args );
            $api->create_contact( contact => $contact );
        } 'Lives through contact creation';

        note( 'Contact ID: ' . $contact->id );
    };

    return $contact;
}

1;
