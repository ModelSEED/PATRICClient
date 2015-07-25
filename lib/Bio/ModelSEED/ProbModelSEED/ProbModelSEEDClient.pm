package Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient;

use JSON::RPC::Legacy::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient

=head1 DESCRIPTION


=head1 ProbModelSEED


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 list_gapfill_solutions

  $output = $obj->list_gapfill_solutions($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a list_gapfill_solutions_params
$output is a reference to a list where each element is a gapfill_data
list_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a gapfill_id
	ref has a value which is a reference
	media_ref has a value which is a reference
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
Timestamp is a string
gapfill_id is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a reference
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string

</pre>

=end html

=begin text

$input is a list_gapfill_solutions_params
$output is a reference to a list where each element is a gapfill_data
list_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a gapfill_id
	ref has a value which is a reference
	media_ref has a value which is a reference
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
Timestamp is a string
gapfill_id is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a reference
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string


=end text

=item Description



=back

=cut

sub list_gapfill_solutions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_gapfill_solutions (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_gapfill_solutions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_gapfill_solutions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_gapfill_solutions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_gapfill_solutions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_gapfill_solutions",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_gapfill_solutions',
				       );
    }
}



=head2 manage_gapfill_solutions

  $output = $obj->manage_gapfill_solutions($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a manage_gapfill_solutions_params
$output is a reference to a hash where the key is a gapfill_id and the value is a gapfill_data
manage_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
	selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int
reference is a string
gapfill_id is a string
gapfill_command is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a gapfill_id
	ref has a value which is a reference
	media_ref has a value which is a reference
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
Timestamp is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a reference
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string

</pre>

=end html

=begin text

$input is a manage_gapfill_solutions_params
$output is a reference to a hash where the key is a gapfill_id and the value is a gapfill_data
manage_gapfill_solutions_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
	selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int
reference is a string
gapfill_id is a string
gapfill_command is a string
gapfill_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a gapfill_id
	ref has a value which is a reference
	media_ref has a value which is a reference
	integrated has a value which is a bool
	integrated_solution has a value which is an int
	solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction
Timestamp is a string
bool is an int
gapfill_reaction is a reference to a hash where the following keys are defined:
	reaction has a value which is a reference
	direction has a value which is a reaction_direction
	compartment has a value which is a string
reaction_direction is a string


=end text

=item Description



=back

=cut

sub manage_gapfill_solutions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function manage_gapfill_solutions (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to manage_gapfill_solutions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'manage_gapfill_solutions');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.manage_gapfill_solutions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'manage_gapfill_solutions',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method manage_gapfill_solutions",
					    status_line => $self->{client}->status_line,
					    method_name => 'manage_gapfill_solutions',
				       );
    }
}



=head2 list_fba_studies

  $output = $obj->list_fba_studies($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a list_fba_studies_params
$output is a reference to a list where each element is a fba_data
list_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a fba_id
	ref has a value which is a reference
	objective has a value which is a float
	media_ref has a value which is a reference
	objective_function has a value which is a string
Timestamp is a string
fba_id is a string

</pre>

=end html

=begin text

$input is a list_fba_studies_params
$output is a reference to a list where each element is a fba_data
list_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a fba_id
	ref has a value which is a reference
	objective has a value which is a float
	media_ref has a value which is a reference
	objective_function has a value which is a string
Timestamp is a string
fba_id is a string


=end text

=item Description



=back

=cut

sub list_fba_studies
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_fba_studies (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_fba_studies:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_fba_studies');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_fba_studies",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_fba_studies',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_fba_studies",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_fba_studies',
				       );
    }
}



=head2 delete_fba_studies

  $output = $obj->delete_fba_studies($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a delete_fba_studies_params
$output is a reference to a hash where the key is a fba_id and the value is a fba_data
delete_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
reference is a string
gapfill_id is a string
gapfill_command is a string
fba_id is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a fba_id
	ref has a value which is a reference
	objective has a value which is a float
	media_ref has a value which is a reference
	objective_function has a value which is a string
Timestamp is a string

</pre>

=end html

=begin text

$input is a delete_fba_studies_params
$output is a reference to a hash where the key is a fba_id and the value is a fba_data
delete_fba_studies_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
reference is a string
gapfill_id is a string
gapfill_command is a string
fba_id is a string
fba_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a fba_id
	ref has a value which is a reference
	objective has a value which is a float
	media_ref has a value which is a reference
	objective_function has a value which is a string
Timestamp is a string


=end text

=item Description



=back

=cut

sub delete_fba_studies
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_fba_studies (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_fba_studies:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_fba_studies');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.delete_fba_studies",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'delete_fba_studies',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_fba_studies",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_fba_studies',
				       );
    }
}



=head2 export_model

  $output = $obj->export_model($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is an export_model_params
$output is a string
export_model_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	format has a value which is a string
	to_shock has a value which is a bool
reference is a string
bool is an int

</pre>

=end html

=begin text

$input is an export_model_params
$output is a string
export_model_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	format has a value which is a string
	to_shock has a value which is a bool
reference is a string
bool is an int


=end text

=item Description



=back

=cut

sub export_model
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function export_model (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to export_model:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'export_model');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.export_model",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'export_model',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method export_model",
					    status_line => $self->{client}->status_line,
					    method_name => 'export_model',
				       );
    }
}



=head2 export_media

  $output = $obj->export_media($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is an export_media_params
$output is a string
export_media_params is a reference to a hash where the following keys are defined:
	media has a value which is a reference
	to_shock has a value which is a bool
reference is a string
bool is an int

</pre>

=end html

=begin text

$input is an export_media_params
$output is a string
export_media_params is a reference to a hash where the following keys are defined:
	media has a value which is a reference
	to_shock has a value which is a bool
reference is a string
bool is an int


=end text

=item Description



=back

=cut

sub export_media
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function export_media (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to export_media:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'export_media');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.export_media",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'export_media',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method export_media",
					    status_line => $self->{client}->status_line,
					    method_name => 'export_media',
				       );
    }
}



=head2 get_model

  $output = $obj->get_model($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a get_model_params
$output is a model_data
get_model_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
model_data is a reference to a hash where the following keys are defined:
	ref has a value which is a reference
	reactions has a value which is a reference to a list where each element is a model_reaction
	compounds has a value which is a reference to a list where each element is a model_compound
	genes has a value which is a reference to a list where each element is a model_gene
	compartments has a value which is a reference to a list where each element is a model_compartment
	biomasses has a value which is a reference to a list where each element is a model_biomass
model_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	name has a value which is a string
	definition has a value which is a string
	gpr has a value which is a string
	genes has a value which is a reference to a list where each element is a gene_id
reaction_id is a string
gene_id is a string
model_compound is a reference to a hash where the following keys are defined:
	id has a value which is a compound_id
	name has a value which is a string
	formula has a value which is a string
	charge has a value which is a float
compound_id is a string
model_gene is a reference to a hash where the following keys are defined:
	id has a value which is a gene_id
	reactions has a value which is a reference to a list where each element is a reaction_id
model_compartment is a reference to a hash where the following keys are defined:
	id has a value which is a compartment_id
	name has a value which is a string
	pH has a value which is a float
	potential has a value which is a float
compartment_id is a string
model_biomass is a reference to a hash where the following keys are defined:
	id has a value which is a biomass_id
	compounds has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a compound_id
	1: (coefficient) a float
	2: (compartment) a compartment_id

biomass_id is a string

</pre>

=end html

=begin text

$input is a get_model_params
$output is a model_data
get_model_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
model_data is a reference to a hash where the following keys are defined:
	ref has a value which is a reference
	reactions has a value which is a reference to a list where each element is a model_reaction
	compounds has a value which is a reference to a list where each element is a model_compound
	genes has a value which is a reference to a list where each element is a model_gene
	compartments has a value which is a reference to a list where each element is a model_compartment
	biomasses has a value which is a reference to a list where each element is a model_biomass
model_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	name has a value which is a string
	definition has a value which is a string
	gpr has a value which is a string
	genes has a value which is a reference to a list where each element is a gene_id
reaction_id is a string
gene_id is a string
model_compound is a reference to a hash where the following keys are defined:
	id has a value which is a compound_id
	name has a value which is a string
	formula has a value which is a string
	charge has a value which is a float
compound_id is a string
model_gene is a reference to a hash where the following keys are defined:
	id has a value which is a gene_id
	reactions has a value which is a reference to a list where each element is a reaction_id
model_compartment is a reference to a hash where the following keys are defined:
	id has a value which is a compartment_id
	name has a value which is a string
	pH has a value which is a float
	potential has a value which is a float
compartment_id is a string
model_biomass is a reference to a hash where the following keys are defined:
	id has a value which is a biomass_id
	compounds has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a compound_id
	1: (coefficient) a float
	2: (compartment) a compartment_id

biomass_id is a string


=end text

=item Description



=back

=cut

sub get_model
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_model (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_model:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_model');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.get_model",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_model',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_model",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_model',
				       );
    }
}



=head2 delete_model

  $output = $obj->delete_model($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a delete_model_params
$output is an ObjectMeta
delete_model_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string

</pre>

=end html

=begin text

$input is a delete_model_params
$output is an ObjectMeta
delete_model_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string


=end text

=item Description



=back

=cut

sub delete_model
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_model (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_model:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_model');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.delete_model",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'delete_model',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_model",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_model',
				       );
    }
}



=head2 list_models

  $output = $obj->list_models()

=over 4

=item Parameter and return types

=begin html

<pre>
$output is a reference to a list where each element is a ModelStats
ModelStats is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a string
	source has a value which is a string
	source_id has a value which is a string
	name has a value which is a string
	type has a value which is a string
	ref has a value which is a reference
	genome_ref has a value which is a reference
	template_ref has a value which is a reference
	fba_count has a value which is an int
	integrated_gapfills has a value which is an int
	unintegrated_gapfills has a value which is an int
	gene_associated_reactions has a value which is an int
	gapfilled_reactions has a value which is an int
	num_genes has a value which is an int
	num_compounds has a value which is an int
	num_reactions has a value which is an int
	num_biomasses has a value which is an int
	num_biomass_compounds has a value which is an int
	num_compartments has a value which is an int
Timestamp is a string
reference is a string

</pre>

=end html

=begin text

$output is a reference to a list where each element is a ModelStats
ModelStats is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is a string
	source has a value which is a string
	source_id has a value which is a string
	name has a value which is a string
	type has a value which is a string
	ref has a value which is a reference
	genome_ref has a value which is a reference
	template_ref has a value which is a reference
	fba_count has a value which is an int
	integrated_gapfills has a value which is an int
	unintegrated_gapfills has a value which is an int
	gene_associated_reactions has a value which is an int
	gapfilled_reactions has a value which is an int
	num_genes has a value which is an int
	num_compounds has a value which is an int
	num_reactions has a value which is an int
	num_biomasses has a value which is an int
	num_biomass_compounds has a value which is an int
	num_compartments has a value which is an int
Timestamp is a string
reference is a string


=end text

=item Description

FUNCTION: list_models
DESCRIPTION: This function lists all models owned by the user

REQUIRED INPUTS:

=back

=cut

sub list_models
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_models (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_models",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_models',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_models",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_models',
				       );
    }
}



=head2 list_model_edits

  $output = $obj->list_model_edits($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a list_model_edits_params
$output is a reference to a list where each element is an edit_data
list_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is an edit_id
	ref has a value which is a reference
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

Timestamp is a string
edit_id is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string

</pre>

=end html

=begin text

$input is a list_model_edits_params
$output is a reference to a list where each element is an edit_data
list_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is an edit_id
	ref has a value which is a reference
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

Timestamp is a string
edit_id is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string


=end text

=item Description



=back

=cut

sub list_model_edits
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_model_edits (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to list_model_edits:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'list_model_edits');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.list_model_edits",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'list_model_edits',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_model_edits",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_model_edits',
				       );
    }
}



=head2 manage_model_edits

  $output = $obj->manage_model_edits($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a manage_model_edits_params
$output is a reference to a hash where the key is an edit_id and the value is an edit_data
manage_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
	new_edit has a value which is an edit_data
reference is a string
edit_id is a string
gapfill_command is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is an edit_id
	ref has a value which is a reference
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

Timestamp is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string

</pre>

=end html

=begin text

$input is a manage_model_edits_params
$output is a reference to a hash where the key is an edit_id and the value is an edit_data
manage_model_edits_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
	commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
	new_edit has a value which is an edit_data
reference is a string
edit_id is a string
gapfill_command is a string
edit_data is a reference to a hash where the following keys are defined:
	rundate has a value which is a Timestamp
	id has a value which is an edit_id
	ref has a value which is a reference
	reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
	altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
	altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
	altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
	0: a float
	1: a compartment_id

Timestamp is a string
reaction_id is a string
reaction_direction is a string
feature_id is a string
edit_reaction is a reference to a hash where the following keys are defined:
	id has a value which is a reaction_id
	reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
	0: (compound) a string
	1: (coefficient) a float
	2: (compartment) a string

	gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
	direction has a value which is a reaction_direction
compound_id is a string
compartment_id is a string


=end text

=item Description



=back

=cut

sub manage_model_edits
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function manage_model_edits (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to manage_model_edits:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'manage_model_edits');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.manage_model_edits",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'manage_model_edits',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method manage_model_edits",
					    status_line => $self->{client}->status_line,
					    method_name => 'manage_model_edits',
				       );
    }
}



=head2 get_feature

  $output = $obj->get_feature($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a get_feature_params
$output is a feature_data
get_feature_params is a reference to a hash where the following keys are defined:
	genome has a value which is a reference
	feature has a value which is a feature_id
reference is a string
feature_id is a string
feature_data is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	function has a value which is a string
	protein_translation has a value which is a string
	subsystems has a value which is a reference to a list where each element is a string
	plant_similarities has a value which is a reference to a list where each element is a similarity
	prokaryotic_similarities has a value which is a reference to a list where each element is a similarity
similarity is a reference to a hash where the following keys are defined:
	hit_id has a value which is a string
	percent_id has a value which is a float
	e_value has a value which is a float
	bit_score has a value which is an int

</pre>

=end html

=begin text

$input is a get_feature_params
$output is a feature_data
get_feature_params is a reference to a hash where the following keys are defined:
	genome has a value which is a reference
	feature has a value which is a feature_id
reference is a string
feature_id is a string
feature_data is a reference to a hash where the following keys are defined:
	id has a value which is a feature_id
	function has a value which is a string
	protein_translation has a value which is a string
	subsystems has a value which is a reference to a list where each element is a string
	plant_similarities has a value which is a reference to a list where each element is a similarity
	prokaryotic_similarities has a value which is a reference to a list where each element is a similarity
similarity is a reference to a hash where the following keys are defined:
	hit_id has a value which is a string
	percent_id has a value which is a float
	e_value has a value which is a float
	bit_score has a value which is an int


=end text

=item Description



=back

=cut

sub get_feature
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_feature (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_feature:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_feature');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.get_feature",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'get_feature',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_feature",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_feature',
				       );
    }
}



=head2 ModelReconstruction

  $output = $obj->ModelReconstruction($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a ModelReconstruction_params
$output is an ObjectMeta
ModelReconstruction_params is a reference to a hash where the following keys are defined:
	genome has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string

</pre>

=end html

=begin text

$input is a ModelReconstruction_params
$output is an ObjectMeta
ModelReconstruction_params is a reference to a hash where the following keys are defined:
	genome has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string


=end text

=item Description



=back

=cut

sub ModelReconstruction
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function ModelReconstruction (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to ModelReconstruction:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'ModelReconstruction');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.ModelReconstruction",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'ModelReconstruction',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method ModelReconstruction",
					    status_line => $self->{client}->status_line,
					    method_name => 'ModelReconstruction',
				       );
    }
}



=head2 FluxBalanceAnalysis

  $output = $obj->FluxBalanceAnalysis($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a FluxBalanceAnalysis_params
$output is an ObjectMeta
FluxBalanceAnalysis_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string

</pre>

=end html

=begin text

$input is a FluxBalanceAnalysis_params
$output is an ObjectMeta
FluxBalanceAnalysis_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string


=end text

=item Description



=back

=cut

sub FluxBalanceAnalysis
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function FluxBalanceAnalysis (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to FluxBalanceAnalysis:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'FluxBalanceAnalysis');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.FluxBalanceAnalysis",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'FluxBalanceAnalysis',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method FluxBalanceAnalysis",
					    status_line => $self->{client}->status_line,
					    method_name => 'FluxBalanceAnalysis',
				       );
    }
}



=head2 GapfillModel

  $output = $obj->GapfillModel($input)

=over 4

=item Parameter and return types

=begin html

<pre>
$input is a GapfillModel_params
$output is an ObjectMeta
GapfillModel_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string

</pre>

=end html

=begin text

$input is a GapfillModel_params
$output is an ObjectMeta
GapfillModel_params is a reference to a hash where the following keys are defined:
	model has a value which is a reference
reference is a string
ObjectMeta is a reference to a list containing 12 items:
	0: an ObjectName
	1: an ObjectType
	2: a FullObjectPath
	3: (creation_time) a Timestamp
	4: an ObjectID
	5: (object_owner) a Username
	6: an ObjectSize
	7: a UserMetadata
	8: an AutoMetadata
	9: (user_permission) a WorkspacePerm
	10: (global_permission) a WorkspacePerm
	11: (shockurl) a string
ObjectName is a string
ObjectType is a string
FullObjectPath is a string
Timestamp is a string
ObjectID is a string
Username is a string
ObjectSize is an int
UserMetadata is a reference to a hash where the key is a string and the value is a string
AutoMetadata is a reference to a hash where the key is a string and the value is a string
WorkspacePerm is a string


=end text

=item Description



=back

=cut

sub GapfillModel
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function GapfillModel (received $n, expecting 1)");
    }
    {
	my($input) = @args;

	my @_bad_arguments;
        (ref($input) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"input\" (value was \"$input\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to GapfillModel:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'GapfillModel');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "ProbModelSEED.GapfillModel",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'GapfillModel',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method GapfillModel",
					    status_line => $self->{client}->status_line,
					    method_name => 'GapfillModel',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "ProbModelSEED.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'GapfillModel',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method GapfillModel",
            status_line => $self->{client}->status_line,
            method_name => 'GapfillModel',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient\n";
    }
    if ($sMajor == 0) {
        warn "Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 bool

=over 4



=item Description

********************************************************************************
    Universal simple type definitions
   	********************************************************************************


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 reference

=over 4



=item Description

Reference to location in PATRIC workspace (e.g. /home/chenry/models/MyModel)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Timestamp

=over 4



=item Description

Standard perl timestamp (e.g. 2015-03-21-02:14:53)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gapfill_id

=over 4



=item Description

ID of gapfilling solution


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 fba_id

=over 4



=item Description

ID of FBA study


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 edit_id

=over 4



=item Description

ID of model edits


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gapfill_command

=over 4



=item Description

An enum of commands to manage gapfilling solutions [D/I/U]; D = delete, I = integrate, U = unintegrate


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reaction_id

=over 4



=item Description

ID of reaction in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 compound_id

=over 4



=item Description

ID of compound in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 feature_id

=over 4



=item Description

ID of feature in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 compartment_id

=over 4



=item Description

ID of compartment in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gene_id

=over 4



=item Description

ID of gene in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 biomass_id

=over 4



=item Description

ID of biomass reaction in model


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 reaction_direction

=over 4



=item Description

An enum of directions for reactions [</=/>]; < = reverse, = = reversible, > = forward


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Username

=over 4



=item Description

Login name for user


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ObjectName

=over 4



=item Description

Name assigned to an object saved to a workspace


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ObjectID

=over 4



=item Description

Unique UUID assigned to every object in a workspace on save - IDs never reused


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ObjectType

=over 4



=item Description

Specified type of an object (e.g. Genome)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ObjectSize

=over 4



=item Description

Size of the object


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ObjectData

=over 4



=item Description

Generic type containing object data


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 FullObjectPath

=over 4



=item Description

Path to any object in workspace database


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 UserMetadata

=over 4



=item Description

This is a key value hash of user-specified metadata


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 AutoMetadata

=over 4



=item Description

This is a key value hash of automated metadata populated based on object type


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 WorkspacePerm

=over 4



=item Description

User permission in worksace (e.g. w - write, r - read, a - admin, n - none)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 gapfill_reaction

=over 4



=item Description

********************************************************************************
    Complex data structures to support functions
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
reaction has a value which is a reference
direction has a value which is a reaction_direction
compartment has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
reaction has a value which is a reference
direction has a value which is a reaction_direction
compartment has a value which is a string


=end text

=back



=head2 gapfill_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is a gapfill_id
ref has a value which is a reference
media_ref has a value which is a reference
integrated has a value which is a bool
integrated_solution has a value which is an int
solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is a gapfill_id
ref has a value which is a reference
media_ref has a value which is a reference
integrated has a value which is a bool
integrated_solution has a value which is an int
solution_reactions has a value which is a reference to a list where each element is a reference to a list where each element is a gapfill_reaction


=end text

=back



=head2 fba_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is a fba_id
ref has a value which is a reference
objective has a value which is a float
media_ref has a value which is a reference
objective_function has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is a fba_id
ref has a value which is a reference
objective has a value which is a float
media_ref has a value which is a reference
objective_function has a value which is a string


=end text

=back



=head2 edit_reaction

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a reaction_id
reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
0: (compound) a string
1: (coefficient) a float
2: (compartment) a string

gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
direction has a value which is a reaction_direction

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a reaction_id
reagents has a value which is a reference to a list where each element is a reference to a list containing 3 items:
0: (compound) a string
1: (coefficient) a float
2: (compartment) a string

gpr has a value which is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
direction has a value which is a reaction_direction


=end text

=back



=head2 edit_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is an edit_id
ref has a value which is a reference
reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
0: a float
1: a compartment_id


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is an edit_id
ref has a value which is a reference
reactions_to_delete has a value which is a reference to a list where each element is a reaction_id
altered_directions has a value which is a reference to a hash where the key is a reaction_id and the value is a reaction_direction
altered_gpr has a value which is a reference to a hash where the key is a reaction_id and the value is a reference to a list where each element is a reference to a list where each element is a reference to a list where each element is a feature_id
reactions_to_add has a value which is a reference to a list where each element is an edit_reaction
altered_biomass_compound has a value which is a reference to a hash where the key is a compound_id and the value is a reference to a list containing 2 items:
0: a float
1: a compartment_id



=end text

=back



=head2 ModelStats

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is a string
source has a value which is a string
source_id has a value which is a string
name has a value which is a string
type has a value which is a string
ref has a value which is a reference
genome_ref has a value which is a reference
template_ref has a value which is a reference
fba_count has a value which is an int
integrated_gapfills has a value which is an int
unintegrated_gapfills has a value which is an int
gene_associated_reactions has a value which is an int
gapfilled_reactions has a value which is an int
num_genes has a value which is an int
num_compounds has a value which is an int
num_reactions has a value which is an int
num_biomasses has a value which is an int
num_biomass_compounds has a value which is an int
num_compartments has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
rundate has a value which is a Timestamp
id has a value which is a string
source has a value which is a string
source_id has a value which is a string
name has a value which is a string
type has a value which is a string
ref has a value which is a reference
genome_ref has a value which is a reference
template_ref has a value which is a reference
fba_count has a value which is an int
integrated_gapfills has a value which is an int
unintegrated_gapfills has a value which is an int
gene_associated_reactions has a value which is an int
gapfilled_reactions has a value which is an int
num_genes has a value which is an int
num_compounds has a value which is an int
num_reactions has a value which is an int
num_biomasses has a value which is an int
num_biomass_compounds has a value which is an int
num_compartments has a value which is an int


=end text

=back



=head2 model_reaction

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a reaction_id
name has a value which is a string
definition has a value which is a string
gpr has a value which is a string
genes has a value which is a reference to a list where each element is a gene_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a reaction_id
name has a value which is a string
definition has a value which is a string
gpr has a value which is a string
genes has a value which is a reference to a list where each element is a gene_id


=end text

=back



=head2 model_compound

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a compound_id
name has a value which is a string
formula has a value which is a string
charge has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a compound_id
name has a value which is a string
formula has a value which is a string
charge has a value which is a float


=end text

=back



=head2 model_gene

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a gene_id
reactions has a value which is a reference to a list where each element is a reaction_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a gene_id
reactions has a value which is a reference to a list where each element is a reaction_id


=end text

=back



=head2 model_compartment

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a compartment_id
name has a value which is a string
pH has a value which is a float
potential has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a compartment_id
name has a value which is a string
pH has a value which is a float
potential has a value which is a float


=end text

=back



=head2 model_biomass

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a biomass_id
compounds has a value which is a reference to a list where each element is a reference to a list containing 3 items:
0: (compound) a compound_id
1: (coefficient) a float
2: (compartment) a compartment_id


</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a biomass_id
compounds has a value which is a reference to a list where each element is a reference to a list containing 3 items:
0: (compound) a compound_id
1: (coefficient) a float
2: (compartment) a compartment_id



=end text

=back



=head2 model_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a reference
reactions has a value which is a reference to a list where each element is a model_reaction
compounds has a value which is a reference to a list where each element is a model_compound
genes has a value which is a reference to a list where each element is a model_gene
compartments has a value which is a reference to a list where each element is a model_compartment
biomasses has a value which is a reference to a list where each element is a model_biomass

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a reference
reactions has a value which is a reference to a list where each element is a model_reaction
compounds has a value which is a reference to a list where each element is a model_compound
genes has a value which is a reference to a list where each element is a model_gene
compartments has a value which is a reference to a list where each element is a model_compartment
biomasses has a value which is a reference to a list where each element is a model_biomass


=end text

=back



=head2 ObjectMeta

=over 4



=item Description

ObjectMeta: tuple containing information about an object in the workspace 

        ObjectName - name selected for object in workspace
        ObjectType - type of the object in the workspace
        FullObjectPath - full path to object in workspace, including object name
        Timestamp creation_time - time when the object was created
        ObjectID - a globally unique UUID assigned to every object that will never change even if the object is moved
        Username object_owner - name of object owner
        ObjectSize - size of the object in bytes or if object is directory, the number of objects in directory
        UserMetadata - arbitrary user metadata associated with object
        AutoMetadata - automatically populated metadata generated from object data in automated way
        WorkspacePerm user_permission - permissions for the authenticated user of this workspace.
        WorkspacePerm global_permission - whether this workspace is globally readable.
        string shockurl - shockurl included if object is a reference to a shock node


=item Definition

=begin html

<pre>
a reference to a list containing 12 items:
0: an ObjectName
1: an ObjectType
2: a FullObjectPath
3: (creation_time) a Timestamp
4: an ObjectID
5: (object_owner) a Username
6: an ObjectSize
7: a UserMetadata
8: an AutoMetadata
9: (user_permission) a WorkspacePerm
10: (global_permission) a WorkspacePerm
11: (shockurl) a string

</pre>

=end html

=begin text

a reference to a list containing 12 items:
0: an ObjectName
1: an ObjectType
2: a FullObjectPath
3: (creation_time) a Timestamp
4: an ObjectID
5: (object_owner) a Username
6: an ObjectSize
7: a UserMetadata
8: an AutoMetadata
9: (user_permission) a WorkspacePerm
10: (global_permission) a WorkspacePerm
11: (shockurl) a string


=end text

=back



=head2 list_gapfill_solutions_params

=over 4



=item Description

********************************************************************************
    Functions for managing gapfilling studies
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=head2 manage_gapfill_solutions_params

=over 4



=item Description

FUNCTION: manage_gapfill_solutions
DESCRIPTION: This function manages the gapfill solutions for a model and returns gapfill solution data

REQUIRED INPUTS:
reference model - reference to model to integrate solutions for
mapping<gapfill_id,gapfill_command> commands - commands to manage gapfill solutions

OPTIONAL INPUTS:
mapping<gapfill_id,int> selected_solutions - solutions to integrate


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command
selected_solutions has a value which is a reference to a hash where the key is a gapfill_id and the value is an int


=end text

=back



=head2 list_fba_studies_params

=over 4



=item Description

********************************************************************************
    Functions for managing FBA studies
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=head2 delete_fba_studies_params

=over 4



=item Description

FUNCTION: delete_fba_studies
DESCRIPTION: This function deletes fba studies associated with model

REQUIRED INPUTS:
reference model - reference to model to integrate solutions for
list<fba_id> fbas - list of FBA studies to delete


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference
commands has a value which is a reference to a hash where the key is a gapfill_id and the value is a gapfill_command


=end text

=back



=head2 export_model_params

=over 4



=item Description

********************************************************************************
    Functions for export of model data
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference
format has a value which is a string
to_shock has a value which is a bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference
format has a value which is a string
to_shock has a value which is a bool


=end text

=back



=head2 export_media_params

=over 4



=item Description

FUNCTION: export_media
DESCRIPTION: This function exports a media in TSV format

REQUIRED INPUTS:
reference media - reference to media to export
bool to_shock - load exported file to shock and return shock url


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
media has a value which is a reference
to_shock has a value which is a bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
media has a value which is a reference
to_shock has a value which is a bool


=end text

=back



=head2 get_model_params

=over 4



=item Description

********************************************************************************
    Functions for managing models
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=head2 delete_model_params

=over 4



=item Description

FUNCTION: delete_model
DESCRIPTION: This function deletes a model specified by the user

REQUIRED INPUTS:
    reference model - reference to model to delete


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=head2 list_model_edits_params

=over 4



=item Description

********************************************************************************
    Functions for editing models
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=head2 manage_model_edits_params

=over 4



=item Description

FUNCTION: manage_model_edits
DESCRIPTION: This function manages edits to model submitted by user

REQUIRED INPUTS:
reference model - reference to model to integrate solutions for
mapping<edit_id,gapfill_command> commands - list of edit commands

OPTIONAL INPUTS:
edit_data new_edit - list of new edits to add


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference
commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
new_edit has a value which is an edit_data

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference
commands has a value which is a reference to a hash where the key is an edit_id and the value is a gapfill_command
new_edit has a value which is an edit_data


=end text

=back



=head2 similarity

=over 4



=item Description

********************************************************************************
	Functions corresponding to use of PlantSEED web-pages
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
hit_id has a value which is a string
percent_id has a value which is a float
e_value has a value which is a float
bit_score has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
hit_id has a value which is a string
percent_id has a value which is a float
e_value has a value which is a float
bit_score has a value which is an int


=end text

=back



=head2 feature_data

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
id has a value which is a feature_id
function has a value which is a string
protein_translation has a value which is a string
subsystems has a value which is a reference to a list where each element is a string
plant_similarities has a value which is a reference to a list where each element is a similarity
prokaryotic_similarities has a value which is a reference to a list where each element is a similarity

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
id has a value which is a feature_id
function has a value which is a string
protein_translation has a value which is a string
subsystems has a value which is a reference to a list where each element is a string
plant_similarities has a value which is a reference to a list where each element is a similarity
prokaryotic_similarities has a value which is a reference to a list where each element is a similarity


=end text

=back



=head2 get_feature_params

=over 4



=item Description

FUNCTION: get_feature
DESCRIPTION: This function retrieves an individual Plant feature

REQUIRED INPUTS:
reference genome - reference of genome that contains feature
feature_id feature - identifier of feature to get


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome has a value which is a reference
feature has a value which is a feature_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome has a value which is a reference
feature has a value which is a feature_id


=end text

=back



=head2 ModelReconstruction_params

=over 4



=item Description

********************************************************************************
	Functions corresponding to modeling apps
   	********************************************************************************


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome has a value which is a reference


=end text

=back



=head2 FluxBalanceAnalysis_params

=over 4



=item Description

FUNCTION: FluxBalanceAnalysis
DESCRIPTION: This function runs the flux balance analysis app directly. See app service for detailed specs.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=head2 GapfillModel_params

=over 4



=item Description

FUNCTION: GapfillModel
DESCRIPTION: This function runs the gapfilling app directly. See app service for detailed specs.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
model has a value which is a reference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
model has a value which is a reference


=end text

=back



=cut

package Bio::ModelSEED::ProbModelSEED::ProbModelSEEDClient::RpcClient;
use base 'JSON::RPC::Legacy::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::Legacy::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::Legacy::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Legacy::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
