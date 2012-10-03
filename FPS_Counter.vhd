----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:16 09/23/2012 
-- Design Name: 
-- Module Name:    FPS_Counter - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FPS_Counter is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           fps_cnt_en : in  STD_LOGIC;
           fps_cnt_stop : in  STD_LOGIC;
           fps_cnt : out  STD_LOGIC_VECTOR (23 downto 0));
end FPS_Counter;

architecture Behavioral of FPS_Counter is
signal int_fps_cnt : STD_LOGIC_VECTOR (23 downto 0);
begin

fps_cnt <= int_fps_cnt;
FPS_counter: process (clk,rst,fps_cnt_en,fps_cnt_stop) is
begin
	if (clk'event and clk='1') then
		if (rst='0') then
			int_fps_cnt<="000000000000000000000000";
		else
			if ((fps_cnt_en='1') AND(fps_cnt_stop='0')) then 
				int_fps_cnt<=int_fps_cnt+1;
			elsif ((fps_cnt_en='1') AND(fps_cnt_stop='1')) then 
				null;				
			else
				int_fps_cnt<="000000000000000000000000";
			end if;
		end if;
	end if;		
end process FPS_counter; 	



end Behavioral;

