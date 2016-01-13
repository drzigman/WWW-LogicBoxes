package WWW::LogicBoxes::DomainAvailability;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Aliases;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Bool DomainName Str );

use Mozilla::PublicSuffix;

# VERSION
# ABSTRACT: LogicBoxes Domain Availability Response

has name => (
    is       => 'ro',
    isa      => DomainName,
    required => 1,
);

has is_available => (
    is       => 'ro',
    isa      => Bool,
    required => 1,
);

has sld => (
    is       => 'ro',
    isa      => Str,
    builder  => '_build_sld',
    lazy     => 1,
    init_arg => undef,
);

has public_suffix => (
    is       => 'ro',
    isa      => Str,
    alias    => 'tld',
    builder  => '_build_public_suffix',
    lazy     => 1,
    init_arg => undef,
);

sub _build_sld {
    my $self = shift;

    return substr( $self->name, 0, length( $self->name ) - ( length( $self->public_suffix ) + 1 ) );
}

sub _build_public_suffix {
    my $self = shift;

    return Mozilla::PublicSuffix::public_suffix( $self->name );
}

__PACKAGE__->meta->make_immutable;

1;
