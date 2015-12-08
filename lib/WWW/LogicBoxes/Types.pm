package WWW::LogicBoxes::Types;

use strict;
use warnings;

use Data::Validate::URI qw( is_uri );

# VERSION
# ABSTRACT: WWW::LogicBoxes Moose Type Library

use MooseX::Types -declare => [qw(
    Bool
    HashRef
    Str

    ResponseType
    URI
)];

use MooseX::Types::Moose
    Bool    => { -as => 'MooseBool' },
    HashRef => { -as => 'MooseHashRef' },
    Str     => { -as => 'MooseStr' };

subtype Bool,    as MooseBool;
subtype HashRef, as MooseHashRef;
subtype Str,     as MooseStr;

enum ResponseType, [qw( xml json xml_simple )];

subtype URI, as Str,
    where { is_uri( $_ ) },
    message { "$_ is not a valid URI" };


1;
