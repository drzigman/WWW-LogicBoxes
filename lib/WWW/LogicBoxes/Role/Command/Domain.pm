package WWW::LogicBoxes::Role::Command::Domain;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( DomainName Int );

use WWW::LogicBoxes::Domain;

use Try::Tiny;
use Carp;

use Readonly;
Readonly my $DOMAIN_DETAIL_OPTIONS => [qw( OrderDetails DomainStatus ContactIds NsDetails StatusDetails )];

requires 'submit';

# VERSION
# ABSTRACT: Domain API Calls

sub get_domain_by_id {
    my $self = shift;
    my ( $domain_id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'domains__details',
            params => {
                'order-id' => $domain_id,
                'options'  => $DOMAIN_DETAIL_OPTIONS,
            }
        });

        return WWW::LogicBoxes::Domain->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            return;
        }

        croak $_;
    };
}

sub get_domain_by_name {
    my $self = shift;
    my ( $domain_name ) = pos_validated_list( \@_, { isa => DomainName } );

    return try {
        my $response = $self->submit({
            method => 'domains__details_by_name',
            params => {
                'domain-name' => $domain_name,
                'options'     => $DOMAIN_DETAIL_OPTIONS,
            }
        });

        return WWW::LogicBoxes::Domain->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/^Website doesn't exist for/ ) {
            return;
        }

        croak $_;
    };
}

1;
