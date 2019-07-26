package exact::role;
# ABSTRACT: Simple role interface extension for exact

use 5.014;
use exact;
use Role::Tiny ();

# VERSION

sub import {
    my ( $self, $caller, $params ) = @_;
    $caller //= caller();

    eval qq{
        package $caller {
            use Role::Tiny;
            use exact 'class';
        };
    };
}

1;
__END__
=pod

=begin :badges

=for markdown
[![Build Status](https://travis-ci.org/gryphonshafer/exact-role.svg)](https://travis-ci.org/gryphonshafer/exact-role)
[![Coverage Status](https://coveralls.io/repos/gryphonshafer/exact-role/badge.png)](https://coveralls.io/r/gryphonshafer/exact-role)

=end :badges

=head1 SYNOPSIS

    use exact role;

=head1 DESCRIPTION

L<exact::role> is a...

=head1 SEE ALSO

You can look for additional information at:

=for :list
* L<GitHub|https://github.com/gryphonshafer/exact-role>
* L<CPAN|http://search.cpan.org/dist/exact-role>
* L<MetaCPAN|https://metacpan.org/pod/exact::role>
* L<AnnoCPAN|http://annocpan.org/dist/exact-role>
* L<Travis CI|https://travis-ci.org/gryphonshafer/exact-role>
* L<Coveralls|https://coveralls.io/r/gryphonshafer/exact-role>
* L<CPANTS|http://cpants.cpanauthors.org/dist/exact-role>
* L<CPAN Testers|http://www.cpantesters.org/distro/D/exact-role.html>

=cut
