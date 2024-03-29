
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "reports dependency versions during testing",
  "AUTHOR" => "Daniel Pittman <daniel\@rimspace.net>, Olivier Mengue <dolmen\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Dist-Zilla-Plugin-ReportVersions-Tiny",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Dist::Zilla::Plugin::ReportVersions::Tiny",
  "PREREQ_PM" => {
    "Dist::Zilla" => "3.101390",
    "Dist::Zilla::File::FromCode" => 0,
    "Dist::Zilla::Role::FileGatherer" => 0,
    "Dist::Zilla::Role::PrereqSource" => 0,
    "Dist::Zilla::Role::TextTemplate" => 0,
    "Moose" => 0,
    "version" => "0.9901"
  },
  "TEST_REQUIRES" => {
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::Deep" => 0,
    "Test::Fatal" => 0,
    "Test::MockObject" => 0,
    "Test::More" => "0.88",
    "Test::Warn" => 0,
    "lib" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "1.10",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



