package WWW::LogicBoxes::Customer;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw(EmailAddress Int Language PhoneNumber Str );

use WWW::LogicBoxes::PhoneNumber;

# VERSION
# ABSTRACT: LogicBoxes Customer

has 'id' => (
    is        => 'ro',
    isa       => Int,
    required  => 0,
    predicate => 'has_id',
    writer    => '_set_id',
);

has 'username' => (
    is       => 'ro',
    isa      => EmailAddress,
    required => 1,
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

has 'alt_phone_number' => (
    is        => 'ro',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_alt_phone_number',
);

has 'mobile_phone_number' => (
    is        => 'ro',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_mobile_phone_number',
);

has 'fax_number' => (
    is        => 'ro',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_fax_number',
);

has 'language_preference' => (
    is       => 'ro',
    isa      => Language,
    default  => 'en',
);

sub construct_from_response {
    my $self     = shift;
    my $response = shift;

    if(!defined $response) {
        return;
    }

    return $self->new({
        id       => $response->{customerid},
        username => $response->{username},
        name     => $response->{name},
        company  => $response->{company},
        address1 => $response->{address1},
        ( exists $response->{address2} ) ? ( address2 => $response->{address2} ) : ( ),
        ( exists $response->{address3} ) ? ( address3 => $response->{address3} ) : ( ),
        city     => $response->{city},
        ( $response->{state} ne 'Not Applicable' ) ? ( state => $response->{state} ) : ( ),
        country  => $response->{country},
        zipcode  => $response->{zip},
        phone_number => ( $response->{telnocc} . $response->{telno} ),
        ( exists $response->{faxnocc} )
            ? ( fax_number => ( $response->{faxnocc} . $response->{faxno} ) )
            : ( ),
        ( exists $response->{mobilenocc} )
            ? ( mobile_phone_number => ( $response->{mobilenocc} . $response->{mobileno} ) )
            : ( ),
        ( exists $response->{alttelnocc} )
            ? ( alt_phone_number => ( $response->{alttelnocc} . $response->{alttelno} ) )
            : ( ),
        language_preference => $response->{langpref},
    });
}

__PACKAGE__->meta->make_immutable;

1;
