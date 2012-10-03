--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:48:38 09/26/2012
-- Design Name:   
-- Module Name:   /home/swen3027/Dropbox/Documents/SchoolWork/Fall2012/Senior Design/SSLAR/sslar2_rev5_8bit/SSLAR2_TB.vhd
-- Project Name:  sslar2_rev5_8bit
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sslar2_test5_8bit
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
library IEEE;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY SSLAR2_TB IS
END SSLAR2_TB;
 
ARCHITECTURE behavior OF SSLAR2_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sslar2_test5_8bit
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         led1 : OUT  std_logic;
         led2 : OUT  std_logic;
         led3 : OUT  std_logic;
         txe : IN  std_logic;
         rxf : IN  std_logic;
         wr : OUT  std_logic;
         rd : OUT  std_logic;
         d : INOUT  std_logic_vector(7 downto 0);
         rdec_clk : OUT  std_logic;
         rdec_rst : OUT  std_logic;
         row_rst : OUT  std_logic;
         row_sel : OUT  std_logic;
         row_boost : OUT  std_logic;
         cdec_clk : OUT  std_logic;
         cdec_rst : OUT  std_logic;
         col_vln_casc : OUT  std_logic;
         col_sh : OUT  std_logic;
         amp_rst : OUT  std_logic;
         comp_rst1 : OUT  std_logic;
         comp_rst2 : OUT  std_logic;
         coldata : IN  std_logic_vector(9 downto 0);
         ref_pwron : OUT  std_logic;
         i2c_rstb : OUT  std_logic;
         i2c_clk : OUT  std_logic;
         i2c_in : OUT  std_logic;
         wat0 : OUT  std_logic;
         wat1 : OUT  std_logic;
         watout : IN  std_logic;
         adc_clk : OUT  std_logic;
         adc_jump : OUT  std_logic;
         adc_done : IN  std_logic;
         ramp_rst : OUT  std_logic;
         ramp_set : OUT  std_logic;
         pdac_clk : OUT  std_logic;
         pdac_sin : OUT  std_logic;
         pdac_sync : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal txe : std_logic := '0';
   signal rxf : std_logic := '0';
   signal coldata : std_logic_vector(9 downto 0) := (others => '0');
   signal watout : std_logic := '0';
   signal adc_done : std_logic := '0';

	--BiDirs
   signal d : std_logic_vector(7 downto 0) := (others => '1');

 	--Outputs
   signal led1 : std_logic;
   signal led2 : std_logic;
   signal led3 : std_logic;
   signal wr : std_logic;
   signal rd : std_logic;
   signal rdec_clk : std_logic;
   signal rdec_rst : std_logic;
   signal row_rst : std_logic;
   signal row_sel : std_logic;
   signal row_boost : std_logic;
   signal cdec_clk : std_logic;
   signal cdec_rst : std_logic;
   signal col_vln_casc : std_logic;
   signal col_sh : std_logic;
   signal amp_rst : std_logic;
   signal comp_rst1 : std_logic;
   signal comp_rst2 : std_logic;
   signal ref_pwron : std_logic;
   signal i2c_rstb : std_logic;
   signal i2c_clk : std_logic;
   signal i2c_in : std_logic;
   signal wat0 : std_logic;
   signal wat1 : std_logic;
   signal adc_clk : std_logic;
   signal adc_jump : std_logic;
   signal ramp_rst : std_logic;
   signal ramp_set : std_logic;
   signal pdac_clk : std_logic;
   signal pdac_sin : std_logic;
   signal pdac_sync : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant rdec_clk_period : time := 10 ns;
   constant cdec_clk_period : time := 10 ns;
   constant i2c_clk_period : time := 10 ns;
   constant adc_clk_period : time := 10 ns;
   constant pdac_clk_period : time := 10 ns;
	signal cnt_d : std_logic := '0';
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sslar2_test5_8bit PORT MAP (
          clk => clk,
          rst => rst,
          led1 => led1,
          led2 => led2,
          led3 => led3,
          txe => txe,
          rxf => rxf,
          wr => wr,
          rd => rd,
          d => d,
          rdec_clk => rdec_clk,
          rdec_rst => rdec_rst,
          row_rst => row_rst,
          row_sel => row_sel,
          row_boost => row_boost,
          cdec_clk => cdec_clk,
          cdec_rst => cdec_rst,
          col_vln_casc => col_vln_casc,
          col_sh => col_sh,
          amp_rst => amp_rst,
          comp_rst1 => comp_rst1,
          comp_rst2 => comp_rst2,
          coldata => coldata,
          ref_pwron => ref_pwron,
          i2c_rstb => i2c_rstb,
          i2c_clk => i2c_clk,
          i2c_in => i2c_in,
          wat0 => wat0,
          wat1 => wat1,
          watout => watout,
          adc_clk => adc_clk,
          adc_jump => adc_jump,
          adc_done => adc_done,
          ramp_rst => ramp_rst,
          ramp_set => ramp_set,
          pdac_clk => pdac_clk,
          pdac_sin => pdac_sin,
          pdac_sync => pdac_sync
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
-- 
--   rdec_clk_process :process
--   begin
--		rdec_clk <= '0';
--		wait for rdec_clk_period/2;
--		rdec_clk <= '1';
--		wait for rdec_clk_period/2;
--   end process;
-- 
--   cdec_clk_process :process
--   begin
--		cdec_clk <= '0';
--		wait for cdec_clk_period/2;
--		cdec_clk <= '1';
--		wait for cdec_clk_period/2;
--   end process;
-- 
--   i2c_clk_process :process
--   begin
--		i2c_clk <= '0';
--		wait for i2c_clk_period/2;
--		i2c_clk <= '1';
--		wait for i2c_clk_period/2;
--   end process;
-- 
--   adc_clk_process :process
--   begin
--		adc_clk <= '0';
--		wait for adc_clk_period/2;
--		adc_clk <= '1';
--		wait for adc_clk_period/2;
--   end process;
-- 
--   pdac_clk_process :process
--   begin
--		pdac_clk <= '0';
--		wait for pdac_clk_period/2;
--		pdac_clk <= '1';
--		wait for pdac_clk_period/2;
--   end process;
	process(clk)
	variable counter : STD_LOGIC_VECTOR (2 downto 0):= "000";
	begin
		if(rst = '0') then
			d <= "11111111";
		else
		if(rising_edge(clk)) then
			if(cnt_d = '1') then
				if(counter = "111") then
					d <= d + 1;
					counter := "000";
				else
					counter := counter + "001";
				end if;
			else
				d <= "11111111";
			end if;
		end if;
		end if;
	end process;

	coldata <= coldata + 1 after clk_period;
	adc_done <= not adc_done after 100*clk_period;
   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '0';
		cnt_d <= '0';
		--coldata <="0000000000";
	--	d <= "11111111";
		wait for 10*clk_period;
		rst <= '1';
		
		wait until rd='0';
		cnt_d <= '1';
		wait for 2* clk_period;
		
		wait for 200*clk_period;
	--	d <= "ZZZZZZZZ";
	--	wait for 10*clk_period;
		wait until amp_rst = '1';
		wait until amp_rst = '0';
		wait for 8 us;
	--	adc_done <= '1';
		wait for 200*clk_period;

      -- insert stimulus here 

      wait;
   end process;

END;
