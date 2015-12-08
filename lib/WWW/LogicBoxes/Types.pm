package WWW::LogicBoxes::Types;

use strict;
use warnings;

use Data::Validate::Domain qw( is_domain );
use Data::Validate::URI qw( is_uri );

# VERSION
# ABSTRACT: WWW::LogicBoxes Moose Type Library

use MooseX::Types -declare => [qw(
    ArrayRef
    Bool
    HashRef
    Str
    Strs

    DomainName
    ResponseType
    URI
)];

use MooseX::Types::Moose
    ArrayRef => { -as => 'MooseArrayRef' },
    Bool     => { -as => 'MooseBool' },
    HashRef  => { -as => 'MooseHashRef' },
    Str      => { -as => 'MooseStr' };

subtype ArrayRef, as MooseArrayRef;
subtype Bool,     as MooseBool;
subtype HashRef,  as MooseHashRef;
subtype Str,      as MooseStr;

subtype Strs,     as ArrayRef[Str];

enum ResponseType, [qw( xml json xml_simple )];

subtype DomainName, as Str,
    where { is_domain( $_ ) },
    message { "$_ is not a valid domain" };

subtype URI, as Str,
    where { is_uri( $_ ) },
    message { "$_ is not a valid URI" };

1;
