=pod

=encoding utf-8

=head1 PURPOSE

Test that MooX::Aspartame compiles and check some basic functionality.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

use strict;
use warnings;
use Test::More;
use Test::Fatal;

use MooX::Aspartame;
use Try::Tiny;

role Foo {
	has foo => (is => "rwp", isa => Int, required => true);
	method add_to_foo (Int $x) {
		try {
			die;
		}
		catch {
			$self->_set_foo( $self->foo + $x );
		};
		return $self;
	}
}

role Bar with Foo;

class Baz with Bar;

ok('Baz'->does('Bar'));
ok('Baz'->does('Foo'));

try {
	'Baz'->new(foo => 1.1);
}
catch {
	like($_[0], qr{^Value "1.1" did not pass type constraint "Int"});
};

package Quux v1.2.3 {
	class Quuux 1.23 {
		class Quuuux {
			::is(__PACKAGE__, 'Quux::Quuux::Quuuux');
		}
	}
}

is('Quux'->VERSION, 'v1.2.3');
is('Quux::Quuux'->VERSION, 1.23);

my $baz = 'Baz'->new(foo => 40);
is($baz->add_to_foo(2), $baz);
is($baz->foo, 42);

like(
	exception { $baz->add_to_foo([]) },
	qr{did not pass type constraint "Int"},
);

done_testing;
