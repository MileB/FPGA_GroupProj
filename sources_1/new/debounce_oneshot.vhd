----------------------------------------------------------------------------------
-- 
-- Name: Michael Byers Jr
-- Class: EN525.642 FPGA/VHDL
-- Assignment: Lab 7
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity debounce_oneshot is port (
  clk   : in  std_logic;
  input : in  std_logic;
  pulse : out std_logic);
end debounce_oneshot;

architecture rtl of debounce_oneshot is
  signal counter : unsigned(23 downto 0);
  signal shoot   : std_logic;
  signal pulse_s : std_logic;
  signal oneshot : std_logic;
begin

  -- Simple logic to detect when the counter condition is met for a pulse
  shoot <= '1' when ( (counter=0) and (input='1') and (pulse_s='0') ) else '0';

  -- Simple incrementing counter.
  -- Uses the lack of button press ( ~input ) as the reset condition
  upcount : process (clk, input) 
  begin
    if (input='0') then
      counter <= (others => '0');
    elsif (rising_edge(clk)) then
      if (oneshot = '0') then
        counter <= counter+1;
      end if;
    end if;
  end process;

  -- Oneshot process, ensure we pause timer while the button remains held
  -- Signal oneshot is set high when a pulse goes out. It then remains high
  -- until input is brought low, gating the counter
  oneshot_p : process(clk, input)
  begin
    if (input ='0') then
      oneshot <= '0';
    elsif (rising_edge(clk)) then
      oneshot <= pulse_s or oneshot;
    end if;
  end process;

  -- Clock in the pulse logic for 1 period of the clock
  pulse_out : process(clk)
  begin
    if (rising_edge(clk)) then
      if (shoot='1') then
        pulse_s <= '1';
      else
        pulse_s <= '0';
      end if;
    end if;
  end process;

  pulse <= pulse_s;

end rtl;
