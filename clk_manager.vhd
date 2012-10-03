----------------------------------------------------------------------------------
-- Daniel Mazo
-- Create Date:    10:41:56 09/24/2012 
-- Module Name:    clk_manager - Behavioral

-- Description:
-- This VHDL process will take a CLK_MAX as an input and then divide it down
-- into 3 "smaller" clock signals. Then a 4:1 MUX will select the appropriate
-- "slower clock" to send off to other processes.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_manager is
	Port(	clk_max	:	in	STD_LOGIC;
			rst		:	in STD_LOGIC;
			sel		:	in STD_LOGIC_VECTOR(1 downto 0);
			clk_out	:	out STD_LOGIC);
end clk_manager;

architecture Behavioral of clk_manager is
-- SIGNALS
type statetype is (s0,s1,s2,s3,s4,s5,s6);
signal state, nextstate : statetype;
signal clk_2,clk_4,clk_6 : STD_LOGIC;

begin
	-- state register
	process (clk_max,rst)
	begin
		if rst = '1' then state <= s0;
		elsif clk_max'event and clk_max = '1' then state <= nextstate;
		end if;	
		
	end process;
	
	-- next state logic
	nextstate <= s1 when state = s0 else
					 s2 when state = s1 else
					 s3 when state = s2 else
					 s4 when state = s3 else
					 s5 when state = s4 else
					 s6 when state = s5 else
					 s0;
					 
	-- output logic
	clk_2 <= '1' when state = s2 else '0';
	clk_4 <= '1' when state = s4 else '0';
	clk_6 <= '1' when state = s6 else '0';

	-- MUX Process
	with sel select clk_out <=
		clk_2 when "00",
		clk_4 when "01",
		clk_6 when "10",
		'0' when others;

end Behavioral;

