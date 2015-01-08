package Dist::Zilla::Plugin::InsertCodeResult;

our $DATE = '2014-12-01'; # DATE
our $VERSION = '0.02'; # VERSION

use 5.010001;
use strict;
use warnings;

use Data::Dump qw(dump);

use Moose;
with (
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::FileFinderUser' => {
        default_finders => [':InstallModules', ':ExecFiles'],
    },
);

use namespace::autoclean;

sub munge_files {
    my $self = shift;

    $self->munge_file($_) for @{ $self->found_files };
}

sub munge_file {
    my ($self, $file) = @_;
    my $content = $file->content;
    if ($content =~ s{^#\s*CODE:\s*(.*)\s*$}{$self->_code_result($1)."\n"}egm) {
        $self->log(["inserting result of code '%s' in %s", $1, $file->name]);
        $file->content($content);
    }
}

sub _code_result {
    my($self, $code) = @_;

    local @INC = @INC;
    unshift @INC, "lib";

    my $res = eval $code;

    if ($@) {
        die "eval '$code' failed: $@";
    } else {
        unless (defined($res) && !ref($res)) {
            $res = dump($res);
        }
    }

    $res =~ s/^/ /gm;
    $res;
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Insert the result of Perl code into your POD

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::InsertCodeResult - Insert the result of Perl code into your POD

=head1 VERSION

This document describes version 0.02 of Dist::Zilla::Plugin::InsertCodeResult (from Perl distribution Dist-Zilla-Plugin-InsertCodeResult), released on 2014-12-01.

=head1 SYNOPSIS

In dist.ini:

 [InsertCodeResult]

In your POD:

 # CODE:

=head1 DESCRIPTION

This module finds C<# CODE: ...> directives in your POD, evals the specified
Perl code, and insert the result into your POD as a verbatim paragraph. If
result is a simple scalar, it is printed as is. If it is undef or a reference,
it will be dumped using L<Data::Dump>. If eval fails, build will be aborted.

=for Pod::Coverage .+

=head1 SEE ALSO

L<Dist::Zilla::Plugin::InsertExample>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Dist-Zilla-Plugin-InsertCodeResult>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Dist-Zilla-Plugin-InsertCodeResult>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-InsertCodeResult>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
