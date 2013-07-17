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
  Weechat.register 'notifier', 'Kabaka', '1', 'MIT',
    'Run scripts on matching messages.', '', ''

  Weechat.hook_command 'notifier', 'Interact with the online notifier script.',
    'enable | once | disable',
    [
      ' enable: enable online notifications',
      '   once: notify only on the next occurrence, then disable',
      'disable: disable online notifications'
    ].join("\n"),
    'enable || once || disable',
    'notifier_cmd_callback', ''

  Weechat.config_set_desc_plugin 'command',
    [
      'Command to run when the script is triggered. May include variables:',
      '   $nick: nick of triggering user',
      ' $buffer: full name of buffer in which trigger was printed',
      '$channel: short buffer name',
      '   $text: text body (including prefix) of the triggering message',
    ].join("\n")

  Weechat.config_set_desc_plugin 'tags',
    [
      'Comma-separated list of tags to which the script should react.',
      'Optionally, include a message mask to match after a colon.',
      'Example:',
      '  irc_nick_back:*Kabaka*',
      '  nick_Kabaka'
    ].join("\n")

  Weechat.hook_print '', '', '', 0, 'notifier_hook_callback', ''

  @state = :disabled

  Weechat::WEECHAT_RC_OK
end

def notifier_cmd_callback data, buffer, args
  case args.downcase

  when 'enable'
    @state = :enabled
    Weechat.print buffer,
      "Notifications #{Weechat.color 'green'}enabled#{Weechat.color 'reset'}."

  when 'disable'
    @state = :disabled
    Weechat.print buffer,
      "Notifications #{Weechat.color 'red'}disabled#{Weechat.color 'reset'}."

  when 'once'
    @state = :once
    Weechat.print buffer,
      "Notifications #{Weechat.color 'yellow'}enabled for one occurrence#{Weechat.color 'reset'}."

  else
    return Weechat::WEECHAR_RC_ERROR

  end

  Weechat::WEECHAT_RC_OK
end

def notifier_hook_callback data, buffer, date, tags,
  displayed, highlight, prefix, message

  if @state == :disabled
    return Weechat::WEECHAT_RC_OK
  end
  
  if Weechat.config_is_set_plugin('command').zero?
    return Weechat::WEECHAT_RC_OK
  end

  if Weechat.config_is_set_plugin('tags').zero?
    return Weechat::WEECHAT_RC_OK
  end

  notifier_tags_array = Weechat.config_get_plugin('tags').split(/\s*,\s*/)
  
  notifier_tags = {}

  notifier_tags_array.each do |tag|
    tag, text = tag.split ':'
    notifier_tags[tag] = (text || '')
  end

  tags.split(/,/).each do |tag|

    if notifier_tags.has_key? tag
      if notifier_tags[tag].empty?
        return run_command buffer, tags, prefix, message

      elsif Weechat.string_match(message, notifier_tags[tag], 0) == 1
        return run_command buffer, tags, prefix, message
      
      end
    end

  end

  Weechat::WEECHAT_RC_OK
end

def run_command buffer, tags, prefix, message
  command = Weechat.config_get_plugin 'command'

  replacements = {
    '$nick'     => Weechat.string_remove_color(prefix,  ''),
    '$message'  => Weechat.string_remove_color(message, ''),
    '$buffer'   => Weechat.buffer_get_string(buffer, 'full_name'),
    '$channel'  => Weechat.buffer_get_string(buffer, 'short_name')
  }

  replacements.each do |var, sub|
    command.gsub! var, sub
  end

  system command
  
  @state = :disabled if @state == :once
  
  Weechat::WEECHAT_RC_OK
end

