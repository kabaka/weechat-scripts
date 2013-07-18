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

### lastline

Scroll through printed messages in the input area.

**Commands**

* `lastline`
  * `next` - move to next message in history
  * `previous` - move to previous message in history

### notifier

Runs a shell command when a message matches tags and optionally a text mask.
For more help, see `/set plugins.desc.ruby.notifier.*`.

**Commands**

* `notifier`
  * `enable` - enable online notifications
  * `disable` - disable online notifications
  * `once` - notify only on the next occurrence, then disable

