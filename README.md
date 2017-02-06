# FabLab Booking Bot

## Build and run

### Requirements

1. Docker 1.6.2 or above.
1. Google Authenticate file. Check [this instruction](https://bitbucket.org/serikov/google-apis-perl) to create it.

### Steps

1. Clone the repository.
1. Put Google Authenticate file into repo dir. Rename it to `gapi.conf`.
1. Open `bot.pl` in text editor and replace Telegram token with yours.
1. Run `dockerctl.sh` (you have to be `root` or member of `docker` group). It will take some time to download Docker images and Perl modules.

_Run `dockerctl.sh help` for more run options._

## Configuration

Configuration file named `bot.json` and has following structure (comments separated with `#`):

```
{
	"token": "<...>",                      # Telegram Bot API token.

	"language": "Russian",                 # Optional. Bot default language (supported values: English, Russian). English used if omitted.
	"timezone": "Europe/Moscow",           # Bot time zone.

	"resources": {
		"CTC 3D printer": {                # Human-readable name of resource.
			"calendar": "primary"          # Resource's calendar id ("primary" for primary account calendar).
		},
	},

	"durations": {                         # Available booking durations in form
		"30_min": 30,                      # LANGUAGE_ID => MINUTES.
		"1_hour": 60,
		"2_hours": 120,
		"3_hours": 180
	},

	"instructors": {                       # List of registered instructors.
		"email@example.com": {             # Human-readable instructor id (username, email - whatever).
			"id": "123456789",             # Instructor's Telegram user id.
			"phone_number": "12345678901", # Instructor's phone number
			"first_name": "Neil",          # and name.
			"last_name": "Gershenfeld"
		}
	}
}
```

## Usage

1. Register your instructors in `bot.json`.
2. Let instructors add their schedule to resources' calendars. Here is some rules they have to follow:

    - instructors must use their human-readable id (see *Configuration* section) as summary for their events;
    - instructors' schedules for particular resource should not intersect each other;
    - instructors' events must be marked as AVAILABLE. *BUSY events will be treated as booked and its time will be removed from resources schedule!*

3. When instructors' schedule added to the calendars you could start the bot.

4. Right after `/start` command the bot will request to share your contact - this is required to book resources, so open menu in right up corner and select `Share my contact`. You are available to book resources now.

5. The bot will notify registered instructors when someone book resources in their schedule, so instructors has to open chat with bot and send `/start` command to it (Telegram bot can't start new chat on their own).

6. You could add the bot to any Telegram group and it will post information about every book he received. This could be useful for common instructors group.

## Known issues

If you have found any issue or have feature request - create an issue for it, please. Thanks.
