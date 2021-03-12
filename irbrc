require 'irb/completion'
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:SAVE_HISTORY] = 1000

IRB.conf[:PROMPT][:MY_PROMPT] = { # name of prompt mode
  :AUTO_INDENT => true,           # enables auto-indent mode
  :PROMPT_I =>  "%02n:%i>> ",        # simple prompt
  :PROMPT_S => nil,               # prompt for continuated strings
  :PROMPT_C => nil,               # prompt for continuated statement
  :RETURN => "    ==>%s\n"        # format to return value
}

IRB.conf[:PROMPT_MODE] = :MY_PROMPT
