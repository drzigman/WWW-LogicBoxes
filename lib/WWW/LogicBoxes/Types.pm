package WWW::LogicBoxes::Types;

use strict;
use warnings;

use MooseX::Types -declare => [qw(
    Int
    EmailAddress
    Str
    PhoneNumber
    Password
    Language
    ContactType
)];

use MooseX::Types::Moose
    Int => { -as => 'MooseInt' },
    Str => { -as => 'MooseStr' };

use Number::Phone;

subtype Str, as MooseStr;
subtype Int, as MooseInt;
subtype EmailAddress, as MooseStr;

subtype Password,
    as MooseStr,
    where {(
        $_ =~ m/\d+/ && $_ =~ m/\w+/             # Alphanumeric
        && length($_) >= 8 && length($_) <= 15   # Between 8 and 15 Characters
    )},
    message { "$_ is not a valid password."
        . "  It must be alphanumeric and between 8 and 15 characters" };

class_type PhoneNumber, { class => 'Number::Phone' };

coerce PhoneNumber,
    from Str,
    via { Number::Phone->new( $_ ) };

enum Language, [qw( en )];
enum ContactType, [qw(
    Contact
    AtContact
    CaContact
    CnContact
    CoContact
    CoopContact
    DeContact
    EsContact
    EuContact
    NlContact
    RuContact
    UkContact
)];

1;
