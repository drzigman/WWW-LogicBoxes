package WWW::LogicBoxes::Role::Command::Domain::Registration;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( DomainRegistration );

use WWW::LogicBoxes::DomainRequest::Registration;

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

1;
