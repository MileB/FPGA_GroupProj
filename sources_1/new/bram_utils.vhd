library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package bram_utils is

  -- Subtype to simplify tracking the bit width
  subtype bram_addr_t is unsigned(18 downto 0);
  subtype bram_data_t is std_logic_vector(11 downto 0);

  constant BRAM_MAX_ADDR : bram_addr_t := to_unsigned(264601, bram_addr_t'LENGTH);

  -- State machine types and constants for loading a COE
  type fsm_states_t is (idle, wait_for_data, write_to_bram, incr_addr, work_done);

end package bram_utils;
