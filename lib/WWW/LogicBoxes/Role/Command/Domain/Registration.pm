package WWW::LogicBoxes::Role::Command::Domain::Registration;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( DomainRegistration Int );

use WWW::LogicBoxes::DomainRequest::Registration;

use Try::Tiny;
use Carp;

requires 'submit', 'get_domain_by_id';

# VERSION
# ABSTRACT: Domain Registration API Calls

sub register_domain {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        request => { isa => DomainRegistration, coerce => 1 }
    );

    my $response = $self->submit({
        method => 'domains__register',
        params => $args{request}->construct_request(),
    });

    return $self->get_domain_by_id( $response->{entityid} );
}

sub delete_domain_registration_by_id {
    my $self = shift;
    my ( $domain_id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'domains__delete',
            params => {
                'order-id' => $domain_id,
            },
        });

        return;
    }
    catch {
        if( $_ =~ m/No Entity found for Entityid/ ) {
            croak 'No such domain to delete';
        }
    };
}

1;
