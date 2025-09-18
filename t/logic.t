#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use Test::Most qw/no_plan/;

{

    package My::Database;
    use AI::Logic::Database variables => [ qw/ Person Project Skill Team Mentee / ],
      predicates => [
        qw{
          developer/1
          designer/1
          manager/1
          works_on/2
          skill/2
          team_member/2
          mentor/2
          collaborates/2
          project/1
          team/1
          team_lead/1
          work_together/2
          person/1
          experienced/1
          }
      ];
    
    # Roles
    developer { 'yuki' };
    developer { 'adeyemi' };
    developer { 'priya' };
    developer { 'carlos' };
    designer { 'kenji' };
    designer { 'zara' };
    manager { 'amara' };
    manager { 'hassan' };
    
    # Projects
    project { 'web_app' };
    project { 'mobile_app' };
    project { 'api_service' };
    
    # Work assignments
    works_on { 'yuki', 'web_app' };
    works_on { 'adeyemi', 'mobile_app' };
    works_on { 'priya', 'api_service' };
    works_on { 'carlos', 'web_app' };
    
    # Skills
    skill { 'yuki', 'javascript' };
    skill { 'adeyemi', 'python' };
    skill { 'priya', 'rust' };
    skill { 'carlos', 'go' };
    skill { 'kenji', 'design' };
    
    # Team memberships
    team_member { 'yuki', 'frontend' };
    team_member { 'carlos', 'frontend' };  # Carlos and yuki on same team
    team_member { 'adeyemi', 'backend' };
    team_member { 'priya', 'backend' };
    team_member { 'kenji', 'design' };
    team_member { 'amara', 'design' };     # Amara and kenji on same team
    
    # Mentoring
    mentor { 'carlos', 'yuki' };
    mentor { 'amara', 'kenji' };
    
    # Rules
    Rule { person { Person } => developer { Person } };
    Rule { person { Person } => designer { Person } };
    Rule { person { Person } => manager { Person } };
    
    # Someone is experienced if they have multiple skills
    experienced { 'carlos' };  # Has go and mentoring experience
    
    # Team lead rule: someone who mentors others (simplified)
    Rule {
        team_lead { Person } => 
          mentor { Person, Any };
    };
    
    # Work together rule: people who work on the same project
    Rule {
        work_together { Person, Project } =>
          works_on { Person, Project };
    };
}

use AI::Logic 'My::Database';

throws_ok {
    developer( 1, 2, sub { } );
}
qr{^Predicate developer/2 not found in database},
  'Calling an unknown predicate should fail';

my @names;
foreach my $name (qw/yuki unknown adeyemi/) {
    developer( $name, sub { push @names => $name; } );
}
eq_or_diff \@names, [qw/yuki adeyemi/],
  'Matching against individual names should succeed';
my $dev = Var;
@names = ();
developer( $dev, sub { push @names => $dev->value } );
eq_or_diff \@names, [qw/yuki adeyemi priya carlos/],
  '... and matching against logic variables should succeed';

my $person = Var 'yuki';
my $project = Var;
works_on(
    $person, $project,
    sub {
        is $project->value, 'web_app', 'Predicates with an arity > 1 should succeed';
    }
);
$person->unbind;
$project->unbind;
my @assignments;
works_on(
    $person, $project,
    sub {
        push @assignments => [ $person->value, $project->value ];
    }
);
eq_or_diff \@assignments, [ 
    [qw/yuki web_app/], 
    [qw/adeyemi mobile_app/], 
    [qw/priya api_service/],
    [qw/carlos web_app/]
  ],
  '... and you should be able to search all records if the arity > 1';


my @team_leads;
my $var = Var 'carlos';
my $continuation = sub { push @team_leads, $var->value };
team_lead( $var, $continuation );
eq_or_diff \@team_leads, ['carlos'], 'We should be able to match a head :- tail rule';

@team_leads = ();
$var = Var;
team_lead($var,$continuation);
eq_or_diff [sort @team_leads], [ 'amara', 'carlos' ],
  'We should be able to match a head :- tail rule';

sub experienced_mentor {
    my ($person, $continuation) = @_;
    experienced(
        $person,
        sub {
            mentor(
                $person, Var,
                sub {
                    developer( $person, $continuation );
                }
            );
        }
    );
}
my $mentor_var = Var;
experienced_mentor($mentor_var, sub { diag $mentor_var->value });
person('yuki', sub { explain "Yuki is a person" });
person('kenji', sub { explain "Kenji is a person" });
