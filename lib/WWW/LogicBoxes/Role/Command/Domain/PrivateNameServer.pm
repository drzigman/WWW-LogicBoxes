package WWW::LogicBoxes::Role::Command::Domain::PrivateNameServer;

use strict;
use warnings;

use Moose::Role;
use MooseX::Params::Validate;

use WWW::LogicBoxes::Types qw( DomainName Int IPv4 PrivateNameServer );

use WWW::LogicBoxes::PrivateNameServer;

use Try::Tiny;
use Carp;

requires 'submit', 'get_domain_by_id';

# VERSION
# ABSTRACT: Domain Private Nameserver API Calls

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

sub modify_private_nameserver_ip {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        domain_id => { isa => Int },
        name      => { isa => DomainName },
        old_ip    => { isa => IPv4 },
        new_ip    => { isa => IPv4 },
    );

    return try {
        my $response = $self->submit({
            method => 'domains__modify_cns_ip',
            params => {
                'order-id' => $args{domain_id},
                'cns'      => $args{name},
                'old-ip'   => $args{old_ip},
                'new-ip'   => $args{new_ip},
            }
        });

        return $self->get_domain_by_id( $args{domain_id} );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }
        elsif( $_ =~ m/^Invalid Child Name Server. Its not registered nameserver for this domain/ ) {
            croak 'No such existing private nameserver';
        }
        elsif( $_ =~ m/^Same value for new and old IpAddress/ ) {
            croak 'Same value for old and new private nameserver ip';
        }
        elsif( $_ =~ m/^Invalid Old IpAddress. Its not attached to Nameserver/ ) {
            croak 'Nameserver does not have specified ip';
        }

        croak $_;
    };
}

sub delete_private_nameserver_ip {
    my $self = shift;
    my ( %args ) = validated_hash(
        \@_,
        domain_id => { isa => Int },
        name      => { isa => DomainName },
        ip        => { isa => IPv4 },
    );

    return try {
        my $response = $self->submit({
            method => 'domains__delete_cns_ip',
            params => {
                'order-id' => $args{domain_id},
                'cns'      => $args{name},
                'ip'       => $args{ip},
            }
        });

        return $self->get_domain_by_id( $args{domain_id} );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }
        elsif( $_ =~ m/^Invalid Child Name Server. Its not registered nameserver for this domain/ ) {
            croak 'No such existing private nameserver';
        }
        elsif( $_ =~ m/^\{ipaddress1=Invalid IpAddress .* Its not attached to Nameserver\}/ ) {
            croak 'IP address not assigned to private nameserver';
        }

        croak $_;
    };
}

sub delete_private_nameserver {
    my $self = shift;
    my ( $nameserver ) = pos_validated_list( \@_, { isa => PrivateNameServer, coerce => 1 } );

    return try {
        for my $ip (@{ $nameserver->ips } ) {
            $self->delete_private_nameserver_ip(
                domain_id => $nameserver->domain_id,
                name      => $nameserver->name,
                ip        => $ip,
            );
        }

        return $self->get_domain_by_id( $nameserver->domain_id );
    }
    catch {
        if( $_ =~ m/^No Entity found for Entityid/ ) {
            croak 'No such domain';
        }

        croak $_;
    };
}

1;
