package WWW::LogicBoxes::Role::Command::Domain::Transfer;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( DomainName DomainTransfer );

use Try::Tiny;
use Carp;

requires 'submit', 'get_domain_by_id';

# VERSION
# ABSTRACT: Domain Transfer API Calls

sub is_domain_transferable {
    my $self = shift;
    my ( $domain_name ) = pos_validated_list( \@_, { isa => DomainName } );

    return try {
        my $response = $self->submit({
            method => 'domains__validate_transfer',
            params => {
                'domain-name' => $domain_name
            }
        });

        return ( $response->{result} eq 'true' );
    }
    catch {
        if( $_ =~ m/is currently available for Registration/ ) {
            return;
        }

        croak $_;
    };
}

sub transfer_domain {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        request => { isa => DomainTransfer, coerce => 1 },
    );

    my $response = $self->submit({
        method => 'domains__transfer',
        params => $args{request}->construct_request,
    });

    if( $response->{status} eq 'Failed' ) {
        if( $response->{actionstatusdesc} =~ m/Order Locked In Processing/ ) {
            croak 'Domain is locked';
        }
        else {
            croak $response->{actionstatusdesc};
        }
    }

    return $self->get_domain_by_id( $response->{entityid} );
}

1;
