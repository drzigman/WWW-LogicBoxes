package WWW::LogicBoxes;

use strict;
use warnings;
use utf8;

use Moose;
use Moose::Util qw(throw_exception);
use Moose::Util::TypeConstraints;
use Moose::Exception::AttributeIsRequired;
use Smart::Comments -ENV;

use Carp qw(croak);

use URI::Escape qw(uri_escape);
use English -no_match_vars;
use IO::Socket::SSL;

# VERSION
# ABSTRACT: Interact with LogicBoxes reseller API

with "WWW::LogicBoxes::Role::Commands",
  "WWW::LogicBoxes::Role::Submit",
  "WWW::LogicBoxes::Role::Command::CheckAvailability";

# Supported Response Types:
my @response_types = qw(xml json xml_simple);
subtype
  "LogicBoxesResponseType" => as "Str",
  => where {
    my $type = $ARG;
    { $type eq $ARG and return 1 for @response_types; 0 }
  },
  => message {
    "response_type must be one of " . join ", ", @response_types;
  };

has username => (
    isa      => "Str",
    is       => "ro",
    required => 1,
);

has password => (
    isa       => "Str",
    is        => "ro",
    required  => 0,
    predicate => 'has_password',
);

has apikey => (
    isa       => "Str",
    is        => "ro",
    required  => 0,
    predicate => 'has_apikey',
);

has sandbox => (
    isa     => "Bool",
    is      => "ro",
    default => 0
);

has response_type => (
    isa     => "LogicBoxesResponseType",
    is      => "rw",
    default => "xml"
);

has _base_uri => (
    isa     => "Str",
    is      => "ro",
    lazy    => 1,
    default => \&_default__base_uri
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my $args  = shift;

    if( !exists $args->{username} ) {
        ### No Username Specified

        throw_exception(AttributeIsRequired => attribute_name => 'username',
            class_name => $class,
            params     => $args,
        );
    }

    if( !exists $args->{password} && !exists $args->{apikey} ) {
        ### No Password and No API Key Specified

        throw_exception(AttributeIsRequired => attribute_name => 'password',
            class_name => $class,
            params     => $args,
        );
    }

    if( exists $args->{password} && exists $args->{apikey} ) {
        ### Both a Password and an API Key Were Specified

        croak "You must specify a password or an apikey, not both.";
    }

    return $class->$orig($args);
};


## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _make_query_string {
## use critic
    my ( $self, $opts ) = @_;

    unless ( defined $opts->{api_class} ) {
        croak
"You must specify the class (domains, contacts, etc...) for the request.  See the class required for yoru specific operation at http://manage.logicboxes.com/kb/answer/751.";
    }

    unless ( defined $opts->{api_method} ) {
        croak
"You must specify the method (create, available, etc...) for the request.  See the method required for your specific operation at http://manage.logicboxes.com/kb/answer/751.";
    }

    my $api_class = $opts->{api_class};
    delete $opts->{api_class};

    my $api_method = $opts->{api_method};
    delete $opts->{api_method};

    $api_class =~ s/_/-/g;
    $api_class =~ s/__/\//g;
    $api_method =~ s/_/-/g;
    $api_method =~ s/__/\//g;

    my $response_type =
      ( $self->response_type eq 'xml_simple' ) ? 'xml' : $self->response_type;

    my $query_uri = $self->_base_uri . "api/" . $api_class . "/" . $api_method . "."
        . $response_type . "?auth-userid=" . uri_escape( $self->username );

    if( $self->has_password ) {
      $query_uri .= "&auth-password=" . uri_escape( $self->password )
    }
    elsif($self->has_apikey) {
      $query_uri .= "&api-key=" . uri_escape( $self->apikey )
    }

    $query_uri .= "&" . _build_get_args($opts);

    return $query_uri;
}

sub _build_get_args {
    my %args = %{ $_[0] };

    #TODO: Clean this up
    ## no critic (BuiltinFunctions::ProhibitComplexMappings)
    return join "&", map {
        my $key = $_;
        map { join "=", $key, uri_escape($_) }
          ref $args{$_}
          ? @{ $args{$_} }
          : $args{$_}
    } keys %args;
    ## use critic
}

sub _default__base_uri {
    my ($self) = @ARG;

    my $sandbox = "https://test.httpapi.com/";
    my $live    = "https://httpapi.com/";

    return $self->sandbox ? $sandbox : $live;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=encoding utf8

=head1 NAME
WWW::LogicBoxes - Interact with LogicBoxes Reseller API

=head1 SYNOPSIS

    use strict;
    use warnings;
    use WWW::LogicBoxes;

    my $logic_boxes = WWW::LogicBoxes->new({
        username	=> "resellid",

        # You may specify a password OR an apikey
        password	=> "resellpw",
        apikey      => "apikey",

        response_type => "xml",
        sandbox		  => 1
    });

    my $response = $logic_boxes->domains__available({
        'domain-name' 	=> ["google", "cnn"],
        'tlds'		=> ["com","net"]
    } );

=head1 METHODS

=head2 new

Constructs a new object for interacting with the LogicBoxes API.  If the "sandbox" parameter is specified then the API calls are made against the LogicBoxes test server instead of the production server.

response_type is also an object argument that dictates the format in which the responses from LogicBoxes' API will be in.  The default is XML, all supported protocols are:

=over

=item * xml

=item * json

=item * xml_simple

=back

=head2 Suggest Domains (and many others)

    my $response = $logic_boxes->domains__suggest_names({
        'keyword'	=> 'car',
        'tlds'		=> ['com', 'net', 'org'],
        'no-of-results'	=> 10,
        'hypehn-allowed'=> 'false',
        'add-related'	=> 'true',
    });

This module implements all of the API methods available using the LogicBoxes API by abstracting out the need to specify the HTTP method (POST or GET) and automagically building the request URI according to the documentation provided by Logic Boxes (see the Logic Boxes API user guide at http://manage.logicboxes.com/kb/answer/744).  To fully understand the method names it's best to take a specific example (in this case the suggestion of domain names).

Logic Boxes' API states that this method is part of their HTTP API, specifically the Domain Category and more specifically the Suggest Names method.  The sample URI for this request would then be:

https://test.httpapi.com/api/domains/suggest-names.json?auth-userid=0&auth-password=password&keyword=domain&tlds=com&tlds=net&no-of-results=0&hyphen-allowed=true&add-related=true

The method name is built using the URI that the request is expected at in a logical way.  Since this method is a member of the Domains Category and is specifically Suggest Names we end up:

    $logic_boxes->domains__suggest_names

Where everything before the first "__" is the category and everything following it is the specific method (with - replaced with _ and / replaced with __).

=head1 Arguments Passed to Methods

The specific arguments each method requires is not enforced by this module, rather I leave it to the developer to reference the LogicBoxes API (again at http://manage.logicboxes.com/kb/answer/744) and to pass the correct arguments to each method as a hash.  There are two "odd" cases that you should be aware of with respect to the way arguments must be passed.

=head2 Repeated Elements

For methods such as domains__check that accept the same "key" multiple times:

https://test.httpapi.com/api/domains/available.json?auth-userid=0&auth-password=password&domain-name=domain1&domain-name=domain2&tlds=com&tlds=net

This module accepts a hash where the key is the name of the argument (such as domain-name) and the value is an array of values you wish to pass:

    $logic_boxes->domains__available({
        'domain-name' 	=> ["google", "cnn"],
        'tlds'		=> ["com","net"]
    });

This is interpreted for you automagically into the repeating elements when the API's URI is built.

=head2 Array of Numbered Elements

For methods such as contacts__set_details that accep the same key multiple times except an incrementing digit is appended:

https://test.httpapi.com/api/contacts/set-details.json?auth-userid=0&auth-password=password&contact-id=0&attr-name1=sponsor1&attr-value1=0&product-key=dotcoop

This module still accepts a hash and leaves it to the developer to handle the appending of the incrementing digit to the keys of the hash:

    $logic_boxes->contacts__set_details({
        'contact-id'	=> 1337,
        'attr-name1'	=> 'sponsor',
        'attr-value1'	=> '0',
        'attr-name2'	=> 'CPR',
        'attr-value2'	=> 'COO',
        'product-key'	=> 'dotcoop'
    });

In this way you are able to overcome the need for unique keys and still pass the needed values onto LogicBoxes' API.

=head1 AUTHORS

Robert Stone, C<< <drzigman AT cpan DOT org > >>

=head1 ACKNOWLEDGMENTS

Thanks to Richard Simoes for his assistance in putting this module together and for writing the WWW::eNom module that much of this is based on.  Also thanks to HostGator.com for funding the development of this module and providing test resources.

=head1 COPYRIGHT & LICENSE

Copyright 2012 Robert Stone
This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU Lesser General Public License as published by the Free Software Foundation; or any compatible license.

See http://dev.perl.org/licenses/ for more information.
