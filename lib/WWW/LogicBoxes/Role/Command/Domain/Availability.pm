package WWW::LogicBoxes::Role::Command::Domain::Availability;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( Bool Strs );

use WWW::LogicBoxes::DomainAvailability;

use Data::Validate::Domain qw( is_domain );

requires 'submit';

# VERSION
# ABSTRACT: Domain Availability API Calls

sub check_domain_availability {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        slds        => { isa => Strs },
        tlds        => { isa => Strs },
        suggestions => { isa => Bool, default => 0 },
    );

    my $response = $self->submit({
        method => 'domains__available',
        params => {
            'domain-name' => $args{slds},
            'tlds'        => $args{tlds},
            'suggest-alternative' => $args{suggestions} ? 'true' : 'false',
        }
    });


    my @domain_availabilities;
    for my $domain_name ( keys %{ $response }) {
        if( is_domain( $domain_name ) ) {
            # Standard Response Record
            push @domain_availabilities, WWW::LogicBoxes::DomainAvailability->new({
                name         => $domain_name,
                is_available => $response->{$domain_name}{status} eq "available" ? 1 : 0,
            });
        }
        else {
            # Suggestion Response Record
            for my $sld ( keys $response->{ $domain_name } ) {
                for my $tld ( keys $response->{ $domain_name }{ $sld } ) {
                    push @domain_availabilities, WWW::LogicBoxes::DomainAvailability->new({
                        name         => lc sprintf('%s.%s', $sld, $tld ),
                        is_available => $response->{$domain_name}{$sld}{$tld} eq "available" ? 1 : 0,
                    });
                }
            }
        }
    }

    return \@domain_availabilities;
}

=cut
sub suggest_names {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        phrase      => { isa => 'Str' },
        tlds        => { isa => 'ArrayRef[Str]' },
        hyphen      => { isa => 'Bool', default => 0 },
        related     => { isa => 'Bool', default => 0 },
        num_results => { isa => 'Int',  default => 10 },
    );

    my $response = $self->submit({
        method => 'domains__suggest_names',
        params => {
            keyword          => $args{phrase},
            tlds             => $args{tlds},
            'hyphen-allowed' => $args{hyphen}  ? 'true' : 'false',
            'add-related'    => $args{related} ? 'true' : 'false',
            'no-of-results'  => $args{num_results},
        }
    });

    my @domains;
    for my $sld (keys %{ $response }) {
        for my $tld ( keys %{ $response->{$sld} }) {
            my $domain = WWW::LogicBoxes::Domain->new({
                name => $sld . '.' . $tld,
                is_available => $response->{$sld}{$tld} eq "available" ? 1 : 0,
            });

            push @domains, $domain
        }
    }

    return \@domains;
}
=cut
1;
