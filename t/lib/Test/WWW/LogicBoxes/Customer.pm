package Test::WWW::LogicBoxes::Customer;

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Faker::Factory;
use MooseX::Params::Validate;

use Test::WWW::LogicBoxes qw(create_api);

use WWW::LogicBoxes::Types qw(EmailAddress Password Str PhoneNumber);
use WWW::LogicBoxes::Customer;

use Exporter 'import';
our @EXPORT_OK = qw( create_customer );

my $fake = Faker::Factory->new(locale => 'en_US')->create;

sub create_customer {
    my (%args) = validated_hash(
        \@_,
        username     => { isa => EmailAddress, optional => 1 },
        password     => { isa => Password,     optional => 1 },
        name         => { isa => Str,          optional => 1 },
        company      => { isa => Str,          optional => 1 },
        address1     => { isa => Str,          optional => 1 },
        address2     => { isa => Str,          optional => 1 },
        address3     => { isa => Str,          optional => 1 },
        city         => { isa => Str,          optional => 1 },
        state        => { isa => Str,          optional => 1 },
        country      => { isa => Str,          optional => 1 },
        zipcode      => { isa => Str,          optional => 1 },
        phone_number        => { isa => PhoneNumber, optional => 1 },
        fax_number          => { isa => PhoneNumber, optional => 1 },
        mobile_phone_number => { isa => PhoneNumber, optional => 1 },
        alt_phone_number    => { isa => PhoneNumber, optional => 1 },
    );

    $args{username} //= lc $fake->email_address;
    $args{password} //= "ABADPASSW1";
    $args{name}     //= $fake->name;
    $args{company}  //= $fake->company;
    $args{address1} //= $fake->street_address;
    $args{address2} //= $fake->street_address;
    $args{city}     //= $fake->city;
    $args{state}    //= $fake->state_name;
    $args{country}  //= 'US';
    $args{zipcode}  //= $fake->postal_code;
    $args{phone_number}        //= '18005551212';
    $args{fax_number}          //= '18005551212';
    $args{mobile_phone_number} //= '18005551212';
    $args{alt_phone_number}    //= '18005551212';

    my $api = create_api( );

    my $customer;
    lives_ok {
        $customer = WWW::LogicBoxes::Customer->new(\%args);
        $api->create_customer({ customer => $customer });
    } "Lives through customer creation";

    note("Customer ID: " . $customer->id);

    return $customer;
}

1;
