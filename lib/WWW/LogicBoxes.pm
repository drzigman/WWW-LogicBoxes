package WWW::LogicBoxes;

use strict;
use warnings;
use utf8;

use Any::Moose;
use Any::Moose "::Util::TypeConstraints";
use URI::Escape qw(uri_escape);
use English -no_match_vars;
use IO::Socket::SSL;
use Carp qw(croak);
#use List::Util "reduce";
#use vars qw($a $b);

# VERSION
# ABSTRACT: Interact with LogicBoxes reseller API

with "WWW::LogicBoxes::Role::Commands";

# Supported Response Types:
my @response_types = qw(xml json);
subtype "LogicBoxesResponseType"
	=> as "Str",
	=> where {
		my $type = $ARG;
		{ $type eq $ARG and return 1 for @response_types; 0 }
	},
	=> message {
		"response_type must be one of " . join ", ", @response_types
	};

has username => (
	isa		=> "Str",
	is		=> "ro",
	required	=> 1
);

has password => (
	isa		=> "Str",
	is		=> "ro",
	required 	=> 1
);

has sandbox => (
	isa		=> "Bool",
	is		=> "ro",
	default		=> 0
);

has response_type => (
	isa		=> "LogicBoxesResponseType",
	is		=> "ro",
	default		=> "xml"
);

has _base_uri => (
	isa		=> "Str",
	is		=> "ro",
	lazy		=> 1,
	default		=> \&_default__base_uri
);

sub _make_query_string {
	my ($self, $opts) = @_;

	unless(defined $opts->{api_class}) {
		croak "You must specify the class (domains, contacts, etc...) for the request.  See the class required for yoru specific operation at http://manage.logicboxes.com/kb/answer/751.";
	}

	unless(defined $opts->{api_method}) {
		croak "You must specify the method (create, available, etc...) for the request.  See the method required for your specific operation at http://manage.logicboxes.com/kb/answer/751.";
	}

	my $api_class = $opts->{api_class};
	delete $opts->{api_class};

	my $api_method = $opts->{api_method};
	delete $opts->{api_method};

	$api_class  =~ s/_/-/g;
	$api_class  =~ s/__/\//g;
	$api_method =~ s/_/-/g;
	$api_method =~ s/__/\//g;

	my $queryURI = $self->_base_uri
		. "api/"		. $api_class
		. "/" 			. $api_method
		. "." 			. $self->response_type
		. "?auth-userid=" 	. uri_escape($self->username)
		. "&auth-password=" 	. uri_escape($self->password)
		. "&"			. build_get_args($opts);

	return $queryURI;
}

sub build_get_args {
    my %args = %{$_[0]};
    return join "&", map {
        my $key = $_;
        map {join "=", $key, uri_escape($_) } ref $args{$_} ? @{$args{$_}} : $args{$_}
    } keys %args;
}

=ignore

	my ($raw_args) = @ARG;
	my @get_args;

	for my $key (keys $raw_args) {
		if(ref($raw_args->{$key}) eq ref []) {
			#Handles the fact that the LogicBoxes API accepts the same key but perl hashes do not
			foreach my $value (@{$raw_args->{$key}}) {
				push @get_args, uri_escape($key) . "=" . uri_escape($value);
			}
		}
		else {
			push @get_args, join "=", map { uri_escape($_) } $key, $raw_args->{$key};
		}
	}
	dd \@get_args;
	return join "&", @get_args;
}

=cut

sub _default__base_uri {
	my ($self) = @ARG;

	my $sandbox 	= "https://test.httpapi.com/";
	my $live	= "https://httpapi.com/";

	return $self->sandbox ? $sandbox : $live;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

-encoding utf8

-head1 NAME
WWW::LogicBoxes - Interact with LogicBoxes reseller API

=head1 SYNOPSIS

	use strict;
	use warnings;
	use WWW::LogicBoxes;

	my $logic_boxes = WWW::LogicBoxes->new(
		username	=> "resellid",
		password	=> "resellpw",
		response_type	=> "xml",
		sandbox		=> 1
	);

	my $response = $logic_boxes->domains__available(
		{
			'domain-name' 	=> ["google", "cnn"],
			'tlds'		=> ["com","net"]
		}
	);
	...

=head1 METHODS

=head2 new

Constructs a new object for interacting with the LogicBoxes API.  If the "sandbox" parameter is specified then the API calls are made against the LogicBoxes test server instead of the production server.

response_type is also an objection argument that dictates the format in which the responses from LogicBoxes' API will be in.  The default is XML, all supported protocols are:

=over

=item * xml

=item * json

=back

=head2 Suggest Domains (and many others)

	my $response = $logic_boxes->domains__suggest_names(
		{
			'keyword'	=> 'car',
			'tlds'		=> ['com', 'net', 'org'],
			'no-of-results'	=> 10,
			'hypehn-allowed'=> 'false',
			'add-related'	=> 'true',
		}
	);

This module implements all of the API methods available using the LogicBoxes API by abstracting out the need to specify the HTTP method (POST or GET) and automagically building the request URI according to the documentation provided by Logic Boxes (see the Logic Boxes API user guide at http://manage.logicboxes.com/kb/answer/744).  To fully understand the method names it's best to take a specific example (in this case the suggestion of domain names).

Logic Boxes' API states that this method is part of their HTTP API, specifically the Domain Category and more specifically the Suggest Names method.  The sample URI for this request would then be:

https://test.httpapi.com/api/domains/suggest-names.json?auth-userid=0&auth-password=password&keyword=domain&tlds=com&tlds=net&no-of-results=0&hyphen-allowed=true&add-related=true

The method name is built using the URI that the request is expected at in a logical way.  Since this method is a member of the Domains Category and is specifically Suggest Names we end up:

	$logic_boxes->domains__suggest_names

Where everything before the first "__" is the category and everything following it is the specific method (with - replaced with _ and / replaced with __).

=head2 Arguments Based to Methods

The specific arguments each method requires is not enforced by this module, rather I leave it to the developer to reference the LogicBoxes API (again at http://manage.logicboxes.com/kb/answer/744) and to pass the correct arguments to each method.  There are two "odd" cases that you should be aware of with respect to the way arguments must be passed.

=head3 Repeated Elements

For methods such as domains__check that accept the same "key" multiple times:

https://test.httpapi.com/api/domains/available.json?auth-userid=0&auth-password=password&domain-name=domain1&domain-name=domain2&tlds=com&tlds=net 

This module accepts a hash where the key is the name of the argument (such as domain-name) and the value is an array of values you wish to pass:

	$logic_boxes->domains__available(
		{
			'domain-name' 	=> ["google", "cnn"],
			'tlds'		=> ["com","net"]
		}
	);

This is interprted for you automagically into the repeating elements.

=head1 AUTHORS

Robert Stone, C<< <drzigman AT cpan DOT org >

=head1 ACKNOWLEDGMENTS

Thanks to Richard Simoes for his assistance in putting this module together and for writing the WWW::eNom module that much of this is based on.  Also thanks to HostGator.com for funding the development of this module and providing test resources.

=head1 COPYRIGHT & LICENSE

Copyright 2012 Robert Stone
This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU Lesser General Public License as published by the Free Software Foundation; or any compatible license.

See http://dev.perl.org/licenses/ for more information.
