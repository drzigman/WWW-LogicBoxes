package WWW::LogicBoxes::Domain;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has is_available => (
    is  => 'ro',
    isa => 'Bool',
    builder => '_build_is_available',
);


sub _build_is_available {
    ...
}

__PACKAGE__->meta->make_immutable;
1;
