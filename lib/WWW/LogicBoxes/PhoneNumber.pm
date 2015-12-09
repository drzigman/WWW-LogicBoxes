package WWW::LogicBoxes::PhoneNumber;

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use overload '""' => \&_to_string, fallback => 1;

use WWW::LogicBoxes::Types qw( Str NumberPhone );

use Number::Phone;
use Carp;

# VERSION
# ABSTRACT: Extendes Number::Phone to add 'number' functionatly (without country code)

has '_number_phone_obj' => (
    is       => 'ro',
    isa      => NumberPhone,
    required => 1,
);

has 'country_code' => (
    is      => 'ro',
    isa     => Str,
    builder => '_build_country_code',
    lazy    => 1,
);

has 'number' => (
    is      => 'ro',
    isa     => Str,
    builder => '_build_number',
    lazy    => 1,
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my $args;
    if( scalar @_ > 1 ) {
        return $class->$orig( @_ );
    }
    else {
        $args = shift;
    }

    if( ref $args eq '' ) {
        return $class->$orig( _number_phone_obj => Number::Phone->new( $args ) );
    }
    elsif( ( ref $args ) =~ m/Number::Phone/ ) {
        return $class->$orig( _number_phone_obj => $args );
    }
    else {
        croak "Invalid params passed to $class";
    }
};

sub _build_country_code {
    my $self = shift;

    return $self->_number_phone_obj->country_code;
}

sub _build_number {
    my $self = shift;

    my $full_number = $self->_number_phone_obj->format;
    $full_number =~ s/[^\d]*//g;

    return substr( $full_number, length( $self->country_code ) );
}

sub _to_string {
    my $self = shift;

    return $self->country_code . $self->number;
}

__PACKAGE__->meta->make_immutable;

1;
