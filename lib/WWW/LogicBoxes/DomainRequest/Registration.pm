package WWW::LogicBoxes::DomainRequest::Registration;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Int );

extends 'WWW::LogicBoxes::DomainRequest';

# VERSION
# ABSTRACT: Domain Registration Request

has years => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

sub construct_request {
    my $self = shift;

    return {
        'domain-name'        => $self->name,
        years                => $self->years,
        ns                   => $self->ns,
        'customer-id'        => $self->customer_id,
        'reg-contact-id'     => $self->registrant_contact_id,
        'admin-contact-id'   => $self->admin_contact_id,
        'tech-contact-id'    => $self->technical_contact_id,
        'billing-contact-id' => $self->billing_contact_id,
        'invoice-option'     => $self->invoice_option,
        $self->is_private ? (
            'protect-privacy'  => 'true',
            'purchase-privacy' => 'true',
        ) : ( ),
    };
}

__PACKAGE__->meta->make_immutable;
1;
