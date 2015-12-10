package WWW::LogicBoxes::Domain;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Bool DateTime DomainName DomainNames DomainStatus Int Str VerificationStatus );

use DateTime;

# VERSION
# ABSTRACT: LogicBoxes Domain Representation

has id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has name => (
    is       => 'ro',
    isa      => DomainName,
    required => 1,
);

has customer_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has status => (
    is       => 'ro',
    isa      => DomainStatus,
    required => 1,
);

has verification_status => (
    is       => 'ro',
    isa      => VerificationStatus,
    required => 1,
);

has is_locked => (
    is       => 'ro',
    isa      => Bool,
    required => 1,
);

has is_private => (
    is       => 'ro',
    isa      => Bool,
    required => 1,
);

has created_date => (
    is       => 'ro',
    isa      => DateTime,
    required => 1,
);

has expiration_date => (
    is       => 'ro',
    isa      => DateTime,
    required => 1,
);

has ns => (
    is       => 'ro',
    isa      => DomainNames,
    required => 1,
);

has registrant_contact_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has admin_contact_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has technical_contact_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has billing_contact_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has epp_key => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub construct_from_response {
    my $self     = shift;
    my $response = shift;

    if( !$response ) {
        return;
    }

    return $self->new(
        id                    => $response->{orderid},
        name                  => $response->{domainname},
        customer_id           => $response->{customerid},
        status                => $response->{currentstatus},
        verification_status   => $response->{raaVerificationStatus},
        is_locked             => !!( grep { $_ eq 'transferlock' } @{ $response->{orderstatus} } ),
        is_private            => $response->{isprivacyprotected} eq 'true',
        created_date          => DateTime->from_epoch( epoch => $response->{creationtime}, time_zone => 'UTC' ),
        expiration_date       => DateTime->from_epoch( epoch => $response->{endtime}, time_zone => 'UTC' ),
        ns                    => [ map { $response->{ $_ } } sort ( grep { $_ =~ m/^ns/ } keys $response ) ],
        registrant_contact_id => $response->{registrantcontactid},
        admin_contact_id      => $response->{admincontactid},
        technical_contact_id  => $response->{techcontactid},
        billing_contact_id    => $response->{billingcontactid},
        epp_key               => $response->{domsecret},
    );
}

__PACKAGE__->meta->make_immutable;
1;
