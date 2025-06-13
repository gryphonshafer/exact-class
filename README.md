# NAME

exact::class - Simple class interface extension for exact

# VERSION

version 1.20

[![test](https://github.com/gryphonshafer/exact-class/workflows/test/badge.svg)](https://github.com/gryphonshafer/exact-class/actions?query=workflow%3Atest)
[![codecov](https://codecov.io/gh/gryphonshafer/exact-class/graph/badge.svg)](https://codecov.io/gh/gryphonshafer/exact-class)

# SYNOPSIS

    package Cat;
    use exact -class;

    # ...or if you want to use it directly (which will also use exact):
    # use exact::class;

    has name => 'Unnamed';
    has ['age', 'weight'] => 4;

    # ...and just for this inline example we need:
    BEGIN { $INC{'Cat.pm'} = 1 }

    package AttackCat;
    use exact 'Cat';

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

# DESCRIPTION

[exact::class](https://metacpan.org/pod/exact%3A%3Aclass) is intended to be a simple class interface extension for
[exact](https://metacpan.org/pod/exact). See the [exact](https://metacpan.org/pod/exact) documentation for additional information about
extensions. The intended use of [exact::class](https://metacpan.org/pod/exact%3A%3Aclass) is via the extension interface
of [exact](https://metacpan.org/pod/exact).

    use exact -class, -conf, -noutf8;

However, you can also use it directly, which will also use [exact](https://metacpan.org/pod/exact) with
default options:

    use exact::class;

Doing either of these will setup your namespace with some methods to make it
easier to use it as a class with a fluent OO interface. Fluent OO interfaces
are a way to design object-oriented APIs around method chaining to create
domain-specific languages, with the goal of making the readablity of the source
code close to written prose.

## Subclasses

Note that [exact::class](https://metacpan.org/pod/exact%3A%3Aclass) will place itself as a parent to package in which it's
used. If you setup a subclass to your package, that subclass should not also
use [exact::class](https://metacpan.org/pod/exact%3A%3Aclass), or else you'll probably end up with an inheritance error.

## "Highly Influenced" Interface

The interface and much of the code is "highly influenced" (i.e. plagiarized)
from the excellent [Mojo::Base](https://metacpan.org/pod/Mojo%3A%3ABase) and [Role::Tiny](https://metacpan.org/pod/Role%3A%3ATiny). So much so that you can
replace:

    use Mojo::Base 'Mojolicious';
    use Role::Tiny::With;

...with:

    use exact -class, 'Mojolicious';

## Class::Method::Modifiers

Note that [Class::Method::Modifiers](https://metacpan.org/pod/Class%3A%3AMethod%3A%3AModifiers) is injected into the namespace to provide
support for: `before`, `around`, and `after`.

# FUNCTIONS

[exact::class](https://metacpan.org/pod/exact%3A%3Aclass) implements the following functions:

## has

Create attributes and associated accessors for hash-based objects.

    has 'name';
    has [ 'name1', 'name2', 'name3' ];
    has name4 => undef;
    has name5 => 'foo';
    has name6 => sub {...};
    has [ 'name7', 'name8', 'name9' ]    => 'foo';
    has [ 'name10', 'name11', 'name12' ] => sub {...};
    has name13 => \ sub {...};

Then whenever you have an object:

    $object->name('Set This Name'); # returns $object
    say $object->name               # returns 'Set This Name'

See also the ["attr"](#attr) section below.

## class\_has

Exactly the same as `has` except attributes are assigned to the class, not to
the object. Thus, any time you change a `class_has` value, it changes across
all objects of that class, both present and future instantiated.

## with

    with 'Some::Role1';
    with qw( Some::Role1 Some::Role2 );

Composes a role into the current space via [Role::Tiny::With](https://metacpan.org/pod/Role%3A%3ATiny%3A%3AWith).

If you have conflicts and want to resolve them in favor of Some::Role1, you can
instead write:

    with 'Some::Role1';
    with 'Some::Role2';

You will almost certainly want to read the documentation for [exact::role](https://metacpan.org/pod/exact%3A%3Arole) for
writing roles.

# METHODS

[exact::class](https://metacpan.org/pod/exact%3A%3Aclass) implements the following methods:

## new

    my $object = SubClass->new;
    my $object = SubClass->new( name => 'value' );
    my $object = SubClass->new( { name => 'value' } );

A basic constructor for hash-based objects. You can pass it either a hash or a
hash reference with attribute values.

## attr

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
    SubClass->attr( 'name13' => \ sub {...} );

Create attribute accessors for hash-based objects, an array reference can be
used to create more than one at a time. Pass an optional second argument to set
a default value, it should be a constant, a callback, or a reference to a
callback.

The direct callback will be executed at accessor read time if there's no set
value, and gets passed the current instance of the object as first argument.
Accessors can be chained, that means they return their invocant when they are
called with an argument.

### Code References

Code references will be called on first access and passed a copy of the object.
The return value of the code references will be saved in the attribute,
replacing the reference.

    package Cat;
    use exact -class;
    my $base = 41;
    has name6 => sub { return ++$base };

    package main;
    my $cat = Cat->new;
    say $cat->name6; # 42
    say $cat->name6; # 42

If you instead need a code reference stored permanently in an attribute, then
use a reference to a code reference:

    package Cat;
    use exact -class;
    my $base = 41;
    has name6 => \ sub { return ++$base };

    package main;
    my $cat = Cat->new;
    say $cat->name6->(); # 42
    say $cat->name6->(); # 43

## tap

    $object = $object->tap( sub {...} );
    $object = $object->tap('some_method');
    $object = $object->tap( 'some_method', @args );

Tap into a method chain to perform operations on an object within the chain
(also known as a K combinator or Kestrel). The object will be the first argument
passed to the callback, and is also available as `$_`. The callback's return
value will be ignored; instead, the object (the callback's first argument) will
be the return value. In this way, arbitrary code can be used within (i.e.,
spliced or tapped into) a chained set of object method calls.

    # longer version
    $object = $object->tap( sub { $_->some_method(@args) } );

    # inject side effects into a method chain
    $object->foo('A')->tap( sub { say $_->foo } )->foo('B');

## with\_roles

    my $new_class = SubClass->with_roles('SubClass::Role::One');
    my $new_class = SubClass->with_roles( '+One', '+Two' );
    $object       = $object->with_roles( '+One', '+Two' );

Create a new class with one or more [Role::Tiny](https://metacpan.org/pod/Role%3A%3ATiny) roles. If called on a class
returns the new class, or if called on an object reblesses the object into the
new class. For roles following the naming scheme "MyClass::Role::RoleName" you
can use the shorthand "+RoleName".

    # create a new class with the role "SubClass::Role::Foo" and instantiate it
    my $new_class = SubClass->with_roles('+Foo');
    my $object    = $new_class->new;

You will almost certainly want to read the documentation for [exact::role](https://metacpan.org/pod/exact%3A%3Arole) for
writing roles.

# CONSIDERATIONS AND CAVEATS

Just as it is with [Mojo::Base](https://metacpan.org/pod/Mojo%3A%3ABase) and [Role::Tiny](https://metacpan.org/pod/Role%3A%3ATiny), if you redefine anything
(like a `has` or `class_has` or method) either within the same class or via
inheritance or use of roles in any variety of ways, it will be redefined
silently. Last redefinition wins. Obviously, this sort of power can be dangerous
if it falls into the wrong hands.

However, unlike [Role::Tiny](https://metacpan.org/pod/Role%3A%3ATiny), composition using the `with` keyword and via a
call to `with_roles` works exactly the same. For example, the `$cat_1` and
`$cat_2` objects are equivalent with [exact::class](https://metacpan.org/pod/exact%3A%3Aclass) but are not equivalent
with [Role::Tiny](https://metacpan.org/pod/Role%3A%3ATiny):

    package CatWithRole {
        use exact -class;
        with 'Attack';
    }

    package CatWithNoRole {
        use exact -class;
    }

    my $cat_1 = CatWithRole->new;
    my $cat_2 = CatWithNoRole->new->with_roles('Attack');

What happens with calling `with_roles` via [Role::Tiny](https://metacpan.org/pod/Role%3A%3ATiny) is that the resulting
object will have any duplicate attributes from the role override the class,
versus the [exact::class](https://metacpan.org/pod/exact%3A%3Aclass) way of the class overriding the role.

# SEE ALSO

You can look for additional information at:

- [GitHub](https://github.com/gryphonshafer/exact-class)
- [MetaCPAN](https://metacpan.org/pod/exact::class)
- [GitHub Actions](https://github.com/gryphonshafer/exact-class/actions)
- [Codecov](https://codecov.io/gh/gryphonshafer/exact-class)
- [CPANTS](http://cpants.cpanauthors.org/dist/exact-class)
- [CPAN Testers](http://www.cpantesters.org/distro/D/exact-class.html)

# AUTHOR

Gryphon Shafer <gryphon@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2019-2050 by Gryphon Shafer.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
