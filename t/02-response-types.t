#!/usr/bin/env perl

use Test::Most tests => 3;
use WWW::LogicBoxes;

use Data::Dumper;

my $username = undef;
my $password = undef;
my $sandbox = 0;

SKIP : {
	skip "Reseller Username and Password not defined", 3 unless defined $username and defined $password;

	lives_ok {
		my $logic_boxes = WWW::LogicBoxes->new(
			username => $username,
			password => $password,
			sandbox  => $sandbox,
			response_type => 'xml'
		);

		my $response = $logic_boxes->domains__available(
			{
				'domain-name' 	=> ["google", "cnn"],
				'tlds'		=> ["com","net"]
			}
		);
	} 'Test Response Type of XML';

	lives_ok {
		my $logic_boxes = WWW::LogicBoxes->new(
			username => $username,
			password => $password,
			sandbox  => $sandbox,
			response_type => 'xml_simple'
		);

		my $response = $logic_boxes->domains__available(
			{
				'domain-name' 	=> ["google", "cnn"],
				'tlds'		=> ["com","net"]
			}
		);
	} 'Test Response Type of XML Simple';

	lives_ok {
		my $logic_boxes = WWW::LogicBoxes->new(
			username => $username,
			password => $password,
			sandbox  => $sandbox,
			response_type => 'json'
		);

		my $response = $logic_boxes->domains__available(
			{
				'domain-name' 	=> ["google", "cnn"],
				'tlds'		=> ["com","net"]
			}
		);
	} "Test Response Type of JSON";
}
