package WWW::LogicBoxes::Role::Command::Customer;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;
use Smart::Comments -ENV;

use Carp;

use WWW::LogicBoxes::Customer;

requires 'submit';

# VERSION
# ABSTRACT: Customer API Calls

=head1 NAME

WWW::LogicBoxes::Role::Command::Customer

=head1 SYNOPSIS

    use strict;
    use warnings;

    use WWW::LogicBoxes;
    use WWW::LogicBoxes::Customer;

    my $api = WWW::LogicBoxes->new({
        username => '123456',
        password => 'Top Secret!',
    });

    my $customer = WWW::LogicBoxes::Customer->new({
        name => 'Iam A. Test',
    });

    my $created_customer = $api->create_customer({ customer => $customer });

    print "Customer ID: " . $created_customer->id . "\n";

=head1 METHODS

=head2 create_customer
    my $api      = WWW::LogicBoxes->new({ ... });
    my $customer = WWW::LogicBoxes::Customer->new({ ... });

    my $created_customer = $api->create_customer({ customer => $customer });

Creates a customer given a WWW::LogicBoxes::Customer object.

This method will set the id attribute of $customer that was provided as an argument,
in addition to returning an instance of WWW::LogicBoxes::Customer.

=cut

sub create_customer {
    my $self = shift;
    my (%args) = validated_hash(
        \@_,
        customer => { isa => 'WWW::LogicBoxes::Customer' },
    );

    if( $args{customer}->has_id ) {
        croak "Customer already exists (is has an id)";
    }

    if( !$args{customer}->has_password ) {
        croak "A password must be specified";
    }

    my $response = $self->submit({
        method => 'customers__signup',
        params => {
            username => $args{customer}->username,
            passwd   => $args{customer}->password,
            name     => $args{customer}->name,
            company  => $args{customer}->company,

            'address-line-1' => $args{customer}->address1,
            ( $args{customer}->has_address2 ) ? ( 'address-line-2' => $args{customer}->address2 ) : ( ),
            ( $args{customer}->has_address3 ) ? ( 'address-line-3' => $args{customer}->address3 ) : ( ),
            city          => $args{customer}->city,
            ( $args{customer}->has_state )
                ? ( state => $args{customer}->state )
                : ( state => 'Not Applicable', 'other-state' => ''),
            country       => $args{customer}->country,
            zipcode       => $args{customer}->zipcode,

            'phone-cc'    => $args{customer}->phone_number->country_code,
            phone         => ($args{customer}->phone_number->areacode // '')
                . $args{customer}->phone_number->subscriber,
            ($args{customer}->has_fax_number) ?
                (   'fax-cc'      => $args{customer}->fax_number->country_code,
                    fax           => ($args{customer}->fax_number->areacode // '')
                        . $args{customer}->fax_number->subscriber,
                ) : (),
            ($args{customer}->has_alt_phone_number) ?
                (   'alt-phone-cc'      => $args{customer}->alt_phone_number->country_code,
                    'alt-phone'         => ($args{customer}->alt_phone_number->areacode // '')
                        . $args{customer}->alt_phone_number->subscriber,
                ) : (),
            ($args{customer}->has_mobile_phone_number) ?
                (   'mobile-cc'      => $args{customer}->mobile_phone_number->country_code,
                    'mobile'         => ($args{customer}->mobile_phone_number->areacode // '')
                        . $args{customer}->mobile_phone_number->subscriber,
                ) : (),

            'lang-pref'   => $args{customer}->language_preference,
        },
    });

    $args{customer}->id($response->{id});

    return $args{customer};
}

=head2 get_customer_by_username

    my $api = WWW::LogicBoxes->new({ ... });
    my $customer = $api->get_customer_by_username('drzigman@cpan.org');

    print "Customer Phone Number is: " . $customer->phone_number->format . "\n";

Performs a search with LogicBoxes for a WWW::LogicBoxes::Customer object with the specified
username.  I<NOTE> that usernames are email addresses.

Returned is a fully formed WWW::LogicBoxes::Customer object

=cut

sub get_customer_by_username {
    my $self     = shift;
    my $username = shift;

    if(!defined $username) {
        croak "An email address username must be specified";
    }

    my $response = $self->submit({
        method => 'customers__details',
        params => {
            'username' => $username,
        }
    });

    return $self->_construct_customer_from_response($response);

}

=head2 get_customer_by_id

    my $api = WWW::LogicBoxes->new({ ... });
    my $customer = $api->get_customer_by_id(42);

    print "Customer Phone Number is: " . $customer->phone_number->format . "\n";

Performs a search with LogicBoxes for a WWW::LogicBoxes::Customer object with the specified
id.

Returned is a fully formed WWW::LogicBoxes::Customer object

=cut

sub get_customer_by_id {
    my $self        = shift;
    my $customer_id = shift;

    if(!defined $customer_id || !($customer_id =~ m/^\d+$/) ) {
        croak "A numeric customer id must be specified";
    }

    my $response = $self->submit({
        method => 'customers__details_by_id',
        params => {
            'customer-id' => $customer_id,
        }
    });

    return $self->_construct_customer_from_response($response);
}

sub _construct_customer_from_response {
    my $self     = shift;
    my $response = shift;

    if(!defined $response) {
        return;
    }

    my $customer = WWW::LogicBoxes::Customer->new({
        id       => $response->{customerid},
        username => $response->{username},
        name     => $response->{name},
        company  => $response->{company},
        address1 => $response->{address1},
        ( exists $response->{address2} ) ? ( address2 => $response->{address2} ) : ( ),
        ( exists $response->{address3} ) ? ( address3 => $response->{address3} ) : ( ),
        city     => $response->{city},
        state    => $response->{state},
        country  => $response->{country},
        zipcode  => $response->{zip},

        phone_number => ( $response->{telnocc} . $response->{telno} ),
        ( exists $response->{faxnocc} )
            ? ( fax_number => ( $response->{faxnocc} . $response->{faxno} ) )
            : ( ),
        ( exists $response->{mobilenocc} )
            ? ( mobile_phone_number => ( $response->{mobilenocc} . $response->{mobileno} ) )
            : ( ),
        ( exists $response->{alttelnocc} )
            ? ( alt_phone_number => ( $response->{alttelnocc} . $response->{alttelno} ) )
            : ( ),

        language_preference => $response->{langpref},
    });

    return $customer;
}

1;
