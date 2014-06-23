package WWW::LogicBoxes::Role::Command::Contact;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;
use Smart::Comments -ENV;

use Carp;

requires 'submit';

# VERSION
# ABSTRACT: Contact API Calls

sub create_contact {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        contact => { isa => 'WWW::LogicBoxes::Contact' },
    );

    if( $args{contact}->has_id ) {
        croak "Contact already exists (it has an id)";
    }

    my $response = $self->submit({
        method => 'contacts__add',
        params => {
            name          => $args{contact}->name,
            company       => $args{contact}->company,
            email         => $args{contact}->email,

            'address-line-1' => $args{contact}->address1,
            ( $args{contact}->has_address2 ) ? ( 'address-line-2' => $args{contact}->address2 ) : ( ),
            ( $args{contact}->has_address3 ) ? ( 'address-line-3' => $args{contact}->address3 ) : ( ),
            city          => $args{contact}->city,
            ( $args{contact}->has_state )    ? ( state => $args{contact}->state ) : ( ),
            country       => $args{contact}->country,
            zipcode       => $args{contact}->zipcode,

            'phone-cc'    => $args{contact}->phone_number->country_code,
            phone         => ($args{contact}->phone_number->areacode // '')
                . $args{contact}->phone_number->subscriber,
            ( $args{contact}->has_fax_number )
                ? ('fax-cc'      => $args{contact}->fax_number->country_code,
                    fax          => ($args{contact}->fax_number->areacode // '')
                        . $args{contact}->fax_number->subscriber,
                ) : ( ),
            type          => $args{contact}->type,
            'customer-id' => $args{contact}->customer_id,
        },
    });

    $args{contact}->id($response->{id});

    return $args{contact};
}

sub get_contact_by_id {
    my $self = shift;
    my $id   = shift;

    if(!defined $id) {
        croak "The contact id must be specified";
    }

    my $response = $self->submit({
        method => 'contacts__details',
        params => {
            'contact-id' => $id,
        },
    });

    return $self->_construct_contact_from_result($response);
}

sub _construct_contact_from_result {
    my $self     = shift;
    my $response = shift;

    if(!defined $response) {
        return;
    }

    my $contact = WWW::LogicBoxes::Contact->new({
        id         => $response->{contactid},
        name       => $response->{name},
        company    => $response->{company},
        email      => $response->{emailaddr},

        address1   => $response->{address1},
        ( exists $response->{address2} ) ? ( address2 => $response->{address2} ) : ( ),
        ( exists $response->{address3} ) ? ( address3 => $response->{address3} ) : ( ),
        city       => $response->{city},
        state      => $response->{state},
        country    => $response->{country},
        zipcode    => $response->{zip},

        phone_number => ( $response->{telnocc} . $response->{telno} ),
        ( exists $response->{faxnocc} )
            ? ( fax_number => ( $response->{faxnocc} . $response->{faxno} ) )
            : ( ),

        type        => $response->{type},
        customer_id => $response->{customerid},
    });

    return $contact;
}

1;
