----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:47:54 09/23/2012 
-- Design Name: 
-- Module Name:    usb_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity usb_controller_mux is
    Port ( 	clk : in STD_LOGIC;
				rst: in STD_LOGIC;
				go : in  STD_LOGIC;
				done : out  STD_LOGIC;
				data_in : in STD_LOGIC_VECTOR(7 downto 0);
				data_out : out STD_LOGIC_VECTOR(7 downto 0);
				dir : in  STD_LOGIC;
				busy : out STD_LOGIC;
				rd : out STD_LOGIC;
				wr : out STD_LOGIC;
				txe : in STD_LOGIC;
				rxf : in STD_LOGIC;
				--ftdi_data : inout STD_LOGIC_VECTOR(7 downto 0) --Data to ftdi chip		
				ftdi_dout : out STD_LOGIC_VECTOR(7 downto 0);
				ftdi_din	 : in STD_LOGIC_VECTOR(7 downto 0)
			  
			  );
end usb_controller_mux;

architecture Behavioral of usb_controller_mux is
signal ustate : integer range 0 to 31;
signal int_dir: STD_LOGIC;
signal int_data : STD_LOGIC_VECTOR(7 downto 0);
--signal ftdi_din, ftdi_dout : STD_LOGIC_VECTOR(7 downto 0);

begin

--ftdi_dout <= int_data when int_dir = '0' else "00000000";
--int_data <= ftdi_din when int_dir = '1' else "00000000";

data_out <= int_data when int_dir = '1' else "00000000";
--ftdi_data <= ftdi_dout when int_dir = '0' else "ZZZZZZZZ";
--ftdi_din <= ftdi_data when int_dir = '1' else "00000000";
process(clk) is
begin
	if(rising_edge(clk)) then
		if(rst = '0') then
			ustate<= 0;
			rd <= '1';
			wr <= '1';
			done <= '0';
			busy <= '0';
			int_data <= "00000000";
		else
			case ustate is
				when 0=>
					rd <= '1';
					wr <= '1';
					done <= '0';	
					busy <= '0';
					if(go = '1') then
						busy <= '1';
						int_dir <= dir;
						ustate <= ustate + 1;
					else
						null;
					end if;
				when 1=>
					if(int_dir = '1') then --read
						ustate <= ustate + 1;
					else
						int_data <= data_in;
						ustate <= ustate + 17;
					end if;
				when 2=>
					if(rxf = '0') then
						ustate <= ustate + 1;
					else
						null;
					end if;
				when 3=> --rxf == 0
					rd <= '0'; --drop read line low
					ustate <= ustate + 1; -- delay 20 ns (assuming 10 ns clk)
				when 6=>
					int_data <= ftdi_din;
					ustate <= ustate + 1; --delay 30 more ns
				when 9=>
					rd <= '1';
					done <= '1';
					ustate <= ustate + 1;	--delay 50 ns
				when 14=>					
					ustate <= 0;
					done <= '0';
					busy <= '0';
				when 18=> -- write sequence
					if(txe = '0') then
						ustate <= ustate + 1;
					else
						null;
					end if;
				when 19=>
					ftdi_dout <= int_data;
					ustate <= ustate + 1;
				when 21=>
					wr <= '0';
					ustate <= ustate + 1;
				when 26=>
					wr <= '1';
					done <= '1';
					ustate <= ustate + 1;
				when 27=>
					ustate <= 0;
					busy <= '0';
				when others=>
					ustate <= ustate + 1;
			end case;
					
		end if;
	end if;
end process;


--Commented out because we must do this at the top level
--	 inst_IOBUF8 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(0),   -- Buffer output
--      IO => ftdi_data(0),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(0),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF9 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(1),   -- Buffer output
--      IO => ftdi_data(1),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(1),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF10 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(2),   -- Buffer output
--      IO => ftdi_data(2),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(2),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF11 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(3),   -- Buffer output
--      IO => ftdi_data(3),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(3),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF12 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(4),   -- Buffer output
--      IO => ftdi_data(4),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(4),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF13 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(5),   -- Buffer output
--      IO => ftdi_data(5),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(5),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF14 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(6),   -- Buffer output
--      IO => ftdi_data(6),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(6),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--   );
--   inst_IOBUF15 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => ftdi_din(7),   -- Buffer output
--      IO => ftdi_data(7),    -- Buffer inout port (connect directly to top-level port)
--      I => ftdi_dout(7),  -- Buffer input
--      T => int_dir       -- 3-state enable input 
--  );	
end Behavioral;

