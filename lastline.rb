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
  Weechat.register 'lastline', 'Kabaka', '1', 'MIT',
    'Scroll through lines spoken by other users as input history.', '', ''

  Weechat.hook_command 'lastline', 'Scroll through previously printed lines.',
    'previous | next',
    'Ideally should be bound do some keys, such as ctrl-alt-up/down.',
    'previous || next',
    'lastline_cmd_callback', ''

  Weechat.hook_signal 'buffer_switch', 'update_hook', ''

  update_hook
  
  Weechat::WEECHAT_RC_OK
end

def lastline_cmd_callback data, buffer, args
  case args.downcase

  when 'next'
    set_infolist
    new_input = get_next buffer

  when 'previous'
    set_infolist
    new_input = get_previous buffer

  else
    return Weechat::WEECHAR_RC_ERROR

  end

  new_input = Weechat.string_remove_color new_input, ''

  update buffer, new_input

  Weechat::WEECHAT_RC_OK
end

def get_next buffer
  Weechat.infolist_next @infolist
  Weechat.infolist_string @infolist, 'message'
end

def get_previous buffer
  Weechat.infolist_prev @infolist
  Weechat.infolist_string @infolist, 'message'
end

def update buffer, str
  Weechat.buffer_set buffer, 'input', str
end


def update_hook *args
  if @buffer_hook
    Weechat.unhook @buffer_hook
  end

  buffer       = Weechat.current_buffer

  @buffer_hook = Weechat.hook_print buffer,
    '', '', 0, 'reset_infolist', ''

  reset_infolist
end

def set_infolist
  @infolist ||= Weechat.infolist_get 'buffer_lines',
    Weechat.current_buffer, ''
end

def reset_infolist *args
  @infolist = nil
  
  Weechat::WEECHAT_RC_OK
end
