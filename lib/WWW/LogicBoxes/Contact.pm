package WWW::LogicBoxes::Contact;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw(Int Str EmailAddress PhoneNumber ContactType);

use WWW::LogicBoxes::PhoneNumber;

# VERSION
# ABSTRACT: LogicBoxes Contact

has 'id' => (
    is        => 'ro',
    isa       => Int,
    required  => 0,
    predicate => 'has_id',
    writer    => '_set_id',
);

has 'name' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'company' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'email' => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
);

has 'address1' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'address2' => (
    is        => 'ro',
    isa       => Str,
    required  => 0,
    predicate => 'has_address2',
);

has 'address3' => (
    is        => 'ro',
    isa       => Str,
    required  => 0,
    predicate => 'has_address3',
);

has 'city' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'state' => (
    is        => 'ro',
    isa       => Str,
    required  => 0,
    predicate => 'has_state',
);

has 'country' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'zipcode' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has 'phone_number' => (
    is       => 'ro',
    isa      => PhoneNumber,
    required => 1,
    coerce   => 1,
);

has 'fax_number' => (
    is        => 'ro',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_fax_number',
);

has 'type' => (
    is       => 'ro',
    isa      => ContactType,
    required => 0,
    default  => 'Contact',
);

has 'customer_id' => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

sub construct_creation_request {
    my $self = shift;

    return {
        name          => $self->name,
        company       => $self->company,
        email         => $self->email,

        'address-line-1' => $self->address1,
        ( $self->has_address2 ) ? ( 'address-line-2' => $self->address2 ) : ( ),
        ( $self->has_address3 ) ? ( 'address-line-3' => $self->address3 ) : ( ),
        city          => $self->city,
        ( $self->has_state )    ? ( state => $self->state ) : ( ),
        country       => $self->country,
        zipcode       => $self->zipcode,

        'phone-cc'    => $self->phone_number->country_code,
        phone         => $self->phone_number->number,
        ( $self->has_fax_number )
            ? ('fax-cc'      => $self->fax_number->country_code,
                fax          => $self->fax_number->number,
            ) : ( ),

        type          => $self->type,
        'customer-id' => $self->customer_id,
    };
}

sub _construct_from_response {
    my $self     = shift;
    my $response = shift;

    if(!defined $response) {
        return;
    }

    my $contact = $self->new({
        id         => $response->{contactid},
        name       => $response->{name},
        company    => $response->{company},
        email      => $response->{emailaddr},

        address1   => $response->{address1},
        ( exists $response->{address2} ) ? ( address2 => $response->{address2} ) : ( ),
        ( exists $response->{address3} ) ? ( address3 => $response->{address3} ) : ( ),
        city       => $response->{city},
        ( exists $response->{state}    ) ? ( state    => $response->{state}    ) : ( ),
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

__PACKAGE__->meta->make_immutable;

1;
