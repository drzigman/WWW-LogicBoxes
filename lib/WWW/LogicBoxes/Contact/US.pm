package WWW::LogicBoxes::Contact::US;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( NexusPurpose NexusCategory );

extends 'WWW::LogicBoxes::Contact';

# VERSION
# ABSTRACT: Contact for .US Registrations

=cut
P1 : Business use for profit.
P2: Non-profit business, club, association, religious organization, etc.
P3: Personal use.
P4: Education purposes.
P5: Government purposes
=cut

has 'nexus_purpose' => (
    is       => 'ro',
    isa      => NexusPurpose,
    required => 1,
);

=cut
C11: A natural person who is a United States citizen.
C12: A natural person who is a permanent resident of the United States of America, or any of its possessions or territories.
C21: A US-based organization or company (A US-based organization or company formed within one of the fifty (50) U.S. states, the District of Columbia, or any of the United States possessions or territories, or organized or otherwise constituted under the laws of a state of the United States of America, the District of Columbia or any of its possessions or territories or a U.S. federal, state, or local government entity or a political subdivision thereof).
C31: A foreign entity or organization (A foreign entity or organization that has a bona fide presence in the United States of America or any of its possessions or territories who regularly engages in lawful activities (sales of goods or services or other business, commercial or non-commercial, including not-for-profit relations in the United States)).
C32: Entity has an office or other facility in the United States.
=cut

has 'nexus_category' => (
    is       => 'ro',
    isa      => NexusCategory,
    required => 1,
);

sub construct_creation_request {
    my $self = shift;

    my $request = $self->SUPER::construct_creation_request();

    $request->{'attr-name1'}  = 'purpose';
    $request->{'attr-value1'} = $self->nexus_purpose;

    $request->{'attr-name2'}  = 'category';
    $request->{'attr-value2'} = $self->nexus_category;

    return $request;
}

sub construct_from_response {
    my $self = shift;
    my $response = shift;

    if( !defined $response ) {
        return;
    }

    my $contact = WWW::LogicBoxes::Contact->construct_from_response( $response );

    if( !defined $contact ) {
        return;
    }

    $self->meta->rebless_instance( $contact,
        nexus_purpose  => $response->{ApplicationPurpose},
        nexus_category => $response->{NexusCategory},
    );


    return $contact;
}

__PACKAGE__->meta->make_immutable;
1;
