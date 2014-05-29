package WWW::LogicBoxes::Role::Submit;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use Carp qw(croak);
use JSON qw(decode_json);

# VERSION
# ABSTRACT: Actually performs the interaction with LogicBoxes

sub submit {
    my $self   = shift;
    my (%args) = validated_hash(
        \@_,
        method => { isa => 'Str' },
        params => { isa => 'HashRef' },
    );

    my $current_response_type = $self->response_type;
    if( $current_response_type ne 'json' ) {
        $self->response_type('json');
    }

    my $response = eval {
        my $method = $args{method};
        my $raw_json = $self->$method( $args{params} );

        ### Raw JSON: ($raw_json)

        return decode_json($raw_json);
    };

    if($@) {
        croak "Unable to decode response from LogicBoxes: $@";
    }

    if(exists $response->{status} && $response->{status} eq "ERROR") {
        croak $response->{message};
    }

    if($self->response_type ne $current_response_type) {
        $self->response_type($current_response_type);
    }

    return $response;
}

1;
