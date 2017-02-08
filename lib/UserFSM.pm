package UserFSM;

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
				rules => [CONTACT => 1],
			},

			CONTACT => {
				do => sub { $ctrl->do_contact(@_); },
				rules => [
					BEGIN => sub { $ctrl->contact_rule_begin(@_); },

					START => \&FSMUtils::_start,
					START => \&FSMUtils::_cancel,

					CONTACT_FAILED => 1
				],
			},

			CONTACT_FAILED => {
				do => sub { $ctrl->do_contact_failed(@_); },
				rules => [CONTACT => 1],
			},

			BEGIN => {
				do => sub { $ctrl->do_begin(@_); },
				rules => [RESOURCE => 1],
			},

			RESOURCE => {
				do => sub { $ctrl->do_resource(@_); },
				rules => [
					RESOURCE_NOT_FOUND => sub { $ctrl->resource_rule_resource_not_found(@_); },
					DURATION => sub { $ctrl->resource_rule_duration(@_); },

					BEGIN => \&FSMUtils::_start,
					CANCEL => \&FSMUtils::_cancel,

					RESOURCE_FAILED => 1
				],
			},

			RESOURCE_NOT_FOUND => {
				do => sub { $ctrl->do_resource_not_found(@_); },
				rules => [REFRESH => 1],
			},

			RESOURCE_FAILED => {
				do => sub { $ctrl->do_resource_failed(@_); },
				rules => [RESOURCE => 1],
			},

			DURATION => {
				do => sub { $ctrl->do_duration(@_); },
				rules => [
					DURATION_NOT_FOUND => sub { $ctrl->duration_rule_duration_not_found(@_); },
					DURATION_NOT_FOUND => sub { $ctrl->duration_rule_datetime(@_); },

					BEGIN => \&FSMUtils::_start,
					CANCEL => \&FSMUtils::_cancel,

					DURATION_FAILED => 1
				],
			},

			DURATION_NOT_FOUND => {
				do => sub { $ctrl->do_duration_not_found(@_); },
				rules => [REFRESH => 1],
			},

			DURATION_FAILED => {
				do => sub { $ctrl->do_duration_failed(@_); },
				rules => [DURATION => 1],
			},

			DATETIME => {
				do => sub { $ctrl->do_datetime(@_); },
				rules => [
					INSTRUCTOR => sub { $ctrl->datetime_rule_instructor(@_); },

					BEGIN => \&FSMUtils::_start,
					CANCEL => \&FSMUtils::_cancel,

					DATETIME_FAILED => 1
				],
			},

			DATETIME_FAILED => {
				do => sub { $ctrl->do_datetime_failed(@_); },
				rules => [DATETIME => 1],
			},

			INSTRUCTOR => {
				do => sub { $ctrl->do_instructor(@_); },
				rules => [
					BOOK => sub { $ctrl->instructor_rule_book(@_); },
					INSTRUCTOR_NOT_FOUND => 1
				],
			},

			INSTRUCTOR_NOT_FOUND => {
				do => sub { $ctrl->do_instructor_not_found(@_); },
				rules => [DATETIME => 1],
			},

			BOOK => {
				do => sub { $ctrl->do_book(@_); },
				rules => [BEGIN => 1],
			},

			CANCEL => {
				do => sub { $ctrl->do_cancel(@_); },
				rules => [BEGIN => 1],
			},

			REFRESH => {
				do => sub { $ctrl->do_refresh(@_); },
				rules => [BEGIN => 1],
			},
		)
	};

	bless $self, $class;
	$self->{fsa}->start();
	$self;
}

1;
