use strict;
use Bio::P3::Workspace::ScriptHelpers;
use Bio::ModelSEED::MSSeedSupportServer::MSSeedSupportClient;

my($opt, $usage) = Bio::P3::Workspace::ScriptHelpers::options("%c %o",[
	["owner|o", "User whose job should be listed"],
]);

my $mss = Bio::ModelSEED::MSSeedSupportServer::MSSeedSupportClient->new("http://bio-data-1.mcs.anl.gov/services/ms_fba",token => Bio::P3::Workspace::ScriptHelpers::token());
my $output = $mss->list_rast_jobs({owner => $opt->{owner}});
print Data::Dumper->Dump($output)."\n";