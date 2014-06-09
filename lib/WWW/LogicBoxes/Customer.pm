package WWW::LogicBoxes::Customer;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw(Int Str PhoneNumber EmailAddress Password Language);

# VERSION
# ABSTRACT: LogicBoxes Customer

has 'id' => (
    is        => 'rw',
    isa       => Int,
    required  => 0,
    predicate => 'has_id',
);

has 'username' => (
    is       => 'rw',
    isa      => EmailAddress,
    required => 1,
);

has 'password' => (
    is        => 'rw',
    isa       => Password,
    required  => 0,
    predicate => 'has_password',
);

has 'name' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has 'company' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has 'address1' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has 'address2' => (
    is        => 'rw',
    isa       => Str,
    required  => 0,
    predicate => 'has_address2',
);

has 'address3' => (
    is        => 'rw',
    isa       => Str,
    required  => 0,
    predicate => 'has_address3',
);

has 'city' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has 'state' => (
    is        => 'rw',
    isa       => Str,
    required  => 0,
    predicate => 'has_state',
);

has 'country' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has 'zipcode' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has 'phone_number' => (
    is       => 'rw',
    isa      => PhoneNumber,
    required => 1,
    coerce   => 1,
);

has 'alt_phone_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_alt_phone_number',
);

has 'mobile_phone_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_mobile_phone_number',
);

has 'fax_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_fax_number',
);

has 'language_preference' => (
    is       => 'rw',
    isa      => Language,
    default  => 'en',
);

__PACKAGE__->meta->make_immutable;
1;
