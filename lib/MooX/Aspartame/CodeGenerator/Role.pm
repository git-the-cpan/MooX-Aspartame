use v5.14;
use strict;
use warnings FATAL => 'all';
no warnings qw(void once uninitialized numeric);

package MooX::Aspartame::CodeGenerator::Role;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.005';

use Moo;
use B qw(perlstring);
extends qw( MooX::Aspartame::CodeGenerator );

around arguments_for_function_parameters => sub
{
	require MooX::Aspartame::MethodModifiers;
	
	my $orig     = shift;
	my $class    = shift;
	my $keywords = $class->$orig(@_);
	my $reify    = $keywords->{fun}{reify_type};
	
	$keywords->{method} = {
		name                 => 'optional',
		default_arguments    => 1,
		check_argument_count => 1,
		named_parameters     => 1,
		types                => 1,
		reify_type           => $reify,
		attrs                => ':method',
		shift                => '$self',
		invocant             => 1,
	};
	$keywords->{ lc($_) } = {
		name                 => 'required',
		default_arguments    => 1,
		check_argument_count => 1,
		named_parameters     => 1,
		types                => 1,
		reify_type           => $reify,
		attrs                => ":$_",
		shift                => '$self',
		invocant             => 1,
	} for qw( Before After Around );
	
	return $keywords;
};

around generate_package_setup => sub
{
	my $orig = shift;
	my $self = shift;
	
	return (
		$self->$orig(@_),
		$self->generate_package_setup_oo,
	);
};

{
	my %using = (
		Moo   => 'use Moo::Role; use MooX::late;',
		Moose => 'use Moose::Role;',
		Mouse => 'use Mouse::Role;',
		Tiny  => 'use Role::Tiny;',
		(
			map { $_ => "use $_;" }
			qw/ Role::Basic Role::Tiny Moo::Role Mouse::Role Moose::Role /
		),
	);
	
	sub generate_package_setup_oo
	{
		my $self  = shift;
		my $using = $self->relations->{using}[0] // 'Moo';
		
		exists($using{$using})
			or Carp::croak("Cannot create a package using $using; stopped");
		
		return (
			$using{$using},
			$self->generate_package_setup_relationships,
			'use namespace::sweep;',
		);
	}
}

sub generate_package_setup_relationships
{
	my $self  = shift;
	my @roles = @{ $self->relations->{with} || [] };
	
	return unless @roles;
	return sprintf "with(%s);", join ",", map perlstring($_), @roles;
}

1;
