package InstructorFSM;

use strict;
use warnings;

use FSA::Rules;

use FSMUtils;

use parent ("BaseFSM");

sub new {
	my ($class, $ctrl) = @_;

	my $self = {
		fsa => FSA::Rules->new(
			START => {
				do => sub { $ctrl->do_start(@_); },
				rules => [MENU => 1],
			},

			CANCEL => {
				do => sub { $ctrl->do_cancel(@_); },
				rules => [MENU => 1],
			},

			MENU => {
				do => sub { $ctrl->do_menu(@_); },
				rules => [SILENT_MENU => 1],
			},

			SILENT_MENU => {
				rules => [
					SCHEDULE => sub { $ctrl->silent_menu_rule_schedule(@_); },
					RESOURCE => sub { $ctrl->silent_menu_rule_resource(@_); },
					SILENT_MENU => 1
				],
			},

			SCHEDULE => {
				do => sub { $ctrl->do_schedule(@_); },
				rules => [SCHEDULE_REMOVE => 1],
			},

			SCHEDULE_REMOVE => {
				do => sub { $ctrl->do_schedule_remove(@_); },
				rules => [
					CANCEL => sub { $ctrl->schedule_remove_rule_cancel(@_); },
					SCHEDULE_REMOVE_DONE => sub { $ctrl->schedule_remove_rule_schedule_remove_done(@_); },
					MENU => 1
				],
			},

			SCHEDULE_REMOVE_DONE => {
				do => sub { $ctrl->do_schedule_remove_done(@_); },
				rules => [SCHEDULE_REMOVE => 1],
			},

			RESOURCE => {
				do => sub { $ctrl->do_resource(@_); },
				rules => [
					RESOURCE_NOT_FOUND => sub { $ctrl->resource_rule_resource_not_found(@_); },
					TIME => sub { $ctrl->resource_rule_time(@_); },
					CANCEL => sub { $ctrl->resource_rule_cancel(@_); },
					RESOURCE_FAILED => 1
				],
			},

			RESOURCE_NOT_FOUND => {
				do => sub { $ctrl->do_resource_not_found(@_); },
				rules => [MENU => 1],
			},

			RESOURCE_FAILED => {
				do => sub { $ctrl->do_resource_failed(@_); },
				rules => [RESOURCE => 1],
			},

			TIME => {
				do => sub { $ctrl->do_time(@_); },
				rules => [
					RESOURCE => sub { $ctrl->time_rule_resource(@_); },
					CANCEL => sub { $ctrl->time_rule_cancel(@_); },
					RECORD => sub { $ctrl->time_rule_record(@_); },
					TIME_FAILED => 1
				],
			},

			TIME_FAILED => {
				do => sub { $ctrl->do_time_failed(@_); },
				rules => [TIME => 1],
			},

			RECORD => {
				do => sub { $ctrl->do_record(@_); },
				rules => [MENU => 1],
			},
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

1;
