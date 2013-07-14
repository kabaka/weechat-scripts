# Copyright (C) 2013 Kyle Johnson <kyle@vacantminded.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.)

def weechat_init
  Weechat.register 'online-notifier', 'Kabaka', '1', 'MIT',
    'Run actions when users come online.', '', ''

  Weechat.hook_command 'notifier', 'Interact with the online notifier script.',
    'enable | once | disable',
    [
      ' enable: enable online notifications',
      '   once: notify only on the next occurrence, then disable',
      'disable: disable online notifications'
    ].join("\n"),
    'enable || once || disable',
    'notifier_cmd_callback', ''

  # Hard-coded my better half, here, since this is why I wrote the script.
  target = 'Unnr'

  Weechat.hook_print '', 'irc_nick_back',  target, 0, 'online_callback', ''
  Weechat.hook_print '', "nick_#{target}", '',     0, 'online_callback', ''

  @state = :disabled

  Weechat::WEECHAT_RC_OK
end

def notifier_cmd_callback data, buffer, args
  case args.downcase

  when 'enable'
    @state = :enabled
    print_with_prefix buffer, prefix,
      "Notifications #{Weechat.color 'green'}enabled#{Weechat.color 'reset'}."

  when 'disable'
    @state = :disabled
    print_with_prefix buffer, prefix,
      "Notifications #{Weechat.color 'red'}disabled#{Weechat.color 'reset'}."

  when 'once'
    @state = :once
    print_with_prefix buffer, prefix,
      "Notifications #{Weechat.color 'yellow'}enabled for one occurrence#{Weechat.color 'reset'}."

  else
    return Weechat::WEECHAR_RC_ERROR

  end

  Weechat::WEECHAT_RC_OK
end

def online_callback data, buffer, date, tags,
  displayed, highlight, prefix, message

  return Weechat::WEECHAT_RC_OK if @state == :disabled

  system '/home/kabaka/scripts/sms-notify unnr &'
  
  @state = :disabled if @state == :once

  Weechat::WEECHAT_RC_OK
end

def print_with_prefix buffer, pf, msg
  Weechat.print buffer, "#{pf}\t#{msg}"
end

def prefix
  [
    Weechat.color('green'),  '<',
    Weechat.color('*green'), '=',
    Weechat.color('green'),  '>'
  ].join
end

