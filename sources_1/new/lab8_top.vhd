----------------------------------------------------------------------------------
-- 
-- Names: Michael Byers Jr, Matt Joy, Luke Allen, Kurt Marking, Marty McConnell
-- Class: EN525.642 FPGA/VHDL
-- Assignment: Lab 8
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use pwm_utils.all;

entity lab8_top is port (
  -- Clock
  CLK100MHZ  : in  std_logic;
  -- Push Buttons
  BTNC       : in  std_logic;

  -- Seg7 Display
  SEG7_CATH  : out std_logic_vector(7 downto 0);
  AN         : out std_logic_vector(7 downto 0);

  -- Switch (Note, 6 is SW 15)
  SW         : in  std_logic_vector(6 downto 0);

  -- PWM Output signals
  AUD_PWM    : out std_logic;   -- PWM Out for mono sound
  AUD_SD     : out std_logic);  -- Amp on/off
end lab8_top;

architecture rtl of lab8_top is
begin
end rtl;
