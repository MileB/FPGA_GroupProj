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

-- Inspired by template provided in Lab 7 prompt
entity pwm_generator is 
  generic ( 
    pwm_resolution : integer );
  port ( 
    clk         : in  std_logic;
    reset       : in  std_logic;
    duty_cycle  : in  std_logic_vector(pwm_resolution-1 downto 0);
    pwm_out     : out std_logic);
end pwm_generator;

architecture rtl of pwm_generator is 
  signal counter : unsigned(pwm_resolution-1 downto 0);
begin

  process (reset, clk) 
  begin
    if (reset = '1') then
      counter <= (others => '0');
    elsif (rising_edge(clk)) then
      counter <= counter + 1;
    end if;
  end process;

  process (reset, clk)
    variable all_ones : unsigned(pwm_resolution-1 downto 0);
  begin
    all_ones := (others => '1');
    if (reset = '1') then
      pwm_out <= '0';
    elsif (rising_edge(clk)) then
      if (counter = all_ones) then
        pwm_out <= '0';
      elsif (counter < unsigned(duty_cycle)) then
        pwm_out <= '1';
      else
        pwm_out <= '0';
      end if;
    end if;
  end process;
end rtl;


