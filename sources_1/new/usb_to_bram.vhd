----------------------------------------------------------------------------------
-- 
-- Name: Michael Byers Jr
-- Class: EN525.642 FPGA/VHDL
-- Assignment: Lab 8, Group Project
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use bram_utils.all;

entity usb_to_bram is port (
  clk             : in  std_logic;
  reset           : in  std_logic;
  start_reading   : in  std_logic; -- Signal to start running the state machine
  new_music_data  : in  std_logic; -- Comes directly from usb_music_serial
  music_data      : in  std_logic_vector(9 downto 0); -- Comes directly from usb_music_serial

  request_data    : out std_logic; -- Ask usb_to_serial for more data
  bram_addr       : out bram_addr_t;
  bram_data       : out bram_data_t;
  bram_wr         : out std_logic;

  working         : out std_logic;  -- Logic high while performing read/write
  done            : out std_logic); -- Logic high when operation completed
end usb_to_bram;

architecture rtl of usb_to_bram is 
  signal state : fsm_states_t;
  signal addr  : bram_addr_t;
  signal data  : bram_data_t;
begin

  fsm : process(clk, reset)
  begin
    if (reset = '1') then
      state <= idle;
      addr <= (others => '0');
    elsif (rising_edge(clk)) then
      case state is

        -- Wait for btn press to kick off state machine
        when idle =>
          if (start_reading = '1') then
            state <= wait_for_data;
          else
            state <= idle;
          end if;

        -- Wait for usb_music_serial to have data ready
        when wait_for_data =>
          if (new_music_data = '1') then
            state <= write_to_bram;
          else
            state <= wait_for_data;
          end if;

        -- Write the newly recvd data out to BRAM,
        -- Flow to next state after 1 clk
        when write_to_bram =>
          state <= incr_addr;

        -- Increment the BRAM_ADDR we write to.
        -- If it's at max value, roll to DONE.
        -- Otherwise, head back to load more data
        -- TODO: Check for off-by-one
        when incr_addr =>
          addr <= addr + 1;
          if (addr = BRAM_MAX_ADDR-2) then
            state <= work_done;
          else
            state <= wait_for_data;
          end if;

        -- Mirror of idle,
        -- Unique state lets us tell the world we've finished.
        when work_done =>
          if (start_reading = '1') then
            state <= wait_for_data;
          else
            state <= work_done;
          end if;

      end case;
    end if;
  end process;

  bram_addr <= addr;
  bram_wr <= '1' when (state = write_to_bram) else '0';
  request_data <= '1' when (state = wait_for_data) else '0';
  data <= "00" & music_data when ( (state = wait_for_data) or (state = write_to_bram) ) else (others => '0');
  bram_data <= data;
  done <= '1' when (state = work_done) else '0';
  working <= '1' when ( (state = wait_for_data) or
                        (state = write_to_bram) or
                        (state = incr_addr) ) else '0';

end rtl;
