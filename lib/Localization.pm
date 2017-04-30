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

		"booked_by"                           => "Booked by %s",

		"help"                                => "❓ Help",
		"back"                                => "⬅️ Back",
		"cancel"                              => "❌ Cancel",
		"operation_cancelled"                 => "❌ Operation cancelled",

		"user_start"                          => "Hello! I am booking bot",
		"user_contact"                        => "Share your contact with me in order to book tools",
		"user_share_contact"                  => "✅ Share contact",
		"user_invalid_contact"                => "This is not information I need, try again, please",
		"user_begin"                          => "OK, let's begin 👌",
		"user_select_resource"                => "⚠ Select tool for booking",
		"user_resource_not_found"             => "I can't found free tools for now, sorry. Try again later",
		"user_invalid_resource"               => "This is not information I need, try again, please",
		"user_select_duration"                => "🕒 OK, how long will you use the tool?",
		"user_duration_not_found"             => "I can't found free vacancies for this tool, sorry. Try again later",
		"user_invalid_duration"               => "This is not information I need, try again, please",
		"user_select_datetime"                => "📆 OK, select convenient time",
		"user_invalid_datetime"               => "This is not information I need, try again, please",
		"user_instructor_not_found"           => "I can't found instructor for you (looks like this time has been booked already). Select another time, please",
		"user_booked"                         => "OK, done. I have booked %s for you at %s",
		"user_instructor_contact"             => "Here is your instructor contact:",
		"user_press_refresh_button"           => "Press the button to refresh data",
		"user_refresh"                        => "⬅️ Refresh",

		"instructor_start"                    => "Hello! I am booking bot",
		"instructor_menu"                     => "What can I do for you?",
		"instructor_show_schedule"            => "📒 Show my schedule",
		"instructor_add_record"               => "➕ New record",
		"instructor_schedule"                 => "OK, I'm going to send you the schedule in a moment",
		"instructor_schedule_is_empty"        => "No records found in your schedule",
		"instructor_remove_record"            => "♻️ You can remove free record by pressing correspond button",
		"instructor_invalid_record"           => "❗️ Press button in the menu, please",
		"instructor_record_removed"           => "✅ Record has been removed",
		"instructor_busy"                     => "Busy",
		"instructor_free"                     => "Free",
		"instructor_resource_not_found"       => "No available resources found, sorry. It looks like a bug, inform my admin, please",
		"instructor_select_resource"          => "Select resource that you'll operate",
		"instructor_enter_time"               => "Enter time when you're available",
		"instructor_time_help"                => "Following formats are available:\n1⃣ \"tomorrow from 8.15 to 9.45\" (you can separate minutes with dot, dash or colon)\n2⃣ \"at monday from 10-20 to 17-35\" (record at next monday)\n3⃣ \"at tue from 15 to 19-15\" (minutes can be ommited)\n4⃣ \"sat from 11.10 to 19\" (week days can be shortened to 3 characters, day preposition could be ommited)\n5⃣ \"at wednesday from 9.30\" (record until the end of the working day)\n6⃣ \"friday after 16\" (until the end of the working day)\n7⃣ \"sunday until 14\" (from the begin of the working day)\n8⃣ \"mon at 10:30\" (\"at\" preposition means record for 1 hour, until 11:30 in this case)\n\nYou can add multiple records like \"mon from 12 to 20, tue from 13 to 17\". Records are separated with a comma or a new line.\n\nWarning: this feature is not tested well for English language. If you find any bugs, please, let developers know. Thanks!",
		"instructor_invalid_time"             => "I didn't understand, sorry, try again, please",
		"instructor_record_saved"             => "OK, record(s) saved",
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

		"booked_by"                           => "Забронировал %s",

		"help"                                => "❓ Справка",
		"back"                                => "⬅️ Назад",
		"cancel"                              => "❌ Отмена",
		"operation_cancelled"                 => "❌ Операция отменена",

		"user_start"                          => "Привет! Я бот для бронирования оборудования",
		"user_contact"                        => "Пришли мне свои контакты, чтобы получить доступ к бронированию",
		"user_share_contact"                  => "✅ Отправить контакты",
		"user_invalid_contact"                => "Это не то, что мне нужно, попробуй ещё раз",
		"user_begin"                          => "OK, приступим 👌",
		"user_select_resource"                => "⚠ Выбери оборудование для бронирования",
		"user_resource_not_found"             => "Я не нашёл свободного оборудования на данный момент, извини. Попробуй позже",
		"user_invalid_resource"               => "Это не то, что мне нужно, попробуй ещё раз",
		"user_select_duration"                => "🕒 Сколько будешь работать с оборудованием?",
		"user_duration_not_found"             => "Я не нашёл свободного времени для данного оборудования, извини. Попробуй позже",
		"user_invalid_duration"               => "Это не то, что мне нужно, попробуй ещё раз",
		"user_select_datetime"                => "📆 Выбери подходящие дату и время",
		"user_invalid_datetime"               => "Это не то, что мне нужно, попробуй ещё раз",
		"user_instructor_not_found"           => "Я не смог найти инструктора для тебя (возможно, выбранное тобой время уже заняли). Выбери другое время, пожалуйста",
		"user_booked"                         => "Отлично, я забронировал для тебя %s на дату %s",
		"user_instructor_contact"             => "Вот контакт твоего инструктора:",
		"user_press_refresh_button"           => "Нажми кнопку чтобы обновить информацию",
		"user_refresh"                        => "⬅️ Обновить",

		"instructor_start"                    => "Привет! Я бот для бронирования оборудования",
		"instructor_menu"                     => "Чем могу помочь?",
		"instructor_show_schedule"            => "📒 Моё расписание",
		"instructor_add_record"               => "➕ Новая запись",
		"instructor_schedule"                 => "OK, сейчас пришлю",
		"instructor_schedule_is_empty"        => "В твоём расписании нет записей",
		"instructor_remove_record"            => "♻️ Ты можешь удалить свободную запись нажав на соответствующую кнопку",
		"instructor_invalid_record"           => "❗️ Выбери пункт в меню, пожалуйста",
		"instructor_record_removed"           => "✅ Запись удалена",
		"instructor_busy"                     => "Занято",
		"instructor_free"                     => "Свободно",
		"instructor_resource_not_found"       => "Не найдено доступное оборудование. Это похоже на программную ошибку, пожалуйста, сообщите моему администратору",
		"instructor_select_resource"          => "Выбери оборудование с которым будешь работать",
		"instructor_enter_time"               => "Введи время, в течение которого ты готов принимать заявки",
		"instructor_time_help"                => "Возможны следующие форматы времени:\n1⃣ \"завтра с 8.15 до 9.45\" (минуты отделяются точкой, тире или двоеточием)\n2⃣ \"в понедельник с 10-20 до 17-35\" (запись в следующий понедельник)\n3⃣ \"во вт с 15 до 19-50\" (минуты могут быть не указаны)\n4⃣ \"сб с 11.10 до 19\" (предлог дня недели может отсутствовать, дни недели сокращаются до 2 букв)\n5⃣ \"в среду с 9.30\" (запись до конца рабочего дня)\n6⃣ \"пятница после 16\" (до конца рабочего дня)\n7⃣ \"вс до 14\" (с начала рабочего дня)\n8⃣ \"пн в 10:30\" (предлог \"в\" означает запись на 1 час, до 11:30 в данном случае)\n\nЗаписи могут добавляться \"пачкой\", например \"пн с 12 до 20, вт с 13 до 17\". В этом случае записи разделяются запятой или переводом строки.",
		"instructor_invalid_time"             => "Это слишком сложно для меня, попробуй ещё раз",
		"instructor_record_saved"             => "OK, добавил в расписание",
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
	my $result = defined $new_language &&
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
