package WWW::LogicBoxes;

use strict;
use warnings;

use Moose;
use MooseX::StrictConstructor;
use MooseX::Aliases;
use namespace::autoclean;

use WWW::LogicBoxes::Types qw( Bool ResponseType Str URI );

use Carp;

# VERSION
# ABSTRACT: Interact with LogicBoxes reseller API

use Readonly;
Readonly my $LIVE_BASE_URI => 'https://httpapi.com';
Readonly my $TEST_BASE_URI => 'https://test.httpapi.com';

has username => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has password => (
    is        => 'ro',
    isa       => Str,
    required  => 0,
    predicate => 'has_password',
);

has api_key => (
    is        => 'ro',
    isa       => Str,
    required  => 0,
    alias     => 'apikey',
    predicate => 'has_api_key',
);

has sandbox => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
);

has response_type => (
    is       => 'rw',
    isa      => ResponseType,
    default  => 'xml',
);

has _base_uri => (
    is       => 'ro',
    isa      => URI,
    builder  => '_build_base_uri',
);

with 'WWW::LogicBoxes::Role::Command';

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = shift;

    # Assign since api_key or apikey are both valid due to backwards compaitability
    my $password = $args->{password};
    my $api_key  = $args->{apikey} // $args->{api_key};

    if( !$password && !$api_key ) {
        croak 'A password or api_key must be specified';
    }

    if( $password && $api_key ) {
        croak "You must specify a password or an api_key, not both";
    }

    return $class->$orig($args);
};

sub _build_base_uri {
    my $self = shift;

    return $self->sandbox ? $TEST_BASE_URI : $LIVE_BASE_URI;
}

1;
