--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:39:29 09/23/2012
-- Design Name:   
-- Module Name:   /home/swen3027/Dropbox/Documents/SchoolWork/Fall2012/Senior Design/SSLAR/sslar2_rev5_8bit/FPS_Counter_TB.vhd
-- Project Name:  sslar2_rev5_8bit
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FPS_Counter
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
 
ENTITY FPS_Counter_TB IS
END FPS_Counter_TB;
 
ARCHITECTURE behavior OF FPS_Counter_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FPS_Counter
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         fps_cnt_en : IN  std_logic;
         fps_cnt_stop : IN  std_logic;
         fps_cnt : OUT  std_logic_vector(23 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal fps_cnt_en : std_logic := '0';
   signal fps_cnt_stop : std_logic := '0';

 	--Outputs
   signal fps_cnt : std_logic_vector(23 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ps;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FPS_Counter PORT MAP (
          clk => clk,
          rst => rst,
          fps_cnt_en => fps_cnt_en,
          fps_cnt_stop => fps_cnt_stop,
          fps_cnt => fps_cnt
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
		fps_cnt_en<= '0';
		fps_cnt_stop<='0';
		wait for clk_period*5;
		rst<= '1';
		wait for clk_period;
		fps_cnt_en<='1';
		wait for clk_period*21;
		fps_cnt_stop<='1';
		assert fps_cnt="000000000000000000010101"
			report "FPS counter at wrong value";
		wait for clk_period*10;
		fps_cnt_en <= '0'; --should reset
		wait for clk_period;
		assert fps_cnt = "000000000000000000000000"
			report "FPS counter didn't reset when fps_cnt_en=0&fps_cnt_stop=1"
			severity note;
      -- insert stimulus here 

      wait;
   end process;

END;
