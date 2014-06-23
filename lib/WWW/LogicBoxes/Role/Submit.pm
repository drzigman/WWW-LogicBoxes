package WWW::LogicBoxes::Role::Submit;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;
use Smart::Comments -ENV;

use Carp qw(croak);
use JSON qw(decode_json);

# VERSION
# ABSTRACT: Actually performs the interaction with LogicBoxes

=head1 NAME

WWW::LogicBoxes::Role::Submit - Actually Performs the Interaction with LogicBoxes

=head1 METHODS

=head2 submit

    my $response = $self->submit({
        method => 'domains__available',
        params => {
            'domain-name' => $args{slds},
            'tlds'        => $args{tlds},
        }
    });

Note the B<self> this is a Role.

submit performs the actual submission to the LogicBoxes API and is abstracted as such since
there is a lot of boilerplate for making a submission.  This is also the method that makes it
possible to use any response type yet still get the JSON needed in order for the well defined
methods to work.

It returns an ArrayRef that is the response on success, and croaks on serious errors like
invalid credentials or unable to decode the response from LogicBoxes.

=cut

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

        if($raw_json =~ /^\d+$/) {
            # When just an id is returned, JSON is not used
            return { id => $raw_json };
        }

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
