use Test2::V0;

package ExactClassTest {
    use exact 'class';
    has answer => 42;
}

package ExactClassTest::Role::Attack {
    use exact 'role';
    requires 'attack';
    has 'hp' => 100;
    sub attack { return 42 }
}

package ExactClassTest::Role::Defend {
    use exact::role;
    has 'thac0' => -3;
}

package ExactClassTest::Role::Pur {
    use exact::role;
    has 'happy' => 13;
}

package ExactClassTest::Cat {
    use exact 'class';
    has 'name';
    with 'ExactClassTest::Role::Attack';
}

package ExactClassTest::Cat::Role::Hiss {
    use exact 'role';
    has 'hiss_power' => 12;
}

my $cat;
ok( lives { $cat = ExactClassTest::Cat->new }, 'new Cat' ) or note $@;
is( $cat->hp, 100, 'Cat obj has hp' );

is( exact::role::does_role( $cat, 'ExactClassTest::Role::Attack' ), 1, 'does_role()' );
is( exact::role::does_role( $cat, 'ExactClassTest::Role::Defend' ), 0, 'not does_role()' );

is( $cat->does('ExactClassTest::Role::Attack'), 1, 'does()' );
is( $cat->does('ExactClassTest::Role::Defend'), 0, 'not does()' );

ok( lives {
    exact::role->apply_roles_to_package( 'ExactClassTest::Cat', 'ExactClassTest::Role::Defend' );
}, 'apply_roles_to_package' ) or note $@;
is( $cat->does('ExactClassTest::Role::Defend'), 1, 'Cat can now defend' );

ok( lives {
    exact::role->apply_roles_to_object( $cat, 'ExactClassTest::Role::Pur' );
}, 'apply_roles_to_object' ) or note $@;
is( $cat->does('ExactClassTest::Role::Pur'), 1, 'Cat can now pur' );

my ( $cat2_class, $cat2_obj );
ok( lives {
    $cat2_class = exact::role->create_class_with_roles(
        'ExactClassTest::Cat',
        qw( ExactClassTest::Role::Defend ExactClassTest::Role::Pur ),
    );
}, 'create_class_with_roles' ) or note $@;

ok( lives {
    $cat2_obj = $cat2_class->new;
}, 'instantiate object from created class' ) or note $@;

is( $cat2_obj->does('ExactClassTest::Role::Pur'), 1, 'Cat 2 can pur' );
is( exact::role->is_role('ExactClassTest::Role::Pur'), 1, 'is_role' );
isnt( exact::role->is_role('ExactClassTest::Cat'), 1, 'not is_role 1' );
isnt( exact::role->is_role('ExactClassTest::Role::Bark'), 1, 'not is_role 2' );

my $cat_with_hiss;
ok( lives { $cat_with_hiss = ExactClassTest::Cat->with_roles('+Hiss') }, 'with_roles' ) or note $@;
is( $cat_with_hiss->hiss_power, 12, 'with_roles attribute' );

done_testing;
