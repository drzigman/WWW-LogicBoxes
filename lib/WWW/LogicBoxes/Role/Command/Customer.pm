package WWW::LogicBoxes::Role::Command::Customer;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( Customer EmailAddress Int Password );

use WWW::LogicBoxes::Customer;

use Try::Tiny;
use Carp;

requires 'submit';

# VERSION
# ABSTRACT: Customer API Calls

sub create_customer {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        customer => { isa => Customer, coerce => 1 },
        password => { isa => Password },
    );

    if( $args{customer}->has_id ) {
        croak "Customer already exists (it has an id)";
    }

    my $response = $self->submit({
        method => 'customers__signup',
        params => {
            username => $args{customer}->username,
            passwd   => $args{password},
            name     => $args{customer}->name,
            company  => $args{customer}->company,

            'address-line-1' => $args{customer}->address1,
            ( $args{customer}->has_address2 ) ? ( 'address-line-2' => $args{customer}->address2 ) : ( ),
            ( $args{customer}->has_address3 ) ? ( 'address-line-3' => $args{customer}->address3 ) : ( ),

            city          => $args{customer}->city,
            ( $args{customer}->has_state ) ? ( state => $args{customer}->state ) : ( state => 'Not Applicable', 'other-state' => ''),
            country       => $args{customer}->country,
            zipcode       => $args{customer}->zipcode,

            'phone-cc'    => $args{customer}->phone_number->country_code,
            'phone'       => $args{customer}->phone_number->number,
            ($args{customer}->has_fax_number) ?
                (   'fax-cc'      => $args{customer}->fax_number->country_code,
                    'fax'         => $args{customer}->fax_number->number,
                ) : (),
            ($args{customer}->has_alt_phone_number) ?
                (   'alt-phone-cc'      => $args{customer}->alt_phone_number->country_code,
                    'alt-phone'         => $args{customer}->alt_phone_number->number,
                ) : (),
            ($args{customer}->has_mobile_phone_number) ?
                (   'mobile-cc'      => $args{customer}->mobile_phone_number->country_code,
                    'mobile'         => $args{customer}->mobile_phone_number->number,
                ) : (),

            'lang-pref'   => $args{customer}->language_preference,
        },
    });

    $args{customer}->_set_id( $response->{id} );

    return $args{customer};
}

sub get_customer_by_id {
    my $self        = shift;
    my ( $customer_id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'customers__details_by_id',
            params => {
                'customer-id' => $customer_id,
            }
        });
    
        return WWW::LogicBoxes::Customer->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/^Invalid customer-id/ ) {
            return;
        }

        croak $_;
    };
}

sub get_customer_by_username {
    my $self     = shift;
    my ( $username ) = pos_validated_list( \@_, { isa => EmailAddress } );

    return try {
        my $response = $self->submit({
            method => 'customers__details',
            params => {
                'username' => $username,
            }
        });

        return WWW::LogicBoxes::Customer->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/Customer [^\s]* not found/ ) {
            return;
        }

        croak $_;
    };
}

1;
