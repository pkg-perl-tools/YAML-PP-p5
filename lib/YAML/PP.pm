# ABSTRACT: YAML Parser and Loader
use strict;
use warnings;
package YAML::PP;

our $VERSION = '0.000'; # VERSION

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    }, $class;
    return $self;
}

sub loader { return $_[0]->{loader} }

sub Load {
    require YAML::PP::Loader;
    my ($self, $yaml) = @_;
    $self->{loader} = YAML::PP::Loader->new;
    return $self->loader->Load($yaml);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

YAML Parser and Loader

=head1 SYNOPSIS

WARNING: This is highly experimental.

Here are a few examples of what you can do right now:

    # Load YAML into a very simple data structure
    yaml-pp-p5-load < file.yaml

    # The loader offers JSON::PP, boolean.pm or pureperl 1/0 (default)
    # for booleans
    my $ypp = YAML::PP::Loader->new(boolean => 'JSON::PP');
    my ($data1, $data2) = $ypp->Load($yaml);

    # Print the events from the parser in yaml-test-suite format
    yaml-pp-p5-events < file.yaml

=head1 DESCRIPTION

This is Yet Another YAML Parser. For why this project was started, see
L<"WHY">.

This project contains a Parser L<YAML::PP::Parser> and a Loader
L<YAML::PP::Loader>.

=head2 YAML::PP::Parser

The parser aims to parse C<YAML 1.2>.

Still TODO:

=over 4

=item Flow Style

Flow style is not implemented yet, you will get an appropriate error message.

=item Supported Characters

The regexes are not complete. It will not accept characters that should be
valid, and it will accept characters that should be invalid.

=item Line Numbers

The parser currently doesn't keep track of the line numbers, so the error
messages might not be very useful yet

=item Error Messages

The error messages in general aren't often very informative

=item Lexer

I would like to support a lexer that can be used for highlighting.

=item Possibly more

=back

=head2 YAML::PP::Loader

The loader is very simple so far.

It supports:

=over 4

=item Simple handling of Anchors/Aliases

Like in modules like L<YAML>, the Loader will use references for mappings and
sequences, but obviously not for scalars.

=item Boolean Handling

You can choose between C<'perl'> (default), C<'JSON::PP'> and C<'boolean'>.pm
for handling boolean types.
That allows you to dump the data structure with one of the JSON modules
without losing information about booleans.

I also would like to add the possibility to specify a callback for your
own boolean handling.

=item Numbers

Numbers are created as real numbers instead of strings, so that they are
dumped correctly by modules like L<JSON::XS>, for example.

See L<"NUMBERS"> for an example.

=back

TODO:

=over 4

=item Complex Keys

Mapping Keys in YAML can be more than just scalars. Of course, you can't load
that into a native perl structure. The Loader will not handle this at the
moment. I would like to stringify the complex key and possibly offer to
specify a method for stringification.

=item Tags

Tags are completely ignored.

=item Parse Tree

I would like to generate a complete parse tree, that allows you to manipulate
the data structure and also dump it, including all whitespaces and comments.
The spec says that this is throwaway content, but I read that many people
wish to be able to keep the comments.

=back

=head1 NUMBERS

Compare the output of the following YAML Loaders and JSON::XS dump:


    use JSON::XS;
    use Devel::Peek;

    use YAML::XS ();

    use YAML ();
    $YAML::Numify = 1; # since version 1.23

    use YAML::Syck ();

    use YAML::PP::Loader;

    my $yaml = "foo: 23\n";

    my $d1 = YAML::XS::Load($yaml);
    my $d2 = YAML::Load($yaml);
    my $d3 = YAML::Syck::Load($yaml);
    my $d4 = YAML::PP::Loader->new->Load($yaml);

    Dump $d1->{foo};
    Dump $d2->{foo};
    Dump $d3->{foo};
    Dump $d4->{foo};

    say encode_json($d1);
    say encode_json($d2);
    say encode_json($d3);
    say encode_json($d4);

    SV = PVIV(0x564f09465c00) at 0x564f09460780
      REFCNT = 1
      FLAGS = (IOK,POK,pIOK,pPOK)
      IV = 23
      PV = 0x564f0945a600 "23"\0
      CUR = 2
      LEN = 10

    SV = PVMG(0x5654d491dd80) at 0x5654d4aca4c8
      REFCNT = 1
      FLAGS = (IOK,pIOK)
      IV = 23
      NV = 0
      PV = 0

    SV = PV(0x564f09d45690) at 0x564f09d46b50
      REFCNT = 1
      FLAGS = (POK,pPOK)
      PV = 0x564f09cd1200 "23"\0
      CUR = 2
      LEN = 10

    SV = PVMG(0x564f09b5cbc0) at 0x564f09d473c0
      REFCNT = 1
      FLAGS = (IOK,pIOK)
      IV = 23
      NV = 0
      PV = 0

    {"foo":"23"}
    {"foo":23}
    {"foo":"23"}
    {"foo":23}


=head1 WHY

In 2016 two really cool projects were started by Ingy döt Net.

=head2 YAML TEST SUITE

One is the yaml-test-suite: L<https://github.com/yaml/yaml-test-suite>

It contains about 160 test cases and expected parsing events and more.
There will be more tests coming. This test suite allows to write parsers
without turning the examples from the Specification into tests yourself.
Also the examples aren't completely covering all cases - the test suite
aims to do that.

The suite contains .tml files, and in a seperate 'data' branch you will
find the content in seperate files, if you can't or don't want to
use TestML.

Thanks also to Felix Krause, who is writing a YAML parser in Nim.
He turned all the spec examples into test cases.

As of this writing, the test suite only contains valid examples.
Invalid ones are on our TODO list.

=head2 YAML EDITOR

The second project is a tool to play around with several YAML parsers and
loaders in vim.

L<https://github.com/yaml/yaml-editor>

The project contains the code to build the frameworks (16 as of this
writing) and put it into one big Docker image.

It also contains the yaml-editor itself, which will start a vim in the docker
container, with some useful mappings. You can choose which frameworks you want
to test and see the output in a grid of vim windows.

Especially when writing a parser it is extremely helpful to have all
the test cases and be able to play around with your own examples to see
how they are handled.

=head2 YAML TEST MATRIX

I was curious to see how the different frameworks handle the test cases,
so, using the test suite and the docker image, I wrote some code that runs
the tests, manipulates the output to compare it with the expected output,
and created a matrix view.

L<https://github.com/perlpunk/yaml-test-matrix>

You can find the latest build at L<http://matrix.yaml.io>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 by Tina Müller

This library is free software and may be distributed under the same terms
as perl itself.

=cut
