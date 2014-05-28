package WWW::LogicBoxes::Role::Command::CheckAvailability;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use Carp;
use JSON qw(decode_json);
use Mozilla::PublicSuffix qw(public_suffix);

use WWW::LogicBoxes::Domain;

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

B<NOTE> In order for this method to function properly you must set the response_type to json
when building the initial WWW::LogicBoxes object.  Otherwise the method will croak.

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

    my $response = eval {
        my $raw_json = $self->domains__available({
            'domain-name' => $args{slds},
            'tlds'        => $args{tlds},
        });

        return decode_json($raw_json);
    };

    if($@) {
        croak "Unable to decode response from LogicBoxes";
    }


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

1;
