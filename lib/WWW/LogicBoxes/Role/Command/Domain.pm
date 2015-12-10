package WWW::LogicBoxes::Role::Command::Domain;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( Int );

use WWW::LogicBoxes::Domain;

requires 'submit';

# VERSION
# ABSTRACT: Domain API Calls

sub get_domain_by_id {
    my $self = shift;
    my ( $domain_id ) = pos_validated_list( \@_, { isa => Int } );

    my $response = $self->submit({
        method => 'domains__details',
        params => {
            'order-id' => $domain_id,
            'options'  => [qw( OrderDetails DomainStatus ContactIds NsDetails StatusDetails )],
        }
    });

    return WWW::LogicBoxes::Domain->construct_from_response( $response );
}

1;
