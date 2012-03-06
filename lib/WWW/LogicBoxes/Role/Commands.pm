package WWW::LogicBoxes::Role::Commands;

use v5.10;
use strict;
use warnings;
use utf8;

use Any::Moose "Role";
use HTTP::Tiny;
use English -no_match_vars;
use Carp qw(croak);
use Data::Dumper;

# VERSION

=begin Pod::Coverage

\w+

=end Pod::Coverage

=cut

# Create methods to support LogicBoxes API as of 2012-03-02
my %api_methods = (
	domains	=> {
		GET  => [qw(available suggest-names validate-transfer search customer-default-ns orderid details locks tel/cth-details)],
		POST => [qw(register transfer eu/transfer eu/trade uk/transfer renew modify-ns add-cns modify-cns-name modify-cns-ip delete-cns-ip modify-contact modify-privacy-protection modify-auth-code enable-theft-protection disable-theft-protection tel/modify-whois-pref resend-rfa uk/release cancel-transfer delete restore de/recheck-ns dotxxx/assoication-details)],
	},
	contacts => {
		GET  => [qw(details search sponsors dotca/registrantagreement)],
		POST =>	[qw(add modify default set-details delete coop/add-sponsor)],
	},
	customers => {
		GET  => [qw(details details-by-id generate-token authenticate-token search)],
		POST => [qw(signup modify change-password delete)],
	},
	resellers => {
		GET  => [qw(details generate-token authenticate-token promo-details temp-password search)],
		POST => [qw(signup modify-details)],
	},
	products => {
		GET  => [qw(availability details plan-details customer-price reseller-price reseller-cost-price)],
		POST => [qw(category-keys-mapping move)],
	},
	webservices => {
		GET  => [qw(details active-plan-categories mock/products/reseller-price orderid search modify-pricing)],
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
		POST => [qw(add renew modify add-dedicated-ip delete-dedicated-ip delete generate-license-key)],
	},
	mail =>	{
		GET  => [qw(user mailinglists)],
		POST => [qw(activate)],
	},
	'mail/user' => {
		GET  => [qw(authenticate)],
		POST => [qw(add add-forward-only-account modify suspend unsuspend change-password reset-password update-autoresponder delete add-admin-forwards delete-admin-forwards add-user-forwards delete-user-forwards)],
	},
	'mail/users' => {
		GET  => [qw(search)],
		POST => [qw(suspend unsuspend delete)],
	},
	'mail/domain' => {
		GET  => [qw(is-owernship-verified catchall dns-records)],
		POST => [qw(add-alias delete-alias update-notification-email active-catchall deactivate-catchall)],
	},
	'mail/mailinglist' => {
		GET  => [qw(subscribers)],
		POST => [qw(add update add-subscribers delete-subscribers delete add-moderators delete-moderators)],
	},
	dns => {
		GET  => [],
		POST => [qw(activate)],
	},
	'dns/manage' => {
		GET  => [qw(search-records delete-record)],
		POST => [qw(add-ipv4-record add-ipv6-record add-cname-record add-mx-record add-ns-record add-txt-record add-srv-record update-ipv4-record update-ipv6-record update-cname-record update-mx-record update-ns-record update-txt-record update-srv-record update-soa-record delete-ipv4-record delete-ipv6-record delete-cname-record delete-mx-record delete-ns-record delete-txt-record delete-srv-record)],
	},
	domainforward => {
		GET  => [qw(details dns-records)],
		POST => [qw(activate manage)],
	},
	digitalcertificate => {
		GET  => [qw(check-status details search orderid)],
		POST => [qw(add cancel delete enroll-for-thawtecertificate reissue renew)],
	},
	billing => {
		GET  => [qw(customer-transactions reseller-transactions customer-greedy-transactions reseller-greedy-transactions customer-balance customer-transactions/search reseller-transactions/search customer-archived-transactions/search customer-balanced-transactions reseller-balance)],
		POST => [qw(customer-pay execute-order-without-payment add-customer-fund add-reseller-fund add-customer-debit-note add-reseller-debit-note add-customer-misc-invoice add-reseller-misc-invoice)],
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
		GET  => [qw(allowedlist-for-customer list-for-reseller customer-transactions)],
		POST => [qw()],
	},
);

my $ua = HTTP::Tiny->new;
foreach my $api_class (keys %api_methods) {
	foreach my $web_method ( keys %{$api_methods{$api_class}}) {
		foreach my $api_method (@{$api_methods{$api_class}{$web_method}}) {
			my $sub_name = $api_class . "__" . $api_method;

			$sub_name =~ s(-)(_)g;
			$sub_name =~ s(/)(__)g;

			__PACKAGE__->meta->add_method (
				$sub_name => sub {
					my ($self, $args) = @ARG;

					$args->{api_class}  = $api_class;
					$args->{api_method} = $api_method;
					my $uri = $self->_make_query_string($args);

					$web_method ~~ [qw(GET POST)] or croak "I'm not sure if this is supposed to be a get or a post type request...";
					return $ua->request($web_method, $uri);
				}
			);
		}
	}
}

1;
