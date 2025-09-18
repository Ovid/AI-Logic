#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
$Data::Dumper::Indent   = 1;
$Data::Dumper::Sortkeys = 1;

{

    package My::Database;
    use AI::Logic::Database predicates => [
        qw{
          developer/1
          designer/1
          works_on/2
          skill/2
          team_member/2
          mentor/2
          },
      ],
      variables => ['Person', 'Project', 'Skill'];
    
    # Diverse team members
    developer { 'yuki' };      # Japanese
    developer { 'adeyemi' };   # Yoruba/Nigerian
    developer { 'priya' };     # Sanskrit/Indian
    developer { 'carlos' };    # Spanish/Latin American
    designer { 'kenji' };      # Japanese
    designer { 'zara' };       # Arabic/Hebrew
    
    # Work assignments
    works_on { 'yuki', 'web_app' };
    works_on { 'adeyemi', 'mobile_app' };
    works_on { 'priya', 'api_service' };
    
    # Skills
    skill { 'yuki', 'javascript' };
    skill { 'adeyemi', 'python' };
    skill { 'priya', 'rust' };
    
    # Team memberships
    team_member { 'yuki', 'frontend' };
    team_member { 'adeyemi', 'backend' };
    team_member { 'priya', 'backend' };
    
    # Mentoring
    mentor { 'carlos', 'yuki' };
    
    Rule {
        full_stack { Person } => 
          skill { Person, 'javascript' },
          skill { Person, 'python' };
    };
}

use AI::Logic 'My::Database';

my @names;
foreach my $name (qw/yuki unknown adeyemi/) {
    developer( $name, sub { push @names => $name; } );
}
print Dumper \@names;
my $dev = Var;
developer( $dev, sub { print $dev->value .' is a developer'.$/ } );

my $person = Var;
my $project = Var;
works_on( $person, $project, sub { 
    print $person->value . ' works on ' . $project->value, $/ 
} );
