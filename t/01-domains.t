#!/usr/bin/env perl

use Test::Most tests => 5;
use WWW::LogicBoxes;

use Data::Dumper;

my $logic_boxes = WWW::LogicBoxes->new(
	username => "",
	password => "",
	sandbox  => 1
);

lives_ok {
	my $response = $logic_boxes->domains__available(
		{
			'domain-name' 	=> ["google", "cnn"],
			'tlds'		=> ["com","net"]
		}
	);
} 'Check the availability of a domain';

lives_ok {
	my $response = $logic_boxes->domains__suggest_names(
		{
			'keyword'	=> 'car',
			'tlds'		=> ['com', 'net', 'org'],
			'no-of-results'	=> 10,
			'hypehn-allowed'=> 'false',
			'add-related'	=> 'true',
		}
	);
} 'Check the name suggestion functionality';

lives_ok {
	my $response = $logic_boxes->domains__orderid(
		{
			'domain-name'	=> 'hostgator.com',
		}
	);
} "Get a domain's order id";

lives_ok {
	my $response = $logic_boxes->domains__renew(
		{
			'order-id'	=> '1234',
			'years'		=> '2',
			'exp-date'	=> '1279012036',
			'invoice-option'=> 'OnlyAdd',
		}
	);
} 'Attempt to renew a domain';

lives_ok {
	my $response = $logic_boxes->domains__tel__cth_details(
		{
			'order-id'	=> '1234',
		}
	);

} 'Testing an API method with a / and a -';

