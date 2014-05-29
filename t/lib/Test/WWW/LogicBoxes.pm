package Test::WWW::LogicBoxes;

use strict;
use warnings;

use Test::More;
use Test::Exception;
use MooseX::Params::Validate;

use WWW::LogicBoxes;

use Exporter 'import';
our @EXPORT_OK = qw( create_api );

sub create_api {
    my (%args) = validated_hash(
        \@_,
        response_type => { isa => 'Str', default => 'xml' },
    );

    if(    ! defined $ENV{PERL_WWW_LOGICBOXES_USERNAME}
        || ! defined $ENV{PERL_WWW_LOGICBOXES_PASSWORD} ) {

        plan( skip_all => "PERL_WWW_LOGICBOXES_USERNAME and"
            . " PERL_WWW_LOGICBOXES_PASSWORD must be defined in"
            . " order to run integration tests.");
    }

    my $api;
    lives_ok {
        $api = WWW::LogicBoxes->new({
            username      => $ENV{PERL_WWW_LOGICBOXES_USERNAME},
            password      => $ENV{PERL_WWW_LOGICBOXES_PASSWORD},
            response_type => $args{response_type},
            sandbox       => 1, # Since this is in the test suite it's always dev
        });
    } "Lives through WWW::LogicBoxes object creation";

    return $api;
}

1;
