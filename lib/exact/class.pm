package exact::class;
# ABSTRACT: Simple class interface extension for exact

use 5.014;
use exact;
use Role::Tiny ();
use Scalar::Util;

# VERSION

my $store = '::____exact_class';

sub import {
    my ( $self, $caller, $params ) = @_;
    $caller //= caller();

    my @methods = qw( new tap attr class_has has with_roles with );
    {
        no strict 'refs';
        for (@methods) {
            *{ $caller . '::' . $_ } = \&$_ unless ( defined &{ $caller . '::' . $_ } );
        }
        *{ $caller . $store } = {};
    }

    exact->autoclean( -except => [@methods] );
}

sub new {
    my $class = shift;
    my $self  = bless( @_ ? @_ > 1 ? {@_} : { %{ $_[0] } } : {}, ref $class || $class );

    my $data;
    {
        no strict 'refs';
        $data = ${ ref($self) . $store };
    }

    if ( ref $data eq 'HASH' ) {
        for my $name ( keys %{ $data->{has} } ) {
            if ( exists $data->{value}{$name} ) {
                $self->attr( $name, $data->{value}{$name} );
            }
            else {
                $self->attr($name);
            }
        }
    }

    return $self;
}

sub tap {
    my ( $self, $cb ) = ( shift, shift );
    $self->$cb(@_);
    return $self;
}

sub attr {
    my ( $self, $attrs, $value ) = @_;

    for my $name ( ( ref $attrs ) ? @$attrs : $attrs ) {
        my $accessor = sub {
            my ( $self, $value ) = @_;
            return ( @_ > 1 ) ? ( $self->{$name} = $value ) : $self->{$name};
        };

        {
            no strict 'refs';
            no warnings 'redefine';
            *{ ref($self) . '::' . $name } = $accessor;
        }

        $self->$name($value) if ( @_ > 2 );
    }
}

sub class_has {
    my ( $attrs, $value ) = @_;
    my $caller = caller();

    for my $name ( ( ref $attrs ) ? @$attrs : $attrs ) {
        no strict 'refs';
        croak "$name already defined" if ( exists ${ $caller . $store }->{name}{$name} );

        *{ caller() . '::' . $name } = sub {
            my ( $self, $value ) = @_;
            return ( @_ > 1 )
                ? ( ${ $caller . $store }->{value}{$name} = $value )
                : ${ $caller . $store }->{value}{$name};
        };

        ${ $caller . $store }->{value}{$name} = $value if ( @_ > 1 );
        ${ $caller . $store }->{name}{$name}  = 1;
    }
}

sub has {
    my ( $attrs, $value ) = @_;
    my $caller = caller();

    for my $name ( ( ref $attrs ) ? @$attrs : $attrs ) {
        no strict 'refs';
        croak "$name already defined" if ( exists ${ $caller . $store }->{name}{$name} );

        *{ caller() . '::' . $name } = sub {
            my ( $self, $value ) = @_;
            return ( @_ > 1 )
                ? ( ${ $caller . $store }->{value}{$name} = $value )
                : ${ $caller . $store }->{value}{$name};
        };

        ${ $caller . $store }->{value}{$name} = $value if ( @_ > 1 );
        ${ $caller . $store }->{name}{$name}  = 1;
        ${ $caller . $store }->{has}{$name}   = 1;
    }
}

sub with {
    return Role::Tiny->apply_roles_to_package( scalar(caller), @_ );
}

sub with_roles {
    my ( $self, @roles ) = @_;

    return Role::Tiny->create_class_with_roles(
        $self,
        map { /^\+(.+)$/ ? "${self}::Role::$1" : $_ } @roles
    ) unless ( my $class = Scalar::Util::blessed $self );

    return Role::Tiny->apply_roles_to_object(
        $self,
        map { /^\+(.+)$/ ? "${class}::Role::$1" : $_ } @roles
    );
}

1;
__END__
=pod

=begin :badges

=for markdown
[![Build Status](https://travis-ci.org/gryphonshafer/exact-class.svg)](https://travis-ci.org/gryphonshafer/exact-class)
[![Coverage Status](https://coveralls.io/repos/gryphonshafer/exact-class/badge.png)](https://coveralls.io/r/gryphonshafer/exact-class)

=end :badges

=head1 SYNOPSIS

    use exact class;

=head1 DESCRIPTION

L<exact::class> is a...

=head1 SEE ALSO

You can look for additional information at:

=for :list
* L<GitHub|https://github.com/gryphonshafer/exact-class>
* L<CPAN|http://search.cpan.org/dist/exact-class>
* L<MetaCPAN|https://metacpan.org/pod/exact::class>
* L<AnnoCPAN|http://annocpan.org/dist/exact-class>
* L<Travis CI|https://travis-ci.org/gryphonshafer/exact-class>
* L<Coveralls|https://coveralls.io/r/gryphonshafer/exact-class>
* L<CPANTS|http://cpants.cpanauthors.org/dist/exact-class>
* L<CPAN Testers|http://www.cpantesters.org/distro/D/exact-class.html>

=cut
