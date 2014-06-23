package WWW::LogicBoxes::Contact;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Email qw(EmailAddress);
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw(Int Str EmailAddress PhoneNumber ContactType);

# VERSION
# ABSTRACT: LogicBoxes Contact

has 'id' => (
    is        => 'rw',
    isa       => Int,
    required  => 0,
    predicate => 'has_id',
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

has 'email' => (
    is       => 'rw',
    isa      => EmailAddress,
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

has 'fax_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_fax_number',
);

has 'type' => (
    is       => 'rw',
    isa      => ContactType,
    required => 0,
    default  => 'Contact',
);

has 'customer_id' => (
    is       => 'rw',
    isa      => Int,
    required => 1,
);

__PACKAGE__->meta->make_immutable;
1;


