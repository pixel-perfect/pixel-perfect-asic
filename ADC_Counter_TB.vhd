--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:11:10 09/23/2012
-- Design Name:   
-- Module Name:   /home/swen3027/Dropbox/Documents/SchoolWork/Fall2012/Senior Design/SSLAR/sslar2_rev5_8bit/ADC_Counter_TB.vhd
-- Project Name:  sslar2_rev5_8bit
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ADC_Counter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ADC_Counter_TB IS
END ADC_Counter_TB;
 
ARCHITECTURE behavior OF ADC_Counter_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ADC_Counter
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         adc_cnt_en : IN  std_logic;
         adc_cnt_stop : IN  std_logic;
         adc_cnt : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal adc_cnt_en : std_logic := '0';
   signal adc_cnt_stop : std_logic := '0';

 	--Outputs
   signal adc_cnt : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ps;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ADC_Counter PORT MAP (
          clk => clk,
          rst => rst,
          adc_cnt_en => adc_cnt_en,
          adc_cnt_stop => adc_cnt_stop,
          adc_cnt => adc_cnt
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
    	rst <= '0';
		adc_cnt_en<= '0';
		adc_cnt_stop<='0';
		wait for clk_period*5;
		rst<= '1';
		wait for clk_period;
		adc_cnt_en<='1';
		wait for clk_period*21;
		adc_cnt_stop<='1';
		assert adc_cnt="0000000000010101"
			report "adc counter at wrong value";
		wait for clk_period*10;
		adc_cnt_en <= '0'; --should reset
		wait for clk_period;
		assert adc_cnt = "0000000000000000"
			report "adc counter didn't reset when adc_cnt_en=0&adc_cnt_stop=1"
			severity note;
      -- insert stimulus here 

      wait;

      wait;
   end process;

END;
