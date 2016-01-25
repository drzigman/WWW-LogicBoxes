package WWW::LogicBoxes::DomainTransfer;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Bool DateTime DomainName DomainNames DomainStatus Int PrivateNameServers Str VerificationStatus );

use WWW::LogicBoxes::PrivateNameServer;

use DateTime;

# VERSION
# ABSTRACT: LogicBoxes Domain Transfer In Progress Representation

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

has transfer_status => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has verification_status => (
    is       => 'ro',
    isa      => VerificationStatus,
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
    is        => 'ro',
    isa       => Str,
    required  => 0,
    predicate => 'has_epp_key',
);

has private_nameservers => (
    is        => 'ro',
    isa       => PrivateNameServers,
    required  => 0,
    predicate => 'has_private_nameservers',
);

sub construct_from_response {
    my $self     = shift;
    my $response = shift;

    if( !$response ) {
        return;
    }

    my @private_nameservers;
    for my $private_nameserver_name ( keys $response->{cns} ) {
        push @private_nameservers, WWW::LogicBoxes::PrivateNameServer->new(
            domain_id => $response->{orderid},
            name      => $private_nameserver_name,
            ips       => $response->{cns}{$private_nameserver_name},
        );
    }

    return $self->new(
        id                    => $response->{orderid},
        name                  => $response->{domainname},
        customer_id           => $response->{customerid},
        status                => $response->{currentstatus},
        transfer_status       => $response->{actionstatusdesc},
        verification_status   => $response->{raaVerificationStatus},
        ns                    => [ map { $response->{ $_ } } sort ( grep { $_ =~ m/^ns/ } keys $response ) ],
        registrant_contact_id => $response->{registrantcontactid},
        admin_contact_id      => $response->{admincontactid},
        technical_contact_id  => $response->{techcontactid},
        billing_contact_id    => $response->{billingcontactid},
        $response->{domsecret} ? ( epp_key => $response->{domsecret} ) : ( ),
        scalar @private_nameservers ? ( private_nameservers => \@private_nameservers ) : ( ),
    );
}

__PACKAGE__->meta->make_immutable;
1;
