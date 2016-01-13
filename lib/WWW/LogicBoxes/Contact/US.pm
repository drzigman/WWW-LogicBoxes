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

has 'nexus_purpose' => (
    is       => 'ro',
    isa      => NexusPurpose,
    required => 1,
);

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
