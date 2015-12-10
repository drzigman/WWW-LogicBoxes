package WWW::LogicBoxes::Role::Command::Domain::Transfer;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( DomainName );

use Try::Tiny;
use Carp;

requires 'submit';

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

1;
