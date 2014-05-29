package WWW::LogicBoxes::Role::Command::CheckAvailability;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;
use Smart::Comments -ENV;

use Carp;
use JSON qw(decode_json);
use Mozilla::PublicSuffix qw(public_suffix);

use WWW::LogicBoxes::Domain;

requires 'submit';

# VERSION
# ABSTRACT: Domain Availability API Calls

=head1 NAME

WWW::LogicBoxes::Role::Command::CheckAvailability

=head1 SYNOPSIS

    use strict;
    use warnings;

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Domain;

    my $api = WWW::LogicBoxes->new({ ... });
    my $domains = $api->check_availability({
        slds => [ 'cpan', 'hostgator', 'drzigman' ],
        tlds => [ 'com', 'net', org' ]
    });

=head1 METHODS

=head2 check_availability

    my $api = WWW::LogicBoxes->new({ ... });
    my $domains = $api->check_availability({
        slds => [ 'cpan', 'hostgator', 'drzigman' ],
        tlds => [ 'com', 'net', org' ]
    });

Checks to see if the specified combination of slds and tlds are available which must be
presented as ArrayRef's of strings.  Returned is an arrayref of WWW::LogicBoxes::Domain objects.

The method will also croak if there is a failure communicating with the LogicBoxes API (such
as it's down or it returned invalid JSON)

=cut

sub check_availability {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        slds => { isa => 'ArrayRef[Str]' },
        tlds => { isa => 'ArrayRef[Str]' },
    );

    if( $self->response_type ne 'json' ) {
        croak "The response_type must be set to json";
    }

    my $response = $self->submit({
        method => 'domains__available',
        params => {
            'domain-name' => $args{slds},
            'tlds'        => $args{tlds},
        }
    });

    my @domains;
    for my $domain_name (keys %{ $response }) {
        my $domain = WWW::LogicBoxes::Domain->new({
            name         => $domain_name,
            is_available => $response->{$domain_name}{status} eq "available" ? 1 : 0,
        });

        push @domains, $domain;
    }

    return \@domains;
}

=head2 suggest_names

    my $api = WWW::LogicBoxes->new({ ... });
    my $domains = $api->suggest_names({
        phrase      => "fast sports car",
        tlds        => [ 'com', 'net', 'org' ],
        hyphen      => 0,
        related     => 0,
        num_results => 10,
    });

suggest_names will ask the LogicBoxes API to suggest potential domain names given a search
phrase.

=over 4

=item B<phrase>

Required.  A string representing a search phrase.  It's worth noting that the more specific the query
the more results you'll get so something like "car" may get zero results but "fast sports car" gets a lot.

=item B<tlds>

An ArrayRef of Strings containing the tlds you wish to include in the search

=item I<hyphen>

Boolean that indicates if you wish to allow hypheniations in domain names, defaults to false.

=item I<related>

Boolean that indicates if you with to allow related concepts to your phrase.  Defaults to false.

=item I<num_results>

The number of phrase matches you wish to allow.  Note that the actual max number of results from
a given query is the num_results * the number of tlds since the num_results refers only to sld
matches.  Defaults to 10.

=back

Returned is an ArrayRef of WWW::LogicBoxes::Domain objects.

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

    if( $self->response_type ne 'json' ) {
        croak "The response_type must be set to json";
    }

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

1;
