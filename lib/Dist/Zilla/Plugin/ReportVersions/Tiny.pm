package Dist::Zilla::Plugin::ReportVersions::Tiny;
BEGIN {
  $Dist::Zilla::Plugin::ReportVersions::Tiny::VERSION = '1.00';
}
use Moose;
with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::TextTemplate';

use Dist::Zilla::File::FromCode;

sub mvp_multivalue_args { qw{exclude} };
has exclude => (is => 'ro', isa => 'ArrayRef', default => sub { [] });


our $template = q{use strict;
use warnings;
use Test::More 'no_plan';  # the safest way to avoid Test::NoWarnings breaking
                           # our expectations is no_plan, not done_testing!

my $v = "\n";

eval {                     # no excuses!
    my $pv = ($^V || $]);
    $v .= "perl: $pv on $^O from $^X\n\n";     # report our Perl details
};

# Now, our module version dependencies:
sub pmver {
    my ($module) = @_;
    my $pmver;
    eval "require $module;";
    if ($@) {
        if ($@ =~ m/Can't locate .* in \@INC/) {
            $pmver = 'module not found.';
        } else {
            diag("${module}: $@");
            $pmver = 'died during require.';
        }
    } else {
        my $version;
        eval { $version = $module->VERSION; };
        if ($@) {
            diag("${module}: $@");
            $pmver = 'died during VERSION check.';
        } elsif (defined $version) {
            $pmver = "$version";
        } else {
            $pmver = '<undef>';
        }
    }

    # So, we should be good, right?
    return sprintf('%-40s => %s%s', $module, $pmver, "\n");
}

{{
    for my $module (@modules) {
        my $text = "eval { \$v .= pmver('${module}') };\n";
        $OUT .= $text;
    }
}}


# All done.
$v .= <<'EOT';

Thanks for using my code.  I hope it works for you.
If not, please try and include this output in the bug report.

EOT

diag($v);
ok(1, "we really didn't test anything, just reporting data");
exit 0;
};

sub applicable_modules {
    my ($self) = @_;

    # Extract the set of modules we depend on.
    my @modules;
    {
        my %modules;
        my $prereq = $self->zilla->prereqs->as_string_hash;
        for my $phase (keys %{ $prereq || {} }) {
            for my $type (keys %{ $prereq->{$phase} || {} }) {
                for my $module (keys %{ $prereq->{$phase}->{$type} || {} }) {
                    $modules{$module} = 1;
                }
            }
        }

        # This is all I ever really cared about.
        @modules = sort { lc($a) cmp lc($b) }
            grep {
                my $name = $_;
                my $found = grep { $name =~ m{$_} } @{ $self->exclude };
                $found == 0;
            }
                grep { $_ ne 'perl' }
                    keys %modules;
    }

    return @modules;
}

sub generate_test_from_prereqs {
    my ($self) = @_;
    my $content = $self->fill_in_string($template, {
        modules => [$self->applicable_modules]
    });

    return $content;
}

sub gather_files {
  my ($self) = @_;

  my $file = Dist::Zilla::File::FromCode->new({
      name => 't/000-report-versions-tiny.t',
      mode => 0644,
      code => sub { $self->generate_test_from_prereqs }
  });

  $self->add_file($file);
  return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=encoding utf8

=head1 NAME

Dist::Zilla::Plugin::ReportVersions::Tiny - reports dependency versions during testing

=head1 VERSION

version 1.00

=head1 SYNOPSIS

In your F<dist.ini>, include C<[ReportVersions::Tiny]> to load the plugin.

=head1 DESCRIPTION

This module integrates with L<Dist::Zilla> to automatically add an additional
test to your released software.  Rather than testing features of the software,
this reports the versions of all static module dependencies, and of Perl, at
the time the tests are run.

The value of this is that when someone submits a test failure report you can
see which versions of the modules were installed and, hopefully, be able to
reproduce problems that are dependent on a specific set of module versions.

=head1 Differences from Dist::Zilla::Plugin::ReportVersions

This module has the same goal as L<Dist::Zilla::Plugin::ReportVersions>, but
takes a much lighter weight approach: the module that inspired my code bundles
a copy of YAML::Tiny, reads META.yml, then reports from that.

This gives the most accurate picture, since any requirements added at install
time will be detected, but is overkill for the vast majority of modules that
use a simple, static list of dependencies.

This module, rather, generates the list of modules to test at the time the
distribution is being built, and reports from that static list.

The biggest advantage of this is that I no longer have to bundle a large
volume of code that isn't really needed, and have a simpler test suite with
less places that things can go wrong.

=head1 ARGUMENTS

=over

=item B<exclude>

Exclude an individual items from version reporting.

This is most commonly required if some module otherwise interferes with the
normal operation of the tests, such as L<Module::Install>, which does not
behave as you might expect if normally C<use>d.

=back

=head1 AUTHORS

=over

=item Daniel Pittman <daniel@rimspace.net>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Daniel Pittman <daniel@rimspace.net>
All Rights Reserved.

=cut