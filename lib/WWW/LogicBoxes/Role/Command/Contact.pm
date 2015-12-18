package WWW::LogicBoxes::Role::Command::Contact;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( Contact Int );

use WWW::LogicBoxes::Contact;

use Try::Tiny;
use Carp;

requires 'submit';

# VERSION
# ABSTRACT: Contact API Calls

sub create_contact {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        contact => { isa => Contact },
    );

    if( $args{contact}->has_id ) {
        croak "Contact already exists (it has an id)";
    }

    my $response = $self->submit({
        method => 'contacts__add',
        params => $args{contact}->construct_creation_request(),
    });
   
    $args{contact}->_set_id($response->{id});

    return $args{contact};
}

sub get_contact_by_id {
    my $self = shift;
    my ( $id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'contacts__details',
            params => {
                'contact-id' => $id,
            },
        });

        # TODO: Abstract this into a Factory that can contain multiple sets of attributes
        # Because we only have normal and .us right now this works for now.
        if( scalar @{ $response->{contacttype} } == 0 ) {
            return WWW::LogicBoxes::Contact->construct_from_response($response);
        }
        elsif( grep { $_ eq 'domus' } @{ $response->{contacttype} } ) {
            return WWW::LogicBoxes::Contact::US->construct_from_response($response);
        }
        else {
            croak 'Unknown contact type';
        }
    }
    catch {
        if( $_ =~ m/^Invalid contact-id/ ) {
            return;
        }

        croak $_;
    };
}

sub delete_contact_by_id {
    my $self = shift;
    my ( $id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'contacts__delete',
            params => {
                'contact-id' => $id,
            },
        });

        return;
    }
    catch {
        croak $_;
    };
}

1;
