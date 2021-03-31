package exact::role;
# ABSTRACT: Simple role interface extension for exact

use 5.014;
use exact;
use Role::Tiny ();

# VERSION

sub import {
    my ( $self, $caller ) = @_;
    $caller //= caller();

    eval qq{
        package $caller {
            use Role::Tiny;
            use exact 'class', 'noautoclean';
        };
    };
    die $@ if ($@);
}

sub does_role {
    Role::Tiny::does_role(@_);
}

sub apply_roles_to_package {
    shift;
    Role::Tiny->apply_roles_to_package(@_);
}

sub apply_roles_to_object {
    shift;
    Role::Tiny->apply_roles_to_object(@_);
}

sub create_class_with_roles {
    shift;
    Role::Tiny->create_class_with_roles(@_);
}

sub is_role {
    shift;
    Role::Tiny->is_role(@_);
}

1;
__END__
=pod

=head1 SYNOPSIS

    package Claw;
    use exact -role;

    package Cat;
    use exact -class;

    with 'Claw';

=head1 DESCRIPTION

L<exact::role> is a tiny mechanism to create roles for use with L<exact::class>.
It relies on L<Role::Tiny>, which is to say, it just integrates L<Role::Tiny>
with L<exact::class> and L<exact>.

Note that the C<noautoclean> option of L<exact> gets automatically switched on
when you:

    use exact -role;

This is to prevent all sorts of expected behaviors from L<Role::Tiny>. If you
want autoclean functionality, it's left up to you to set that up.

=head1 IMPORTED FUNCTIONS

=head2 requires

    requires qw(foo bar);

Declares a list of methods that must be defined to compose role.

=head2 with

    with 'Some::Role1';
    with 'Some::Role1', 'Some::Role2';

Composes another role into the current role
(or class via L<exact::class>'s C<with>).

If you have conflicts and want to resolve them in favour of Some::Role1 you
can instead write:

    with 'Some::Role1';
    with 'Some::Role2';

If you have conflicts and want to resolve different conflicts in favour of
different roles, please refactor your codebase.

=head2 before

    before foo => sub { ... };

See L<< Class::Method::Modifiers/before method(s) => sub { ... } >> for full
documentation.

Note that since you are not required to use method modifiers,
L<Class::Method::Modifiers> is lazily loaded and we do not declare it as
a dependency. If your L<exact::role> role uses modifiers you must depend on
both L<Class::Method::Modifiers> and L<exact::role>.

=head2 around

    around foo => sub { ... };

See L<< Class::Method::Modifiers/around method(s) => sub { ... } >> for full
documentation.

Note that since you are not required to use method modifiers,
L<Class::Method::Modifiers> is lazily loaded and we do not declare it as
a dependency. If your L<exact::role> role uses modifiers you must depend on
both L<Class::Method::Modifiers> and L<exact::role>.

=head2 after

    after foo => sub { ... };

See L<< Class::Method::Modifiers/after method(s) => sub { ... } >> for full
documentation.

Note that since you are not required to use method modifiers,
L<Class::Method::Modifiers> is lazily loaded and we do not declare it as
a dependency. If your L<exact::role> role uses modifiers you must depend on
both L<Class::Method::Modifiers> and L<exact::role>.

=head1 SUBROUTINES

=head2 does_role

    exact::role::does_role( $foo, 'Some::Role' );

Returns true if class has been composed with role.

This subroutine is also installed as C<does> on any class a L<exact::role> is
composed into unless that class already has an C<does> method, so...

    $foo->does('Some::Role');

...will work for classes but to test a role, one must use C<does_role> directly.

Additionally, L<exact::role> will override the standard Perl C<does> method
for your class. However, if C<any> class in your class inheritance
hierarchy provides C<does>, then L<exact::role> will not override it.

=head1 METHODS

=head2 apply_roles_to_package

    exact::role->apply_roles_to_package(
        'Some::Package', 'Some::Role', 'Some::Other::Role'
    );

Composes role with package. See also L<exact::class>'s C<with>.

=head2 apply_roles_to_object

    exact::role->apply_roles_to_object( $foo, qw( Some::Role1 Some::Role2 ) );

Composes roles in order into object directly. Object is reblessed into the
resulting class. Note that the object's methods get overridden by the role's
ones with the same names.

=head2 create_class_with_roles

    exact::role->create_class_with_roles( 'Some::Base', qw( Some::Role1 Some::Role2 ) );

Creates a new class based on base, with the roles composed into it in order.
New class is returned.

=head2 is_role

    exact::role->is_role('Some::Role1');

Returns true if the given package is a role.

=head1 SEE ALSO

You can look for additional information at:

=for :list
* L<GitHub|https://github.com/gryphonshafer/exact-class>
* L<MetaCPAN|https://metacpan.org/pod/exact::class>
* L<GitHub Actions|https://github.com/gryphonshafer/exact-class/actions>
* L<Codecov|https://codecov.io/gh/gryphonshafer/exact-class>
* L<CPANTS|http://cpants.cpanauthors.org/dist/exact-class>
* L<CPAN Testers|http://www.cpantesters.org/distro/D/exact-class.html>

=cut
