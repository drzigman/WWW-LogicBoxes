package WWW::LogicBoxes::DomainRequest::Transfer;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Str );

extends 'WWW::LogicBoxes::DomainRequest';

has epp_key => (
    is        => 'ro',
    isa       => Str,
    required  => 0,
    predicate => 'has_epp_key',
);

sub construct_request {
    my $self = shift;

    return {
        'domain-name'        => $self->name,
        ns                   => $self->ns,
        'customer-id'        => $self->customer_id,
        'reg-contact-id'     => $self->registrant_contact_id,
        'admin-contact-id'   => $self->admin_contact_id,
        'tech-contact-id'    => $self->technical_contact_id,
        'billing-contact-id' => $self->billing_contact_id,
        'invoice-option'     => $self->invoice_option,
        $self->has_epp_key ? ( 'auth-code' => $self->epp_key ) : ( ),
        $self->is_private ? (
            'protect-privacy'  => 'true',
            'purchase-privacy' => 'true',
        ) : ( ),
    };
}

__PACKAGE__->meta->make_immutable;
1;
