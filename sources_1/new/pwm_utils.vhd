library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package pwm_utils is

  -- Subtype to simplify tracking the bit width
  subtype pwm_timer_t is unsigned(9 downto 0);

  -- Constants to keep track of the number of counts for 100 MHz clock
  -- To other various frequencies. 
  -- Don't know that we'll actually need these for lab8, we'll probably
  -- have to just do the math to figure it out ourselves
  constant CNT_0HZ    : pwm_timer_t := to_unsigned(0,   pwm_timer_t'LENGTH);
  constant CNT_500HZ  : pwm_timer_t := to_unsigned(781, pwm_timer_t'LENGTH);
  constant CNT_1000HZ : pwm_timer_t := to_unsigned(391, pwm_timer_t'LENGTH);
  constant CNT_1500HZ : pwm_timer_t := to_unsigned(260, pwm_timer_t'LENGTH);
  constant CNT_2000HZ : pwm_timer_t := to_unsigned(195, pwm_timer_t'LENGTH);
  constant CNT_2500HZ : pwm_timer_t := to_unsigned(156, pwm_timer_t'LENGTH);
  constant CNT_3000HZ : pwm_timer_t := to_unsigned(130, pwm_timer_t'LENGTH);
  constant CNT_3500HZ : pwm_timer_t := to_unsigned(112, pwm_timer_t'LENGTH);

end package pwm_utils;
