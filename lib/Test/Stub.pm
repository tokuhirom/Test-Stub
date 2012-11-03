package Test::Stub;
use strict;
use warnings;
use 5.008001;
our $VERSION = '0.03';
use parent qw/Exporter/;

our @EXPORT = qw/stub make_stub/;

sub stub {
    bless \$_[0], 'Test::Stub::Driver';
}

my $id = 0;
sub make_stub {
    my $object = shift;
    my $method = shift;
    my $stub = shift || sub {};

    my $func = ref($stub) eq 'CODE' ? $stub : sub { $stub };

    my $pkg = "Test::Stub::Anon" . $id++;

    # stubbing.
    {
        no strict 'refs';
        unshift @{"$pkg\::ISA"}, ref $$object;
        *{"$pkg\::$method"} = $func;
    }

    # rebless
    bless $$object, $pkg;

    return;
}

package Test::Stub::Driver;

our $AUTOLOAD;
sub DESTROY { }
sub AUTOLOAD {
    $AUTOLOAD =~ s/.*:://;
    my $method = $AUTOLOAD;

    my $self = shift;
    Test::Stub::make_stub($self, $method, @_);

    return;
}

1;
__END__

=encoding utf8

=head1 NAME

Test::Stub - Stub! Stub! Stub!

=head1 SYNOPSIS

    use Test::Stub;

    # DSL style
    my $agent = LWP::UserAgent->new();
    stub($agent)->get(HTTP::Response->new(200, "OK"));
    is($agent->get('http://www.aiseikai.or.jp/')->code, 200);

    # simple style
    my $agent = LWP::UserAgent->new();
    make_stub($agent, 'get', HTTP::Response->new(200, "OK"));
    is($agent->get('http://www.aiseikai.or.jp/')->code, 200);

=head1 DESCRIPTION

Test::Stub is a simple stubbing library for Perl5.

=head1 EXPORTABLE FUNCTIONS

=over 4

=item stub($stuff) : Test::Stub::Driver

Create a new instance of Test::Stub::Driver.

=item make_stub($object, $method, $stub) : Undef

Make monadic class from blessed($object) and add a $method with $stub.

=back

=head1 Test::Stub::Driver

This class only provides a AUTOLOAD method.

AUTOLOAD method rebless the C<$stuff> to anonymous class.

For example. After calling following code:

    stub($stuff)->foo('bar');

C<< $stuff->foo() >> returns 'bar'.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

The interface was taken from L<Test::Double>.

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
