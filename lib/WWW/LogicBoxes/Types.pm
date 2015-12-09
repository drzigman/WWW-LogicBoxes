package WWW::LogicBoxes::Types;

use strict;
use warnings;

use Data::Validate::Domain qw( is_domain );
use Data::Validate::Email qw( is_email );
use Data::Validate::URI qw( is_uri );

# VERSION
# ABSTRACT: WWW::LogicBoxes Moose Type Library

use MooseX::Types -declare => [qw(
    ArrayRef
    Bool
    HashRef
    Int
    Str
    Strs

    DomainName
    EmailAddress
    Language
    Password
    PhoneNumber
    NumberPhone
    ResponseType
    URI

    Customer
)];

use MooseX::Types::Moose
    ArrayRef => { -as => 'MooseArrayRef' },
    Bool     => { -as => 'MooseBool' },
    HashRef  => { -as => 'MooseHashRef' },
    Int      => { -as => 'MooseInt' },
    Str      => { -as => 'MooseStr' };

subtype ArrayRef, as MooseArrayRef;
subtype Bool,     as MooseBool;
subtype HashRef,  as MooseHashRef;
subtype Int,      as MooseInt;
subtype Str,      as MooseStr;

subtype Strs,     as ArrayRef[Str];

enum Language, [qw( en )];
enum ResponseType, [qw( xml json xml_simple )];

class_type NumberPhone, { class => 'Number::Phone' };
class_type PhoneNumber, { class => 'WWW::LogicBoxes::PhoneNumber' };
coerce PhoneNumber, from Str,
    via { WWW::LogicBoxes::PhoneNumber->new( $_ ) };
coerce PhoneNumber, from NumberPhone,
    via { WWW::LogicBoxes::PhoneNumber->new( $_->format ) };

class_type Customer, { class => 'WWW::LogicBoxes::Customer' };
coerce Customer, from HashRef,
    via { WWW::LogicBoxes::Customer->new( $_ ) };

subtype DomainName, as Str,
    where { is_domain( $_ ) },
    message { "$_ is not a valid domain" };

subtype EmailAddress, as Str,
    where { is_email( $_ ) },
    message { "$_ is not a valid email address" };

subtype Password, as Str,
    where {(
        $_ =~ m/([a-zA-Z0-9])+/                  # Alphanumeric
        && length($_) >= 8 && length($_) <= 15   # Between 8 and 15 Characters
    )},
    message { "$_ is not a valid password.  It must be alphanumeric and between 8 and 15 characters" };

subtype URI, as Str,
    where { is_uri( $_ ) },
    message { "$_ is not a valid URI" };

1;
