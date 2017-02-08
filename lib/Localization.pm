package Localization;

use strict;
use warnings;
use utf8;

use parent ("Exporter");

my %strings = (
	"English" => {
		"na"                                  => "N/A",

		"datetime_format"                     => "%%d %%b %%H:%%M",
		"contact_format"                      => "▶ %s %s\n📞 %s",

		"span_regexp"                         => qr/(?:[^\d\s]+\s+)?([^\d\s,]+)(?:(?:\s*,\s*)|(?:\s+))([^\d\s]+)\s+(\d+)(?:[:.-](\d+))?(?:\s+[^\d\s]+\s+(\d+)(?:[:.-](\d+))?)?/i,
		"today"                               => "today",
		"tomorrow"                            => "tomorrow",

		"monday_re"                           => qr/mon(?:day)?/i,
		"tuesday_re"                          => qr/tue(?:sday)?/i,
		"wednesday_re"                        => qr/wed(?:nesday)?/i,
		"thursday_re"                         => qr/thu(?:rsday)?/i,
		"friday_re"                           => qr/fri(?:day)?/i,
		"saturday_re"                         => qr/sat(?:urday)?/i,
		"sunday_re"                           => qr/sun(?:day)?/i,

		"at_re"                               => qr/at/i,
		"until_re"                            => qr/until/i,

		"30_min"                              => "30 minutes",
		"1_hour"                              => "1 hour",
		"2_hours"                             => "2 hours",
		"3_hours"                             => "3 hours",

		"back"                                => "⬅️ Back",

		"cancel"                              => "❌ Cancel",
		"operation_cancelled"                 => "Operation cancelled",

		"start"                               => "Hello! I am FabLab61 booking bot",
		"contact"                             => "Share your contact with me in order to book tools",
		"invalid_contact"                     => "This is not information I need. Try again",
		"begin"                               => "OK. Let's begin!",
		"select_resource"                     => "Select tool for booking",
		"resource_not_found"                  => "I can't found free tools for now, sorry. Try again later",
		"invalid_resource"                    => "This is not information I need. Try again",
		"select_duration"                     => "OK. How long will you use the tool?",
		"duration_not_found"                  => "I can't found free vacancies for this tool, sorry. Try again later",
		"invalid_duration"                    => "This is not information I need. Try again",
		"select_datetime"                     => "OK. Select convenient time",
		"invalid_datetime"                    => "This is not information I need. Try again",
		"instructor_not_found"                => "I can't found an instructor for you (looks like this time has been booked already). Please, select another time",
		"booked"                              => "OK, done. I have booked %s for you at %s",
		"booked_by"                           => "Booked by %s",
		"instructor_contact"                  => "Here is your instructor contact:",

		"press_refresh_button"                => "Press the button to refresh data",
		"refresh"                             => "⬅️ Refresh",

		"instructor_start"                    => "Hello! I am FabLab61 booking bot",
		"instructor_menu"                     => "What can I do for you?",
		"instructor_show_schedule"            => "📒 Show my schedule",
		"instructor_add_record"               => "➕ Add record to the schedule",
		"instructor_schedule"                 => "OK, I am going to send you the schedule in a moment",
		"instructor_record_time"              => "Enter time when you are available",
		"instructor_new_book"                 => "Hi! I have received new book record for you, here is what I have:\nResource: %s\nBooked from %s to %s\nI will send you the user contact in a moment\nYour contact has been sent to the user already\nHave a nice day! 😊",

		"group_new_book"                      => "Hi guys! I have received new book record for instructor %s (%s), here is what I have:\nResource: %s\nBooked from %s to %s\nI will post here the user contact in a moment\nThe instructor's contact has been sent to the user already\nHave a nice day! 😊",
		"group_new_book_fallback"             => "Hi guys! I have received new book record, here is what I have:\nResource: %s\nBooked from %s to %s\nI will post here the user contact in a moment\nHave a nice day! 😊",
	},

	"Russian" => {
		"na"                                  => "Н/Д",

		"today"                               => "сегодня",
		"tomorrow"                            => "завтра",

		"monday_re"                           => qr/(?:пн)|(?:понедельник)/i,
		"tuesday_re"                          => qr/(?:вт)|(?:вторник)/i,
		"wednesday_re"                        => qr/(?:ср)|(?:сред(?:а|у))/i,
		"thursday_re"                         => qr/(?:чт)|(?:четверг)/i,
		"friday_re"                           => qr/(?:пт)|(?:пятниц(?:а|у))/i,
		"saturday_re"                         => qr/(?:сб)|(?:суббот(?:а|у))/i,
		"sunday_re"                           => qr/(?:вс)|(?:воскресенье)/i,
		
		"at_re"                               => qr/в/i,
		"until_re"                            => qr/до/i,

		"30_min"                              => "30 минут",
		"1_hour"                              => "1 час",
		"2_hours"                             => "2 часа",
		"3_hours"                             => "3 часа",

		"start"                               => "Привет! Я бот для бронирования оборудования FabLab61",
		"contact"                             => "Пришли мне свои контакты, чтобы получить доступ к бронированию",
		"invalid_contact"                     => "Это не то, что мне нужно, попробуй ещё раз",
		"begin"                               => "Хорошо, приступим 👌",
		"select_resource"                     => "⚠ Выбери оборудование для бронирования",
		"resource_not_found"                  => "Я не нашёл свободного оборудования на данный момент, извини. Попробуй позже",
		"invalid_resource"                    => "Это не то, что мне нужно. Попробуй ещё раз",
		"select_duration"                     => "🕒 Сколько будешь работать с оборудованием?",
		"duration_not_found"                  => "Я не нашёл свободного времени для данного оборудования, извини. Попробуй позже",
		"invalid_duration"                    => "Это не то, что мне нужно. Попробуй ещё раз",
		"select_datetime"                     => "📆 Выбери подходящие дату и время",
		"invalid_datetime"                    => "Это не то, что мне нужно. Попробуй ещё раз",
		"instructor_not_found"                => "Я не смог найти инструктора для тебя (возможно, выбранное тобой время уже заняли). Выбери другое время, пожалуйста",
		"booked"                              => "Отлично, я забронировал для тебя %s на дату %s",
		"booked_by"                           => "Забронировал %s",
		"instructor_contact"                  => "Вот контакт твоего инструктора:",

		"press_refresh_button"                => "Нажми кнопку чтобы обновить информацию",
		"refresh"                             => "⬅️ Обновить",

		"instructor_new_book"                 => "Привет! Я получил новую заявку на бронирование твоего оборудования. Вот информация, которая у меня есть:\nОборудование: %s\nВремя брони: с %s до %s\nСейчас я пришлю контакты клиента\nТвои контакты уже отправлены\nХорошего дня! 😊",

		"group_new_book"                      => "Всем привет! Я получил новую заявку на бронирование для инструктора %s (%s). Вот что я узнал:\nОборудование: %s\nВремя брони: с %s до %s\nСейчас я пришлю контакты клиента\nКонтакты инструктора уже отправлены клиенту\nВсем хорошего дня! 😊",
		"group_new_book_fallback"             => "Всем привет! Я получил новую заявку на бронирование. Вот что я узнал:\nОборудование: %s\nВремя брони: с %s до %s\nСейчас я пришлю контакты клиента\nВсем хорошего дня! 😊",
	},
);

sub languages {
	my @result = keys %strings;
	\@result;
}

my $fallback = "English";
my $language = $fallback;

sub set_language {
	my ($new_language) = @_;

	my $languages_ = languages;
	my $result = defined $new_language and
		grep { $_ eq $new_language } @$languages_;
	if ($result) {
		$language = $new_language;
	}

	$result;
}

sub lz {
	my ($key, @params) = @_;

	sub _keys {
		my ($language) = @_;
		my @result = keys %{$strings{$language}};
		\@result;
	};

	if (grep { $_ eq $key } keys %{$strings{$language}}) {
		sprintf($strings{$language}{$key}, @params);
	} elsif (grep { $_ eq $key } keys %{$strings{$fallback}}) {
		sprintf($strings{$fallback}{$key}, @params);
	} else {
		$key;
	}
}

sub dt {
	my ($datetime) = @_;
	$datetime->strftime(lz("datetime_format"));
}

our @EXPORT_OK = ("lz", "dt");

1;
