#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Moose::More;

use WWW::LogicBoxes::Role::Command;

use Readonly;
Readonly my $ROLE => 'WWW::LogicBoxes::Role::Command';

subtest "$ROLE is a well formed role" => sub {
    is_role_ok( $ROLE );
    requires_method_ok( $ROLE, 'response_type' );
    does_ok( $ROLE, 'WWW::LogicBoxes::Role::Command::Raw' );
    does_ok( $ROLE, 'WWW::LogicBoxes::Role::Command::Customer' );
    does_ok( $ROLE, 'WWW::LogicBoxes::Role::Command::Domain::Availability' );
};

subtest "$ROLE has the correct methods" => sub {
    has_method_ok( $ROLE, 'submit');
};

done_testing;
