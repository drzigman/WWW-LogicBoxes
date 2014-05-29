package WWW::LogicBoxes::Domain;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use Carp;
use Mozilla::PublicSuffix qw(public_suffix);

# VERSION
# ABSTRACT: LogicBoxes Domain Representation

=head1 NAME

WWW::LogicBoxes::Domain - LogicBoxes Representation of a Domain

=head1 ATTRIBUTES

=head2 name

String representation of the domain name

=cut

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=head2 is_available

Bool representating if this domain is available or not.

=cut

has is_available => (
    is  => 'ro',
    isa => 'Bool',
    builder => '_build_is_available',
);

=head2 tld

The B<public suffix> of the domain in question.  This is an important distinction between
the public suffix and the tld.  google.co.uk has a tld of "uk" and a public suffix of "co.uk"

=cut

sub tld {
    my $self = shift;

    return public_suffix($self->name);
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _build_is_available {
## use critic

    croak "Not Yet Implemented";
}

__PACKAGE__->meta->make_immutable;
1;
