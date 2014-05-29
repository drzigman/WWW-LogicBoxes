#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;
use Test::Exception;

use WWW::LogicBoxes;

if(    ! defined $ENV{PERL_WWW_LOGICBOXES_USERNAME}
    || ! defined $ENV{PERL_WWW_LOGICBOXES_PASSWORD}
    || ! defined $ENV{PERL_WWW_LOGICBOXES_APIKEY} ) {

    plan( skip_all => "PERL_WWW_LOGICBOXES_USERNAME,"
        . " PERL_WWW_LOGICBOXES_PASSWORD, and PERL_WWW_LOGICBOXES_APIKEY"
        . " must be defined in order to run authentication tests.");
}

use Readonly;

Readonly my $USERNAME => $ENV{PERL_WWW_LOGICBOXES_USERNAME};
Readonly my $PASSWORD => $ENV{PERL_WWW_LOGICBOXES_PASSWORD};
Readonly my $APIKEY   => $ENV{PERL_WWW_LOGICBOXES_APIKEY};

subtest "No Credentials" => sub {
    throws_ok {
        WWW::LogicBoxes->new();
    } 'Moose::Exception::AttributeIsRequired', "Dies with no credentials";

    cmp_ok($@->attribute_name, 'eq', 'username', "Missing username");
};

subtest "Only a username" => sub {
    throws_ok {
        WWW::LogicBoxes->new({
            username => $USERNAME,
        });
    } 'Moose::Exception::AttributeIsRequired', "Dies with no credentials";

    cmp_ok($@->attribute_name, 'eq', 'password', "Missing password");
};

subtest "Specified username, password, and api key" => sub {
    throws_ok {
        WWW::LogicBoxes->new({
            username => $USERNAME,
            password => $PASSWORD,
            apikey   => $APIKEY,
        });
    } qr/You must specify a password or an apikey, not both/, "Dies with too many credentials";
};

subtest "Invalid username and password" => sub {
    my $api;

    lives_ok {
        $api = WWW::LogicBoxes->new({
            username => $USERNAME,
            password => "A BAD PASSWORD",
            response_type => 'json',
        });
    } "Lives through object creation";

    throws_ok {
        $api->check_availability({
            slds => [ 'google' ],
            tlds => [ 'com' ],
        });
    } qr/Invalid credentials, or your User account maybe Inactive or Suspended/, "Dies with bad creds";
};

subtest "Valid username and password" => sub {
    my $api;

    lives_ok {
        $api = WWW::LogicBoxes->new({
            username => $USERNAME,
            password => $PASSWORD,
            response_type => 'json',
        });
    } "Lives through object creation";

    my $domains;
    lives_ok {
        $domains = $api->check_availability({
            slds => [ 'google' ],
            tlds => [ 'com' ],
        });
    } "Lives through API action";

    cmp_ok(scalar @{ $domains }, '==', 1, "Domain Returned");
};

subtest "Invalid username and api key" => sub {
    my $api;

    lives_ok {
        $api = WWW::LogicBoxes->new({
            username => $USERNAME,
            apikey   => "A BAD API KEY",
            response_type => 'json',
        });
    } "Lives through object creation";

    throws_ok {
        $api->check_availability({
            slds => [ 'google' ],
            tlds => [ 'com' ],
        });
    } qr/Invalid credentials, or your User account maybe Inactive or Suspended/, "Dies with bad creds";
};

subtest "Valid username and api key" => sub {
    my $api;

    lives_ok {
        $api = WWW::LogicBoxes->new({
            username => $USERNAME,
            apikey   => $APIKEY,,
            response_type => 'json',
        });
    } "Lives through object creation";

    my $domains;
    lives_ok {
        $domains = $api->check_availability({
            slds => [ 'google' ],
            tlds => [ 'com' ],
        });
    } "Lives through API action";

    cmp_ok(scalar @{ $domains }, '==', 1, "Domain Returned");
};

done_testing;
