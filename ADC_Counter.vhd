----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:09:25 09/23/2012 
-- Design Name: 
-- Module Name:    ADC_Counter - Behavioral 
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

entity ADC_Counter is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           adc_cnt_en : in  STD_LOGIC;
           adc_cnt_stop : in  STD_LOGIC;
           adc_cnt : out  STD_LOGIC_VECTOR (15 downto 0));
end ADC_Counter;

architecture Behavioral of ADC_Counter is
signal int_adc_cnt : STD_LOGIC_VECTOR(15 downto 0);
begin
adc_cnt <= int_adc_cnt;

ADC_counter: process (clk,rst,adc_cnt_en,adc_cnt_stop) is
begin
	if (clk'event and clk='1') then
		if (rst='0') then
			int_adc_cnt<="0000000000000000";
		else
			if ((adc_cnt_en='1') AND(adc_cnt_stop='0')) then 
				int_adc_cnt<=int_adc_cnt+1;
			elsif ((adc_cnt_en='1') AND(adc_cnt_stop='1')) then 
				null;				
			else
				int_adc_cnt<="0000000000000000";
			end if;
		end if;
	end if;		
end process ADC_counter; 

end Behavioral;

