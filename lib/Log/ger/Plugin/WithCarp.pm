package Log::ger::Plugin::WithCarp;

# DATE
# VERSION

use strict;
use warnings;

use Carp ();
use Log::ger ();

sub get_hooks {
    my %conf = @_;

    return {
        create_routine_names => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                my $levels = \%Log::ger::Levels;

                return [{
                    log_subs    => [
                        (map { (["log_${_}_carp", $_, "default"], ["log_${_}_cluck", $_, "default"]) }
                             grep {$levels->{$_} == 30} keys %$levels),
                        (map { (["log_${_}_croak", $_, "default"], ["log_${_}_confess", $_, "default"]) }
                             grep {$levels->{$_} > 0 && $levels->{$_} <= 20} keys %$levels),
                    ],
                    is_subs     => [],
                    log_methods => [
                        (map { (["${_}_carp", $_, "default"], ["${_}_cluck", $_, "default"]) }
                             grep {$levels->{$_} == 30} keys %$levels),
                        (map { (["${_}_croak", $_, "default"], ["${_}_confess", $_, "default"]) }
                             grep {$levels->{$_} > 0 && $levels->{$_} <= 20} keys %$levels),
                    ],
                    logml_methods => [
                    ],
                    is_methods  => [
                    ],
                }, 0];
            }],
        before_install_routines => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                # wrap the logger
                for my $r (@{ $args{routines} }) {
                    my ($code, $name, $numlevel, $type) = @$r;
                    if    ($type eq 'log_sub'    && $name =~ /\Alog_\w+_carp\z/   ) { $r->[0] = sub { $code->(@_);        Carp::carp   ($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_method' && $name =~ /\A\w+_carp\z/       ) { $r->[0] = sub { $code->(@_); shift; Carp::carp   ($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_sub'    && $name =~ /\Alog_\w+_cluck\z/  ) { $r->[0] = sub { $code->(@_);        Carp::cluck  ($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_method' && $name =~ /\A\w+_cluck\z/      ) { $r->[0] = sub { $code->(@_); shift; Carp::cluck  ($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_sub'    && $name =~ /\Alog_\w+_croak\z/  ) { $r->[0] = sub { $code->(@_);        Carp::croak  ($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_method' && $name =~ /\A\w+_croak\z/      ) { $r->[0] = sub { $code->(@_); shift; Carp::croak  ($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_sub'    && $name =~ /\Alog_\w+_confess\z/) { $r->[0] = sub { $code->(@_);        Carp::confess($args{formatters}{default}(@_)."\n") } }
                    elsif ($type eq 'log_method' && $name =~ /\A\w+_confess\z/    ) { $r->[0] = sub { $code->(@_); shift; Carp::confess($args{formatters}{default}(@_)."\n") } }
                }
            },
        ],
    };
}

1;
# ABSTRACT: Add *_{carp,cluck,croak,confess} logging routines

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Plugin 'WithCarp';
 use Log::ger;
 my $log = Log::ger->get_logger;

These subroutines will also become available:

 log_warn_carp    ("blah!"); # in addition to log, will also carp()
 log_warn_cluck   ("blah!"); # in addition to log, will also cluck()
 log_error_croak  ("blah!"); # in addition to log, will also croak()
 log_error_confess("blah!"); # in addition to log, will also confess()
 log_fatal_croak  ("blah!"); # in addition to log, will also croak()
 log_fatal_confess("blah!"); # in addition to log, will also confess()

These logging methods will also become available:

 $log->warn_carp    ("blah!"); # in addition to log, will also carp()
 $log->warn_cluck   ("blah!"); # in addition to log, will also cluck()
 $log->error_croak  ("blah!"); # in addition to log, will also croak()
 $log->error_confess("blah!"); # in addition to log, will also confess()
 $log->fatal_croak  ("blah!"); # in addition to log, will also croak()
 $log->fatal_confess("blah!"); # in addition to log, will also confess()


=head1 DESCRIPTION


=head1 SEE ALSO

L<Log::ger::Plugin::WithWarn>

L<Log::ger::Plugin::WithDie>

L<Log::ger::Plugin::Log4perl>
