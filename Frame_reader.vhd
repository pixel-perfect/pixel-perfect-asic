library IEEE;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Frame_reader is
    Port ( 	clk 	: in  STD_LOGIC;	
				rst 	: in  STD_LOGIC;			
				frame_en : in STD_LOGIC;
				frame_end : out std_logic;
				frame_ready: out std_logic;
				data_available : out STD_LOGIC;
				usb_busy : in STD_LOGIC;
				---- USB ports
				dout 		: out  STD_LOGIC_VECTOR (7 downto 0);
				--END USB stuff
				rdec_clk		:out  STD_LOGIC;
				rdec_rst		:out  STD_LOGIC;
				row_rst		:out  STD_LOGIC;
				row_sel		:out  STD_LOGIC;
				row_boost	:out  STD_LOGIC;
				reg_p23		:in	STD_LOGIC_VECTOR(7 downto 0);
				reg_p24		:in	STD_LOGIC_VECTOR(7 downto 0);
				--
				cdec_clk		:out  STD_LOGIC;
				cdec_rst		:out  STD_LOGIC;
				col_vln_casc:out  STD_LOGIC;
				col_sh		:out  STD_LOGIC;
				amp_rst		:out  STD_LOGIC;
				comp_rst1	:out  STD_LOGIC;
				comp_rst2	:out  STD_LOGIC;
				coldata 		:in   STD_LOGIC_VECTOR (9 downto 0);
				---	
				i2c_in1		:out  STD_LOGIC;
				---
				wat0		:out  STD_LOGIC;
				wat1		:out  STD_LOGIC;
				watout	:in   STD_LOGIC;
				--
				adc_clk	:out  STD_LOGIC;
				adc_jump	:out  STD_LOGIC;
				adc_done	:in   STD_LOGIC;
				ramp_rst	:out  STD_LOGIC;
				ramp_set	:out  STD_LOGIC
				);
end Frame_reader;

	

architecture Behavioral of Frame_reader is

	


	signal fjump		: STD_LOGIC;

	-------- Counter signals
	signal fps_cnt,fps_cnt_buf :STD_LOGIC_VECTOR (23 downto 0);	
	signal fps_cnt_en,fps_cnt_stop: STD_LOGIC;	
	signal adc_cnt :STD_LOGIC_VECTOR (15 downto 0);	
	signal adc_cnt_en,adc_cnt_stop: STD_LOGIC;		
	-------- Frame reader signals
	signal trip: STD_LOGIC;	
	signal fstate  : integer range 0 to 4095:=0;
	signal rowptr,colptr : integer range 0 to 255:=0;
	signal pstep,rstep : integer range 0 to 31:=0;
	signal fwr:STD_LOGIC;
	--signal fdout:STD_LOGIC_VECTOR (7 downto 0);
	signal cycle_cnt,cdata:STD_LOGIC_VECTOR (9 downto 0);
	
	COMPONENT FPS_Counter
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		fps_cnt_en : IN std_logic;
		fps_cnt_stop : IN std_logic;          
		fps_cnt : OUT std_logic_vector(23 downto 0)
		);
	END COMPONENT;
	COMPONENT ADC_Counter
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		adc_cnt_en : IN std_logic;
		adc_cnt_stop : IN std_logic;          
		adc_cnt : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
begin

Inst_FPS_Counter: FPS_Counter PORT MAP(
		clk => clk,
		rst => rst,
		fps_cnt_en => fps_cnt_en,
		fps_cnt_stop => fps_cnt_stop,
		fps_cnt => fps_cnt
	);
	
Inst_ADC_Counter: ADC_Counter PORT MAP(
	clk => clk,
	rst => rst,
	adc_cnt_en => adc_cnt_en,
	adc_cnt_stop => adc_cnt_stop,
	adc_cnt => adc_cnt
);





Frame_FSM: process (clk,rst,frame_en,adc_cnt,fps_cnt,reg_p23) is
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
			fstate<=0;
			---
			frame_end	<='0';
			frame_ready	<='0';
			fwr		<='1';
			dout		<="00000000";
			rowptr	<=0;
			colptr	<=0;	
			trip		<='1';
			------
			i2c_in1<='0';
			rdec_clk		<='0';
			rdec_rst		<='0';
			row_rst		<='0';
			row_sel		<='0';
			row_boost	<='0';
			cdec_clk		<='0';
			cdec_rst		<='0';
			col_vln_casc<='0';
			col_sh		<='0';
			amp_rst		<='0';
			comp_rst1	<='0';
			comp_rst2	<='0';
			wat0		<='0';
			wat1		<='0';
			adc_clk	<='0';
			adc_jump	<=reg_p23(3);
			ramp_rst	<='0';
			ramp_set	<='0';
			--
			adc_cnt_en 		<='0';
			adc_cnt_stop	<='0';
			fps_cnt_en 		<='0';
			fps_cnt_stop	<='0';	
			fps_cnt_buf<="000000000000000000000000";	
			pstep<=1;			
			rstep<=1;
			fjump	<='0';
			data_available <= '0';
		else --if (reg_p23(4)='1') then
			---------------------------------------------------------------------------------------------
			--- FRAME Reader Operation
			---------------------------------------------------------------------------------------------			
			case fstate is
				when  0=>	frame_ready	<='1';	--- ready to sent frame to USB
								frame_end	<='0'; 	--- not end of frame
								rowptr		<=0;
								colptr		<=0;	
								trip		<='1';
								---
								i2c_in1		<='0';
								rdec_clk		<='0';
								rdec_rst		<='1';
								row_rst		<='0';
								row_sel		<='0';
								row_boost	<='0';
								cdec_clk		<='0';
								cdec_rst		<='0';
								col_vln_casc<='1';
								col_sh		<='0';
								amp_rst		<='0';
								comp_rst1	<='0';
								comp_rst2	<='0';
								adc_clk		<='0';
								ramp_rst		<='1';
								ramp_set		<='0';
								adc_jump		<=reg_p23(3);
								----
								adc_cnt_en 	<='0';
								adc_cnt_stop<='0';
								fps_cnt_en 	<='0';
								fps_cnt_stop<='0';
								fwr			<='1';
								dout(7 downto 0)<="00000000";
								fps_cnt_buf<="000000000000000000000000";
								wat0		<='0';
								wat1		<='0';
								---
								if    ((reg_p23(7)='0') and (reg_p23(6)='0')) then pstep<=1;
								elsif ((reg_p23(7)='0') and (reg_p23(6)='1')) then pstep<=4;
								elsif ((reg_p23(7)='1') and (reg_p23(6)='0')) then pstep<=8;
								else pstep<=12; end if;
								---
								---
								if    ((reg_p24(5)='0') and (reg_p24(5)='0')) then rstep<=1;fjump<='0';
								elsif ((reg_p24(5)='0') and (reg_p24(5)='1')) then rstep<=2;fjump<='0';
								elsif ((reg_p24(5)='1') and (reg_p24(5)='0')) then rstep<=3;fjump<='0';
								else rstep<=1; fjump<='1';end if;
								---								
								fstate<=fstate+1;
				when 	 6=>	i2c_in1	<='1';
								fps_cnt_en 	<='1'; -- start FPS counter
								fstate<=fstate+1;								
				when 	 9=>	rdec_rst	<='0'; 
								frame_ready	<='0';--- missed frame sent, wait next frame time
								fstate<=fstate+1;
				-------------------------------------
				--- Row repeat return point
				-------------------------------------	
				when  13=>	ramp_set		<='0';
								rdec_clk		<='1';
								trip		<='1';
								col_vln_casc<='1';
								fstate<=fstate+1;				
				when 	16=>	dout(7 downto 0)<="00000000";
								i2c_in1	<='0';
								rdec_clk	<='0';
								row_sel	<='1';
								cdec_rst		<='1';
								col_sh		<='1';
								amp_rst		<='1';
								comp_rst1	<='1';
								comp_rst2	<='1';
								ramp_rst		<='1';
								fwr			<='1';
								fstate<=fstate+1;	
				when  20=>	cdec_rst		<='0';
						      if (fjump='0') then	fstate<=fstate+1;	
								else fstate<=fstate+16;end if;
				when 	48=>	comp_rst2	<='0';
								fstate<=fstate+1;								
				when 	64=>	comp_rst1	<='0';
								fstate<=fstate+1;	
				when  88=>	amp_rst		<='0';
								row_rst		<='1';
								if (fjump='0') then	fstate<=fstate+1;	
								else fstate<=fstate+24;	end if;									
				when  103=>	if (reg_p24(3)='1') then 
									row_boost	<='1';
								else
									row_boost	<='0';
								end if;
								fstate<=fstate+1;
				when 120=>	row_boost	<='0';				
								fstate<=fstate+1;	
				when 156=>	col_sh		<='0';
								fstate<=fstate+1;	
				when 159=>	adc_cnt_en 	<='1';-- runs ADC counter 
								adc_cnt_stop 	<='0';
								fwr			<='1';
								dout			<="00000000";
								cycle_cnt	<="0000000000";
								fstate<=fstate+1;		
				-------------------------------------
				--- ADC repeat return point
				-------------------------------------															
				when 160=>	col_vln_casc<='0';
								row_rst		<='0';
								row_sel		<='0';
								adc_clk 		<='0';
								fstate<=fstate+pstep;	
				when 173=>	ramp_rst		<='0';
								fstate<=fstate+1;	
				when 176=>	adc_clk		<='1';
								fstate<=fstate+pstep;	
				when 191=>	adc_clk		<='1';
								if ((adc_done='1') OR (cycle_cnt="1111111111")) then 	
									adc_cnt_stop 	<='1';
									fstate<=fstate+1;	
								else 	cycle_cnt<=cycle_cnt+1; 
									fstate<=160;	
								end if;
				-------------------------------------
				--- Sent ADC counter/speed to USB2
				-------------------------------------								
				when 192=>	dout(7 downto 0)	<=adc_cnt(7 downto 0);
								data_available <= '1';
								adc_clk		<='0';
								if (reg_p23(4)='1') then trip<='0'; end if;---shot down IDAC
								fwr			<='1';
								fstate<=fstate+1;	
			--	when 193=>
			--					 fstate <= fstate + 1;
				when 194=>	if (frame_en='1') then fwr<='0';	end if;
								data_available <= '0';
								fstate<=fstate+1;	
				when 196=>	dout(7 downto 0)	<=adc_cnt(15 downto 8);
								
								fwr			<='1';
								if(usb_busy = '1') then
									null;
								else
									data_available <= '1';
									fstate<=fstate+1;	
								end if;
		--		when 197=>  fstate <= fstate + 1;
				when 198=>	if (frame_en='1') then fwr<='0';	end if;
								data_available <= '0';
								i2c_in1		<='1';
								colptr		<=0;
								cdec_clk<='0';
								adc_cnt_stop 	<='0'; -- runs ADC counter (BUT if adc_cnt_en=0, it resets it) 
								adc_cnt_en 		<='0'; -- resets ADC counter
								fstate<=fstate+1;	
				-------------------------------------
				--- Column read return point
				-------------------------------------								
				when 200=>	if (frame_en='1') then fwr<='0';	end if;
								cdec_clk		<='1';
								ramp_set		<='1';
								fstate<=fstate+rstep;
				when 203=>	dout(7 downto 0)	<=coldata(9 downto 2); --sent upper 8bit
								fwr<='1';
								fstate<=fstate+rstep;	
				when 204=>
								if(usb_busy = '1') then
									null;
								else
									data_available <= '1'; 
									fstate <= fstate + 1;
								end if;
				when 206=>	--if (frame_en='1') then fwr<='0';	end if;
								data_available <= '0';
								cdec_clk	<='0';
								i2c_in1<='0';
								fstate<=fstate+rstep;
				when 209=>	fwr<='1';
								fstate<=fstate+rstep;					
				when 212=>	fwr<='1';
								if (colptr=199) then	fstate<=fstate+1;	
								else 	colptr<=colptr+1;
									fstate<=199;
								end if;
				-------------------------------------
				--- check frame range
				-------------------------------------								
				when 213=>	if (frame_en='1') then fwr<='0';	end if;
								fstate<=fstate+1;	
								ramp_set		<='1';
								--amp_rst		<='1'; ---added here
								fps_cnt_buf<=fps_cnt;
				when 214=>	if (rowptr=149) then		
									--if (fps_cnt(23 downto 0)="010100111100000101000000") then
									if ((fps_cnt(23 downto 0)="010100010100000000000000") or reg_p23(5)='1') then
									-- to get same IT even speed  up achieved for SSLAR operation
									-- Problem: Need to power down some blocks. Power consumption becomes erradic.
									  fps_cnt_stop<='1';-- stops frame counter
									  col_vln_casc<='1';
									  fstate<=fstate+1;
									  trip		<='1'; ---turnon down IDAC
									end if;
								else
									rowptr<=rowptr+1;
									trip		<='1'; ---turnon down IDAC
									fstate<=8;	
								end if;
				-------------------------------------
				--- END OF FRAME - Sent FPS counter/speed to USB2
				-------------------------------------								
				when 215=>	dout(7 downto 0)	<=fps_cnt_buf(7 downto 0);
								fwr			<='1';
								fstate<=fstate+1;	
				when 218=>	if (frame_en='1') then fwr<='0';	end if;
								fstate<=fstate+1;	
				when 221=>	dout(7 downto 0)	<=fps_cnt_buf(15 downto 8);
								fwr			<='1';
								fstate<=fstate+1;	
				when 224=>	if (frame_en='1') then fwr<='0';	end if;
								fstate<=fstate+1;	
				when 227=>	dout(7 downto 0)	<=fps_cnt_buf(23 downto 16);
								fwr			<='1';
								fstate<=fstate+1;	
				when 230=>	if (frame_en='1') then fwr<='0';	end if;
								fstate<=fstate+1;	
				when 232=>	fwr			<='1';
								frame_end	<='1'; -- end of frame
								fstate<=fstate+1;	
				when 233=>	frame_end	<='0'; -- not end of frame
								frame_ready	<='1'; -- frame ready
								fstate<=fstate+1;	
				when 234=>	fps_cnt_stop<='0'; -- runs frame counter (but)
								fps_cnt_en 	<='0'; -- resets frame counter
								fstate<=0;
				-------------------------------------
				when others=> fstate<=fstate+1;
			end case;
		end if;
	end if;
end process Frame_FSM;
end Behavioral;