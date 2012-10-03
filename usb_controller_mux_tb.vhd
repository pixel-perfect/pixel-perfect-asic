--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:51:19 09/24/2012
-- Design Name:   
-- Module Name:   /home/swen3027/Dropbox/Documents/SchoolWork/Fall2012/Senior Design/SSLAR/sslar2_rev5_8bit/usb_controller_mux_tb.vhd
-- Project Name:  sslar2_rev5_8bit
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: usb_controller_mux
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
 
ENTITY usb_controller_mux_tb IS
END usb_controller_mux_tb;
 
ARCHITECTURE behavior OF usb_controller_mux_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT usb_controller_mux
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         go : IN  std_logic;
         done : OUT  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         dir : IN  std_logic;
         busy : OUT  std_logic;
         rd : OUT  std_logic;
         wr : OUT  std_logic;
         txe : IN  std_logic;
         rxf : IN  std_logic;
			ftdi_dout : OUT std_logic_vector(7 downto 0);
			ftdi_din : IN std_logic_vector(7 downto 0)
     --    ftdi_data : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal go : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := "00000000";
   signal dir : std_logic := '0';
   signal txe : std_logic := '0';
   signal rxf : std_logic := '0';
	signal ftdi_din : std_logic_vector(7 downto 0);

	--BiDirs
 --  signal ftdi_data : std_logic_vector(7 downto 0);

 	--Outputs
   signal done : std_logic;
	signal ftdi_dout : std_logic_vector(7 downto 0);
   signal data_out : std_logic_vector(7 downto 0);
   signal busy : std_logic;
   signal rd : std_logic;
   signal wr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: usb_controller_mux PORT MAP (
          clk => clk,
          rst => rst,
          go => go,
          done => done,
          data_in => data_in,
          data_out => data_out,
          dir => dir,
          busy => busy,
          rd => rd,
          wr => wr,
          txe => txe,
          rxf => rxf,
       --   ftdi_data => ftdi_data
			ftdi_din => ftdi_din,
			ftdi_dout => ftdi_dout
        );

   -- Clock process definitions
	
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	error_checking_proc: process
	begin
		wait until go = '1';
		if busy = '1' then
			assert rxf='1' and rd='0'
				report "RXE high and rd low" SEVERITY error;
			assert txe = '1' and wr='0'
				report "TXE high and wr low" SEVERITY error;
		end if;
				
	
	end process;
	rand_proc: process
	begin
		wait for clk_period * 2;
		rxf <= '1';
		wait for clk_period * 1;
		txe<= '1';
		wait for clk_period * 7;
		txe <= '0';
		wait for clk_period * 3;
		rxf <= '0';
		wait for clk_period * 9;
		rxf <= '1';
		txe <= '1';
		wait for clk_period * 2.5;
		rxf <= '0';
		txe <= '0';
	end process;
   -- Stimulus process
   stim_proc: process
   begin		
		rst <= '0';
		wait for 5*clk_period;
		rst <= '1';
		go <= '0';
	--	rxf <= '0';
	--	txe <= '0';
		wait for clk_period*3;
		--Read sequence
		ftdi_din <= "10101010";	
		dir <= '1'; 
		wait for clk_period;
		go <= '1';
		wait for clk_period*2;
		go <= '0';
		wait until done ='0' and busy='0';
		--go <= '0';
		wait for 5*clk_period;
	--	ftdi_data <= "ZZZZZZZZ";
		data_in <= "11111010";
		dir <= '0';
		wait for clk_period;
		go <= '1';
		wait for clk_period;
		go <= '0';
		wait until done = '1';
		wait for 10* clk_period;

      -- insert stimulus here 

      wait;
   end process;

END;
