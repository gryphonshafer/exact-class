use Test2::V0;

package Deep {
    use exact 'role';
    has 'remote';
}

package Middle {
    use exact 'role';
    with 'Deep';
}

package Direct {
    use exact 'class';
    with 'Deep';
    has 'local';
}

package Indirect {
    use exact 'class';
    with 'Middle';
    has 'local';
}

my $direct   = Direct->new( remote => 42 );
my $indirect = Indirect->new( remote => 42 );

is( $direct->remote, 42, 'direct remote attr set-able' );
is( $indirect->remote, 42, 'indirect remote attr set-able' );

my $direct_set_0 = Direct->new->remote(42);
my $direct_set_1 = Direct->new->remote(1138);

ok(
    $direct_set_0->remote == 42 and $direct_set_1->remote == 1138,
    'multiple direct remote attr do not bleed',
);

my $indirect_set_0 = Indirect->new->remote(42);
my $indirect_set_1 = Indirect->new->remote(1138);

ok(
    $indirect_set_0->remote == 42 and $indirect_set_1->remote == 1138,
    'multiple indirect remote attr do not bleed',
);

done_testing;
