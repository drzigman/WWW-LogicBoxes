package WWW::LogicBoxes::DomainRequest;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Bool DomainName DomainNames Int InvoiceOption );

# VERSION
# ABSTRACT: Abstract Base Class for Domain Registration/Transfer Requests

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

has is_private => (
    is       => 'ro',
    isa      => Bool,
    default  => 0,
);

has invoice_option => (
    is       => 'ro',
    isa      => InvoiceOption,
    default  => 'NoInvoice',
);

__PACKAGE__->meta->make_immutable;

1;
