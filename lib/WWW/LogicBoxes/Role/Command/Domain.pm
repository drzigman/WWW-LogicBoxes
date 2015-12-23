package WWW::LogicBoxes::Role::Command::Domain;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( Bool DomainName DomainNames Int PrivateNameServer Str );

use WWW::LogicBoxes::Domain;
use WWW::LogicBoxes::PrivateNameServer;

use Try::Tiny;
use Carp;

use Readonly;
Readonly my $DOMAIN_DETAIL_OPTIONS => [qw( All )];

requires 'submit';

# VERSION
# ABSTRACT: Domain API Calls

sub get_domain_by_id {
    my $self = shift;
    my ( $domain_id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'domains__details',
            params => {
                'order-id' => $domain_id,
                'options'  => $DOMAIN_DETAIL_OPTIONS,
            }
        });

        return WWW::LogicBoxes::Domain->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            return;
        }

        croak $_;
    };
}

sub get_domain_by_name {
    my $self = shift;
    my ( $domain_name ) = pos_validated_list( \@_, { isa => DomainName } );

    return try {
        my $response = $self->submit({
            method => 'domains__details_by_name',
            params => {
                'domain-name' => $domain_name,
                'options'     => $DOMAIN_DETAIL_OPTIONS,
            }
        });

        return WWW::LogicBoxes::Domain->construct_from_response( $response );
    }
    catch {
        if( $_ =~ m/^Website doesn't exist for/ ) {
            return;
        }

        croak $_;
    };
}

sub update_domain_contacts {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        id                    => { isa => Int },
        registrant_contact_id => { isa => Int, optional => 1 },
        admin_contact_id      => { isa => Int, optional => 1 },
        technical_contact_id  => { isa => Int, optional => 1 },
        billing_contact_id    => { isa => Int, optional => 1 },
    );

    return try {
        my $original_domain = $self->get_domain_by_id( $args{id} );

        if( !$original_domain ) {
            croak 'No such domain exists';
        }

        my $contact_mapping = {
            registrant_contact_id => 'reg-contact-id',
            admin_contact_id      => 'admin-contact-id',
            technical_contact_id  => 'tech-contact-id',
            billing_contact_id    => 'billing-contact-id',
        };

        my $num_changes = 0;
        my $contacts_to_update;
        for my $contact_type ( keys $contact_mapping ) {
            if( $args{$contact_type} && $args{$contact_type} != $original_domain->$contact_type ) {
                $contacts_to_update->{ $contact_mapping->{ $contact_type } } = $args{ $contact_type };
                $num_changes++;
            }
            else {
                $contacts_to_update->{ $contact_mapping->{ $contact_type } } = $original_domain->$contact_type;
            }
        }

        if( $num_changes == 0 ) {
            return $original_domain;
        }

        my $response = $self->submit({
            method => 'domains__modify_contact',
            params => {
                'order-id'    => $args{id},
                %{ $contacts_to_update }
            }
        });

        return $self->get_domain_by_id( $args{id} );
    }
    catch {
        if( $_ =~ m/{registrantcontactid=registrantcontactid is invalid}/ ) {
            croak 'Invalid registrant_contact_id specified';
        }
        elsif( $_ =~ m/{admincontactid=admincontactid is invalid}/ ) {
            croak 'Invalid admin_contact_id specified';
        }
        elsif( $_ =~ m/{techcontactid=techcontactid is invalid}/ ) {
            croak 'Invalid technical_contact_id specified';
        }
        elsif( $_ =~ m/{billingcontactid=billingcontactid is invalid}/ ) {
            croak 'Invalid billing_contact_id specified';
        }

        croak $_;
    };
}

sub enable_domain_lock_by_id {
    my $self = shift;
    my ( $domain_id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'domains__enable_theft_protection',
            params => {
                'order-id' => $domain_id,
            }
        });

        return $self->get_domain_by_id( $domain_id );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }

        croak $_;
    };
}

sub disable_domain_lock_by_id {
    my $self = shift;
    my ( $domain_id ) = pos_validated_list( \@_, { isa => Int } );

    return try {
        my $response = $self->submit({
            method => 'domains__disable_theft_protection',
            params => {
                'order-id' => $domain_id,
            }
        });

        return $self->get_domain_by_id( $domain_id );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }

        croak $_;
    };
}

sub enable_domain_privacy {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        id     => { isa => Int },
        reason => { isa => Str, optional => 1 },
    );

    $args{reason} //= 'Enabling Domain Privacy';

    return $self->_set_domain_privacy(
        id     => $args{id},
        status => 1,
        reason => $args{reason},
    );
}

sub disable_domain_privacy {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        id     => { isa => Int },
        reason => { isa => Str, optional => 1 },
    );

    $args{reason} //= 'Disabling Domain Privacy';

    return try {
        return $self->_set_domain_privacy(
            id     => $args{id},
            status => 0,
            reason => $args{reason},
        );
    }
    catch {
        if( $_ =~ m/^Privacy Protection not Purchased/ ) {
            return $self->get_domain_by_id( $args{id} );
        }

        croak $_;
    };
}

sub _set_domain_privacy {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        id     => { isa => Int },
        status => { isa => Bool },
        reason => { isa => Str },
    );

    return try {
        my $response = $self->submit({
            method => 'domains__modify_privacy_protection',
            params => {
                'order-id'        => $args{id},
                'protect-privacy' => $args{status} ? 'true' : 'false',
                'reason'          => $args{reason},
            }
        });

        return $self->get_domain_by_id( $args{id} );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }

        croak $_;
    };
}

sub update_domain_nameservers {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        id          => { isa => Int },
        nameservers => { isa => DomainNames },
    );

    return try {
        my $response = $self->submit({
            method => 'domains__modify_ns',
            params => {
                'order-id' => $args{id},
                'ns'       => $args{nameservers},
            }
        });

        return $self->get_domain_by_id( $args{id} );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }
        elsif( $_ =~ m/is not a valid Nameserver/ ) {
            croak 'Invalid nameservers provided';
        }
        elsif( $_ =~ m/Same value for new and old NameServers/ ) {
            return $self->get_domain_by_id( $args{id} );
        }

        croak $_;
    };
}

sub create_private_nameserver {
    my $self = shift;
    my ( $nameserver ) = pos_validated_list( \@_, { isa => PrivateNameServer, coerce => 1 } );

    return try {
        my $response = $self->submit({
            method => 'domains__add_cns',
            params => {
                'order-id' => $nameserver->domain_id,
                'cns'      => $nameserver->name,
                'ip'       => $nameserver->ips,
            }
        });

        return $self->get_domain_by_id( $nameserver->domain_id );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }
        elsif( $_ =~ m/This IpAddress already exists/ ) {
            croak 'Nameserver with this IP Address already exists';
        }

        croak $_;
    };
}

sub rename_private_nameserver {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        domain_id => { isa => Int },
        old_name  => { isa => DomainName },
        new_name  => { isa => DomainName },
    );

    return try {
        my $response = $self->submit({
            method => 'domains__modify_cns_name',
            params => {
                'order-id' => $args{domain_id},
                'old-cns'  => $args{old_name},
                'new-cns'  => $args{new_name},
            }
        });

        return $self->get_domain_by_id( $args{domain_id} );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }
        elsif( $_ =~ m/^Invalid Old Child NameServer. Its not registered nameserver for this domain/ ) {
            croak 'No such existing private nameserver';
        }
        elsif( $_ =~ m/^Parent Domain for New child nameServer is not registered by us/
            || $_ =~ m/^\{hostname=Parent DomainName is not registered by you\}/ ) {
            croak 'Invalid domain for private nameserver';
        }
        elsif( $_ =~ m/^Same value for new and old Child NameServer/ ) {
            croak 'Same value for old and new private nameserver name';
        }
        elsif( $_ =~ m/^\{hostname=Child NameServer already exists\}/ ) {
            croak 'A nameserver with that name already exists';
        }

        croak $_;
    };
}

1;
