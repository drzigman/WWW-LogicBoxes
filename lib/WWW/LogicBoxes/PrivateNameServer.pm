package WWW::LogicBoxes::PrivateNameServer;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( DomainName Int IPv4s );

# VERSION
# ABSTRACT: LogicBoxes Private Nameserver

has domain_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has name => (
    is       => 'ro',
    isa      => DomainName,
    required => 1,
);

has ips => (
    is       => 'ro',
    isa      => IPv4s,
    required => 1,
);

__PACKAGE__->meta->make_immutable;
1;
