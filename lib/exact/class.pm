package exact::class;
# ABSTRACT: Simple class interface extension for exact

use 5.014;
use exact;
use Role::Tiny ();
use Scalar::Util;

# VERSION

my $store = '::____exact_class';

sub import {
    my ( $self, $caller ) = @_;
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
    $_->$cb(@_) for $self;
    return $self;
}

sub attr {
    my ( $self, $attrs, $value ) = @_;
    my $caller = ref($self) || $self;

    for my $name ( ( ref $attrs ) ? @$attrs : $attrs ) {
        my $accessor = sub {
            my ( $self, $value ) = @_;

            if ( @_ > 1 ) {
                $self->{$name} = $value;
                return $self;
            }
            else {
                return $self->{$name};
            }
        };

        {
            no strict 'refs';
            no warnings 'redefine';

            *{ $caller . '::' . $name } = $accessor;

            if ( ref $self ) {
                $self->$name($value) if ( @_ > 2 );
            }
            else {
                ${ $caller . $store }->{value}{$name} = $value if ( @_ > 2 );
                ${ $caller . $store }->{name}{$name}  = 1;
                ${ $caller . $store }->{has}{$name}   = 1;
            }
        }
    }
}

sub class_has {
    my ( $attrs, $value ) = @_;
    my $caller = caller();

    for my $name ( ( ref $attrs ) ? @$attrs : $attrs ) {
        no strict 'refs';
        croak "$name already defined" if ( exists ${ $caller . $store }->{name}{$name} );

        *{ $caller . '::' . $name } = sub {
            my ( $self, $value ) = @_;

            if ( @_ > 1 ) {
                ${ $caller . $store }->{value}{$name} = $value;
                return $self;
            }
            else {
                return ${ $caller . $store }->{value}{$name};
            }
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

        *{ $caller . '::' . $name } = sub {
            my ( $self, $value ) = @_;

            if ( @_ > 1 ) {
                ${ $caller . $store }->{value}{$name} = $value;
                return $self;
            }
            else {
                return ${ $caller . $store }->{value}{$name};
            }
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

=for test_synopsis
no strict 'subs'

package Cat;
use exact class;

# ...or if you want to use it directly (which will also use exact):
# use exact::class;

has name => 'Unnamed';
has ['age', 'weight'] => 4;

package AttackCat;
use exact class;
use parent 'Cat';

has attack => 4;
has thac0  => -3;

class_has hp => 42;

with 'Attack';

package main;
use exact;

my $cat = Cat->new( name => 'Hamlet' );
say $cat->age;
say $cat->age(3)->weight(5)->age;

my $demon = AttackCat->new( attack => 5, hp => 1138 );
say $demon->tap( sub { $_->thac0(-4) } )->hp;

$demon->attr( new_attribute => 1024 );
say $demon->new_attribute;

my $devil = AttackCat->with_roles('+Claw')->new;

=head1 DESCRIPTION

L<exact::class> is intended to be a simple class interface extension for
L<exact>. See the L<exact> documentation for additional informatioh about
extensions. The intended use of L<exact::class> is via the extension interface
of L<exact>.

    use exact class, conf, noutf8;

However, you can also use it directly, which will also use L<exact> with
default options:

    use exact::class;

Doing either of these will setup your namespace with some methods to make it
easier to use it as a class with a fluent OO interface. Fluent OO interfaces
are a way to design object-oriented APIs around method chaining to create
domain-specific languages, with the goal of making the readablity of the source
code close to written prose.

All attribute accessors created with "has" (or "attr") or "class_has" will
return their invocant whenever they are used to assign a new attribute value.

The interface and much of the code is highly influenced (i.e. plagiarized) from
the excellent L<Mojo::Base> and L<Role::Tiny>.

=head1 FUNCTIONS

L<exact::class> implements the following functions:

=head2 has

Create attributes and associated accessors for hash-based objects.

    has 'name';
    has [ 'name1', 'name2', 'name3' ];
    has name4 => undef;
    has name5 => 'foo';
    has name6 => sub {...};
    has [ 'name7', 'name8', 'name9' ]    => 'foo';
    has [ 'name10', 'name11', 'name12' ] => sub {...};

Then whenever you have an object:

    $object->name('Set This Name'); # returns $object
    say $object->name               # returns 'Set This Name'

=head2 class_has

Exactly the same as C<has> except attributes are assigned to the class, not to
the object. Thus, any time you change a C<class_has> value, it changes across
all objects of that class, both present and future instantiated.

=head2 with

    with 'Some::Role1';
    with qw( Some::Role1 Some::Role2 );

Composes a role into the current space via L<Role::Tiny::With>.

If you have conflicts and want to resolve them in favor of Some::Role1, you can
instead write:

    with 'Some::Role1';
    with 'Some::Role2';

You will almost certainly want to read the documentation for L<exact::role> for
writing roles.

=head1 METHODS

L<exact::class> implements the following methods:

=head2 new

    my $object = SubClass->new;
    my $object = SubClass->new( name => 'value' );
    my $object = SubClass->new( { name => 'value' } );

A basic constructor for hash-based objects. You can pass it either a hash or a
hash reference with attribute values.

=head2 attr

    $object->attr('name');
    SubClass->attr('name');
    SubClass->attr( [ 'name1', 'name2', 'name3' ] );
    SubClass->attr( name => 'foo' );
    SubClass->attr( name => sub {...} );
    SubClass->attr( [ 'name1', 'name2', 'name3' ] => 'foo' );
    SubClass->attr( [ 'name1', 'name2', 'name3' ] => sub {...} );
    SubClass->attr( name => sub {...} );
    SubClass->attr( name => undef );
    SubClass->attr( [ 'name1', 'name2', 'name3' ] => sub {...} );

Create attribute accessors for hash-based objects, an array reference can be
used to create more than one at a time. Pass an optional second argument to set
a default value, it should be a constant or a callback. The callback will be
executed at accessor read time if there's no set value, and gets passed the
current instance of the object as first argument. Accessors can be chained, that
means they return their invocant when they are called with an argument.

=head2 tap

    $object = $object->tap( sub {...} );
    $object = $object->tap('some_method');
    $object = $object->tap( 'some_method', @args );

Tap into a method chain to perform operations on an object within the chain
(also known as a K combinator or Kestrel). The object will be the first argument
passed to the callback, and is also available as C<$_>. The callback's return
value will be ignored; instead, the object (the callback's first argument) will
be the return value. In this way, arbitrary code can be used within (i.e.,
spliced or tapped into) a chained set of object method calls.

    # longer version
    $object = $object->tap( sub { $_->some_method(@args) } );

    # inject side effects into a method chain
    $object->foo('A')->tap( sub { say $_->foo } )->foo('B');

=head2 with_roles

    my $new_class = SubClass->with_roles('SubClass::Role::One');
    my $new_class = SubClass->with_roles( '+One', '+Two' );
    $object       = $object->with_roles( '+One', '+Two' );

Create a new class with one or more L<Role::Tiny> roles. If called on a class
returns the new class, or if called on an object reblesses the object into the
new class. For roles following the naming scheme "MyClass::Role::RoleName" you
can use the shorthand "+RoleName".

    # create a new class with the role "SubClass::Role::Foo" and instantiate it
    my $new_class = SubClass->with_roles('+Foo');
    my $object    = $new_class->new;

You will almost certainly want to read the documentation for L<exact::role> for
writing roles.

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
