package WWW::LogicBoxes::Role::Command::Raw;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( HashRef Str );

use HTTP::Tiny;
use URI::Escape qw( uri_escape );
use XML::LibXML::Simple qw(XMLin);
use Carp;

requires 'username', 'password', 'api_key', '_base_uri', 'response_type';

# VERSION
# ABSTRACT: Construct Methods For Making Raw LogicBoxes Requests

use Readonly;
# Create methods to support LogicBoxes API as of 2012-03-02
Readonly our $API_METHODS => {
    domains => {
        GET => [
            qw(available suggest-names validate-transfer search customer-default-ns orderid details details-by-name locks tel/cth-details)
        ],
        POST => [
            qw(register transfer eu/transfer eu/trade uk/transfer renew modify-ns add-cns modify-cns-name modify-cns-ip delete-cns-ip modify-contact modify-privacy-protection modify-auth-code enable-theft-protection disable-theft-protection tel/modify-whois-pref resend-rfa uk/release cancel-transfer delete restore de/recheck-ns dotxxx/assoication-details)
        ],
    },
    contacts => {
        GET  => [qw(details search sponsors dotca/registrantagreement)],
        POST => [qw(add modify default set-details delete coop/add-sponsor)],
    },
    customers => {
        GET =>
          [qw(details details-by-id generate-token authenticate-token search)],
        POST => [qw(signup modify change-password delete)],
    },
    resellers => {
        GET => [
            qw(details generate-token authenticate-token promo-details temp-password search)
        ],
        POST => [qw(signup modify-details)],
    },
    products => {
        GET => [
            qw(availability details plan-details customer-price reseller-price reseller-cost-price)
        ],
        POST => [qw(category-keys-mapping move)],
    },
    webservices => {
        GET => [
            qw(details active-plan-categories mock/products/reseller-price orderid search modify-pricing)
        ],
        POST => [qw(add renew modify enable-ssl enable-maintenance delete)],
    },
    multidomainhosting => {
        GET  => [qw(details orderid search modify-pricing)],
        POST => [qw(add renew modify enable-ssl delete)],
    },
    'multidomainhosting/windows' => {
        GET  => [qw(details orderid search modify-pricing)],
        POST => [qw(add renew modify enable-ssl delete)],
    },
    resellerhosting => {
        GET  => [qw(details orderid search modify-pricing)],
        POST => [
            qw(add renew modify add-dedicated-ip delete-dedicated-ip delete generate-license-key)
        ],
    },
    mail => {
        GET  => [qw(user mailinglists)],
        POST => [qw(activate)],
    },
    'mail/user' => {
        GET  => [qw(authenticate)],
        POST => [
            qw(add add-forward-only-account modify suspend unsuspend change-password reset-password update-autoresponder delete add-admin-forwards delete-admin-forwards add-user-forwards delete-user-forwards)
        ],
    },
    'mail/users' => {
        GET  => [qw(search)],
        POST => [qw(suspend unsuspend delete)],
    },
    'mail/domain' => {
        GET  => [qw(is-owernship-verified catchall dns-records)],
        POST => [
            qw(add-alias delete-alias update-notification-email active-catchall deactivate-catchall)
        ],
    },
    'mail/mailinglist' => {
        GET  => [qw(subscribers)],
        POST => [
            qw(add update add-subscribers delete-subscribers delete add-moderators delete-moderators)
        ],
    },
    dns => {
        GET  => [],
        POST => [qw(activate)],
    },
    'dns/manage' => {
        GET  => [qw(search-records delete-record)],
        POST => [
            qw(add-ipv4-record add-ipv6-record add-cname-record add-mx-record add-ns-record add-txt-record add-srv-record update-ipv4-record update-ipv6-record update-cname-record update-mx-record update-ns-record update-txt-record update-srv-record update-soa-record delete-ipv4-record delete-ipv6-record delete-cname-record delete-mx-record delete-ns-record delete-txt-record delete-srv-record)
        ],
    },
    domainforward => {
        GET  => [qw(details dns-records)],
        POST => [qw(activate manage)],
    },
    digitalcertificate => {
        GET => [qw(check-status details search orderid)],
        POST =>
          [qw(add cancel delete enroll-for-thawtecertificate reissue renew)],
    },
    billing => {
        GET => [
            qw(customer-transactions reseller-transactions customer-greedy-transactions reseller-greedy-transactions customer-balance customer-transactions/search reseller-transactions/search customer-archived-transactions/search customer-balanced-transactions reseller-balance)
        ],
        POST => [
            qw(customer-pay execute-order-without-payment add-customer-fund add-reseller-fund add-customer-debit-note add-reseller-debit-note add-customer-misc-invoice add-reseller-misc-invoice)
        ],
    },
    orders => {
        GET  => [qw()],
        POST => [qw(suspend unsuspend)],
    },
    actions => {
        GET  => [qw(search-current search-archived)],
        POST => [qw()],
    },
    commons => {
        GET  => [qw(legal-agreements)],
        POST => [qw()],
    },
    pg => {
        GET => [
            qw(allowedlist-for-customer list-for-reseller customer-transactions)
        ],
        POST => [qw()],
    },
};

has api_methods => (
    is       => 'ro',
    isa      => HashRef,
    default  => sub { $API_METHODS },
    init_arg => undef,
);

sub BUILD {
    my $self = shift;

    $self->install_methods();
}

sub install_methods {
    my $self = shift;

    my $ua = HTTP::Tiny->new;
    for my $api_class ( keys $self->api_methods ) {
        for my $http_method ( keys $self->api_methods->{ $api_class } ) {
            for my $api_method (@{ $self->api_methods->{ $api_class }{ $http_method } }) {
                my $method_name = $api_class . '__' . $api_method;

                $method_name =~ s|-|_|g;
                $method_name =~ s|/|__|g;

                $self->meta->add_method(
                    $method_name => sub {
                        my $self = shift;
                        my $args = shift;

                        if( !grep { $_ eq $http_method } qw( GET POST ) ) {
                            croak 'Unable to determine if this is a GET or POST request';
                        }

                        my $uri = $self->_make_query_string(
                            api_class  => $api_class,
                            api_method => $api_method,
                            params     => $args,
                        );

                        ### Method Name: ( $method_name )
                        ### HTTP Method: ( $http_method )
                        ### URI: ( $uri )

                        my $response = $ua->request( $http_method, $uri );
                        if ( $self->response_type eq "xml_simple" ) {
                            return XMLin( $response->{content} );
                        }
                        else {
                            return $response->{content};
                        }
                    }
                );
            }
        }
    }
}

sub _make_query_string {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        api_class  => { isa => Str },
        api_method => { isa => Str },
        params     => { isa => HashRef },
    );

    my $api_class = $args{api_class};
    $api_class =~ s/_/-/g;
    $api_class =~ s/__/\//g;

    my $api_method = $args{api_method};
    $api_method =~ s/_/-/g;
    $api_method =~ s/__/\//g;

    my $response_type = ( $self->response_type eq 'xml_simple' ) ? 'xml' : $self->response_type;

    my $query_uri = sprintf('%s/api/%s/%s.%s?auth-userid=%s',
        $self->_base_uri, $api_class, $api_method, $response_type, uri_escape( $self->username ) );

    if( $self->has_password ) {
      $query_uri .= "&auth-password=" . uri_escape( $self->password )
    }
    elsif($self->has_api_key) {
      $query_uri .= "&api-key=" . uri_escape( $self->apikey )
    }
    else {
        croak 'Unable to construct query string without a password or api_key';
    }

    $query_uri .= $self->_construct_get_args( $args{params} );

    return $query_uri;
}

sub _construct_get_args {
    my $self = shift;
    my ( $params ) = pos_validated_list( \@_, { isa => HashRef } );

    my $get_args;
    for my $param_name ( keys $params ) {
        if( ref $params->{ $param_name } eq 'ARRAY' ) {
            for my $param_value (@{ $params->{ $param_name } }) {
                $get_args .= sprintf('&%s=%s', uri_escape( $param_name ), uri_escape( $param_value ) );
            }
        }
        else {
            $get_args .= sprintf('&%s=%s', uri_escape( $param_name ), uri_escape( $params->{ $param_name } ) );
        }
    }

    return $get_args;
}

1;
