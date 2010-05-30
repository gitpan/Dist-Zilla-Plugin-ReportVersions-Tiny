use strict;
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

eval { $v .= pmver('Dist::Zilla') };
eval { $v .= pmver('Dist::Zilla::File::FromCode') };
eval { $v .= pmver('Dist::Zilla::Role::FileGatherer') };
eval { $v .= pmver('Dist::Zilla::Role::TextTemplate') };
eval { $v .= pmver('ExtUtils::MakeMaker') };
eval { $v .= pmver('File::Find') };
eval { $v .= pmver('File::Temp') };
eval { $v .= pmver('Moose') };
eval { $v .= pmver('Test::Differences') };
eval { $v .= pmver('Test::Exception') };
eval { $v .= pmver('Test::MockObject') };
eval { $v .= pmver('Test::More') };
eval { $v .= pmver('vars') };



# All done.
$v .= <<'EOT';

Thanks for using my code.  I hope it works for you.
If not, please try and include this output in the bug report.

EOT

diag($v);
ok(1, "we really didn't test anything, just reporting data");
exit 0;
