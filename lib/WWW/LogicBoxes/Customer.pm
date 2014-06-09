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

=head1 NAME

WWW::LogicBoxes::Customer - LogicBoxes Representation of a Customer

=head1 ATTRIBUTES

=head2 I<id>

Numeric ID assigned by LogicBoxes

=cut

has 'id' => (
    is        => 'rw',
    isa       => Int,
    required  => 0,
    predicate => 'has_id',
);

=head2 B<username>

Email address of the customer

=cut

has 'username' => (
    is       => 'rw',
    isa      => EmailAddress,
    required => 1,
);

=head2 B<password>

The password to set for the customer.  B<NOTE> that LogicBoxes is very picky when it
comes to what makes a password valid.  It must be alphanumeric and between 8 and 15 characters
(inclusive).

Also note that this is only used when creating a customer or performing password specific
operations.  It is not ever returned by LogicBoxes once set.

=cut

has 'password' => (
    is        => 'rw',
    isa       => Password,
    required  => 0,
    predicate => 'has_password',
);

=head2 B<name>

The customer's full name

=cut

has 'name' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

=head2 B<company>

The customer's company

=cut

has 'company' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

=head2 B<address1>

The first line of the customer's address

=cut

has 'address1' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

=head2 I<address2>

The second line of the customer's address

=cut

has 'address2' => (
    is        => 'rw',
    isa       => Str,
    required  => 0,
    predicate => 'has_address2',
);

=head2 I<address3>

The third line of the customer's address

=cut

has 'address3' => (
    is        => 'rw',
    isa       => Str,
    required  => 0,
    predicate => 'has_address3',
);

=head2 B<city>

The city of the customer.

=cut

has 'city' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

=head2 I<state>

The geographic state of the customer.  Note that this is not always required, for
US customers it must be the full state name.

=cut

has 'state' => (
    is        => 'rw',
    isa       => Str,
    required  => 0,
    predicate => 'has_state',
);

=head2 B<country>

The 2 digit country code of this customer

=cut

has 'country' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

=head2 B<zipcode>

The postal code of the customer.

=cut

has 'zipcode' => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

=head2 B<phone_number>

The phone number of the customer.  Note that this is actually a Number::Phone object
coerced from a string so it must be well formed enough for Number::Phone to understand it
(or you can provide your own Number::Phone object).  This means that the country code must
be included in the phone number.

    "8005551212"   # Good
    "18005551212"  # Better
    "+18005551212" # Best

Values such as extension and what not are never accepted here.  Just the pure phone number
including the country code.

=cut

has 'phone_number' => (
    is       => 'rw',
    isa      => PhoneNumber,
    required => 1,
    coerce   => 1,
);

=head2 I<alt_phone_number>

An alternate phone number.

=cut

has 'alt_phone_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_alt_phone_number',
);

=head2 I<mobile_phone_number>

Yet another phone number field

=cut

has 'mobile_phone_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_mobile_phone_number',
);

=head2 I<fax_number>

The customer's fax number if they still have a fax machine.

=cut

has 'fax_number' => (
    is        => 'rw',
    isa       => PhoneNumber,
    required  => 0,
    coerce    => 1,
    predicate => 'has_fax_number',
);

=head2 B<language_preference>

The two digit ISO639 code corresponding to the language the customer speaks.
en is english.

=cut

has 'language_preference' => (
    is       => 'rw',
    isa      => Language,
    default  => 'en',
);

__PACKAGE__->meta->make_immutable;
1;
