----------------------------------------------------------------------------------
-- 
-- Names: Michael Byers Jr, Matt Joy, Luke Allen, Kurt Marking, Marty McConnell
-- Class: EN525.642 FPGA/VHDL
-- Assignment: Lab 8
-- 
-- TODOs:
--    [X] Debounce the inputs of BTNU and BTNC
--        > Done, provided with BTNC_db and BTNU_db
--    [ ] Handle NUM_PLAYBACK Cycles. (ONLY for playback, not writing)
--         This could be handled at the top level 
--         Or within bram counter. In some fashion, we need
--         to have the BRAM addresses loop SW[1:0] number of times
--    [ ] Handle USB to BRAM writing
--         If BTNU is pressed, enable this block and disable playback
--         Recv 10bit from usb_music_serial, pad with two upper 00's, write to
--         BRAM, increment BRAM writing address, wait for the next one, continue...
--         Light LED[0] when you start. Turn it off when done. Light LED[1] when done.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use pwm_utils.all;

library UNISIM;
use UNISIM.VComponents.all;

entity lab8_top is port (
  -- Clock
  CLK100MHZ  : in  std_logic;
  reset : in std_logic;
  -- Push Buttons
  BTNC       : in  std_logic;
  BTNU       : in  std_logic;

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
    signal BTNC_db : std_logic; -- debounced button
    signal BTNU_db : std_logic; -- debounced button


    signal bram_en : std_logic;
    signal bram_we : std_logic_vector (0 downto 0);
    signal bram_addr_un : unsigned (18 downto 0);
    signal bram_addr_slv : std_logic_vector (18 downto 0);
    signal bram_din : std_logic_vector (11 downto 0);
    signal bram_dout : std_logic_vector (11 downto 0);
        
    -- playback counter signals
    signal playback_count : unsigned (11 downto 0); -- 12 bits needed for max value 2_268
    signal playback_count_max : unsigned (11 downto 0);
    signal playback_clear : std_logic;
    signal playback_pulse : std_logic;
    signal playback_en : std_logic;
    
    -- bram reader signals
--    signal bram_reader_reg : unsigned (9 downto 0);
    signal bram_reader_clear : std_logic;

    COMPONENT blk_mem_gen_0
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC; -- Port A clock enable
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
      );
    END COMPONENT;

begin
    AUD_SD <= SW(6);

    -- Debounce BTNC for playback
    debounce_c : entity debounce_oneshot
      PORT MAP (
        clk => CLK100MHZ,
        input => BTNC,
        pulse => BTNC_db
      );

    -- Debounce BTNU for COE loading
    debounce_u : entity debounce_oneshot
      PORT MAP (
        clk => CLK100MHZ,
        input => BTNU,
        pulse => BTNU_db
      );

    bram_en <= '1';

    -- 12-bit wide, 264601 entry deep BRAM.
    -- Used to store a single music file for playback
    bram_inst : blk_mem_gen_0
      PORT MAP (
        clka => CLK100MHZ,
        ena => bram_en,
        wea => (others => '0'),   --bram_we,
        addra => bram_addr_slv,   --bram_addr,
        dina => (others => '0'),  --bram_din,
        douta => bram_dout        --bram_dout
      );

    -- Playback counter will take in our 100 MHz clock and scale
    -- it down to the 44.1 kHz rate for playback of an audio file
    playback_counter : process (CLK100MHZ, reset)
    begin
        if (reset = '1') then
            playback_count <= (others => '0');
            playback_en <= '0';
        elsif (rising_edge(CLK100MHZ)) then
            if (playback_clear = '1') then
                playback_count <= (others => '0');
                playback_en <= playback_en;
            elsif (BTNC_db = '1') then
                playback_count <= playback_count;
                playback_en <= '1';
            elsif (playback_en = '1') then
                playback_count <= playback_count + 1;
                playback_en <= '1';
            end if;
        end if;
    end process;
    
    playback_count_max <= x"8DB"; -- TODO: move this off to a constant
    playback_clear <= '1' when (playback_count = playback_count_max) else '0';
    playback_pulse <= playback_clear;
    

    -- BRAM Reader will continuously increment the 
    -- read address of the BRAM.
    -- TODO : Gate starting this behind either
    --    > Start of music playback
    --    > Start of COE writing
    bram_reader : process (CLK100MHZ, reset)
    begin
        if (reset = '1') then
            bram_addr_un <= (others => '0');
        elsif (rising_edge(CLK100MHZ)) then
            if (bram_reader_clear = '1') then
                bram_addr_un <= (others => '0');
            elsif (playback_pulse = '1') then
                bram_addr_un <= bram_addr_un + 1;
            end if;
        end if;
    end process;
    
    bram_reader_clear <= '1' when (bram_addr_un = "100" & x"0999") else '0';
    bram_addr_slv <= std_logic_vector(bram_addr_un);   

    -- PWM_Generator takes in a duty cycle to 
    -- create a PWM signal for audio output
    -- TODO: Comb. logic to push nothing when
    -- COE loading is going on.
    pwm_generator_inst : entity pwm_generator
    generic map ( pwm_resolution => 10 )
    port map (
        clk => CLK100MHZ,
        reset => reset,
        duty_cycle => bram_dout(9 downto 0),
        pwm_out => AUD_PWM);

end rtl;
