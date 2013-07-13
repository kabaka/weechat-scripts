# WeeChat Scripts

A collection of some utility scripts I have written for WeeChat.

Most of these will not be useful for most users. For more interesting scripts,
take a peek at the other `weechat-` repositories on
[my GitHub account](https://github.com/kabaka).

## List of Scripts

### eval

Run Ruby code.

**Commands**

* `eval` - Evaluate Ruby code and output the result to the current buffer.

### online-notifier

Runs a script when a user comes online, caught via irc_nick_back tag,
presently hard-coded for needs.

**Commands**

* `notifier`
  * `enable` - enable online notifications
  * `disable` - disable online notifications
  * `once` - notify only on the next occurrence, then disable

