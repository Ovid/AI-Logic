package AI::Logic::TestDatabase;

use AI::Logic::Database
    variables => [qw(Person X Y Z List Head Tail Rest Length Item Project Team Skill Role)],
    predicates => [qw(
        developer/1
        designer/1
        manager/1
        works_on/2
        team_member/2
        mentor/2
        collaborates/2
        skill/2
        project/1
        team/1
        team_lead/1
        work_together/2
        Append/3
        Member/2
        Select/3
        Empty_list/1
        List_length/2
    )];

# Software development team with diverse, globally representative names

# Roles
developer { 'yuki' };        # Japanese
developer { 'adeyemi' };     # Yoruba/Nigerian  
developer { 'priya' };       # Sanskrit/Indian
developer { 'carlos' };      # Spanish/Latin American
developer { 'fatima' };      # Arabic
developer { 'erik' };        # Scandinavian
developer { 'aisha' };       # Swahili/Arabic
developer { 'dmitri' };      # Russian

designer { 'kenji' };        # Japanese
designer { 'zara' };         # Arabic/Hebrew
designer { 'maya' };         # Sanskrit/Hebrew/Latin American

manager { 'amara' };         # Igbo/Sanskrit
manager { 'hassan' };        # Arabic
manager { 'ling' };          # Chinese

# Projects
project { 'web_app' };
project { 'mobile_app' };
project { 'api_service' };
project { 'data_pipeline' };

# Teams
team { 'frontend' };
team { 'backend' };
team { 'design' };
team { 'devops' };

# Work relationships
works_on { 'yuki', 'web_app' };
works_on { 'adeyemi', 'mobile_app' };
works_on { 'priya', 'api_service' };
works_on { 'carlos', 'data_pipeline' };
works_on { 'fatima', 'web_app' };
works_on { 'erik', 'mobile_app' };

# Team memberships
team_member { 'yuki', 'frontend' };
team_member { 'adeyemi', 'backend' };
team_member { 'priya', 'backend' };
team_member { 'carlos', 'devops' };
team_member { 'kenji', 'design' };
team_member { 'zara', 'design' };

# Mentoring relationships
mentor { 'carlos', 'yuki' };
mentor { 'fatima', 'adeyemi' };
mentor { 'erik', 'priya' };
mentor { 'amara', 'kenji' };

# Collaboration relationships
collaborates { 'yuki', 'kenji' };
collaborates { 'priya', 'adeyemi' };
collaborates { 'fatima', 'zara' };
collaborates { 'carlos', 'erik' };

# Skills
skill { 'yuki', 'javascript' };
skill { 'yuki', 'react' };
skill { 'adeyemi', 'python' };
skill { 'adeyemi', 'django' };
skill { 'priya', 'rust' };
skill { 'priya', 'postgresql' };
skill { 'carlos', 'go' };
skill { 'carlos', 'kubernetes' };
skill { 'fatima', 'typescript' };
skill { 'fatima', 'vue' };
skill { 'erik', 'swift' };
skill { 'erik', 'ios' };

# Define some useful rules
Rule {
    # Someone is a team_lead if they mentor someone on their team
    team_lead { Person } => 
        mentor { Person, Mentee },
        team_member { Person, Team },
        team_member { Mentee, Team };
};

Rule {
    # Two people work together if they work on the same project
    work_together { Person1, Person2 } =>
        works_on { Person1, Project },
        works_on { Person2, Project };
};

# List predicates will be implemented in subsequent tasks
# For now they are just defined as callable predicates

1;