----------------------------------------------------------------------------------
-- Create Date:    
-- Design Name: 
-- Module Name:    sslar2_test5_8bit- Behavioral 
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity sslar2_test5_8bit is
    Port ( 	clk 	: in  STD_LOGIC;	
				rst 	: in  STD_LOGIC;	
				led1 	: out  STD_LOGIC;
				led2 	: out  STD_LOGIC;
				led3 	: out  STD_LOGIC;				
				---- USB ports
				txe 	: in  STD_LOGIC;	
				rxf 	: in  STD_LOGIC;
				wr 	: out  STD_LOGIC;	
				rd 	: out  STD_LOGIC;
				d 		: inout  STD_LOGIC_VECTOR (7 downto 0);
				---- memory ports				
				--mdata			:inout  STD_LOGIC_VECTOR (15 downto 0);
				--maddr 		:out    STD_LOGIC_VECTOR (15 downto 0);
				--mce			:out  STD_LOGIC;
				--mwe			:out  STD_LOGIC;
				--mbe			:out  STD_LOGIC;
				------------
				rdec_clk		:out  STD_LOGIC;
				rdec_rst		:out  STD_LOGIC;
				row_rst		:out  STD_LOGIC;
				row_sel		:out  STD_LOGIC;
				row_boost	:out  STD_LOGIC;
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
				ref_pwron	:out  STD_LOGIC;
				---
				i2c_rstb		:out  STD_LOGIC;
				i2c_clk		:out  STD_LOGIC;
				i2c_in		:out  STD_LOGIC;
				---
				wat0		:out  STD_LOGIC;
				wat1		:out  STD_LOGIC;
				watout	:in   STD_LOGIC;
				--
				adc_clk	:out  STD_LOGIC;
				adc_jump	:out  STD_LOGIC;
				adc_done	:in   STD_LOGIC;
				ramp_rst	:out  STD_LOGIC;
				ramp_set	:out  STD_LOGIC;
				---
				pdac_clk	:out  STD_LOGIC; 
				pdac_sin	:out  STD_LOGIC;
				pdac_sync:out  STD_LOGIC);
end sslar2_test5_8bit;

architecture Behavioral of sslar2_test5_8bit is
	-- program registers
	signal reg_p1   :STD_LOGIC_VECTOR (7 downto 0):="10011011";
	signal reg_p2   :STD_LOGIC_VECTOR (7 downto 0):="00110000";
	signal reg_p3   :STD_LOGIC_VECTOR (7 downto 0):="10011011";
	signal reg_p4   :STD_LOGIC_VECTOR (7 downto 0):="00110000";
	signal reg_p5   :STD_LOGIC_VECTOR (7 downto 0):="10000000";
	signal reg_p6   :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p7   :STD_LOGIC_VECTOR (7 downto 0):="10000000";
	signal reg_p8   :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p9   :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p10  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p11  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p12  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p13  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p14  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p15  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p16  :STD_LOGIC_VECTOR (7 downto 0):="00011011";	
	signal reg_p17  :STD_LOGIC_VECTOR (7 downto 0):="00011110";
	signal reg_p18  :STD_LOGIC_VECTOR (7 downto 0):="00010000";
	signal reg_p19  :STD_LOGIC_VECTOR (7 downto 0):="00100000";
	signal reg_p20  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p21  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p22  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal reg_p23  :STD_LOGIC_VECTOR (7 downto 0):="00010100";
	signal reg_p24  :STD_LOGIC_VECTOR (7 downto 0):="00000010";
	signal reg_p25  :STD_LOGIC_VECTOR (7 downto 0):="00000000";
	signal data_buff1 : STD_LOGIC_VECTOR( 7 downto 0);
	-------- Main FSM signals
	signal dir		:STD_LOGIC;
	signal din,dout,dbuf:STD_LOGIC_VECTOR (7 downto 0);
	signal ustate 	: integer range 0 to 31:=0;
	signal reg_ptr : integer range 0 to 63:=0;	
	signal cstate : integer range 0 to 63 := 0;
	-----
	signal mdin,mdout:STD_LOGIC_VECTOR (15 downto 0);
	signal mdir,fjump		: STD_LOGIC;
	-------- IDAC signal
	signal idacstate  : integer range 0 to 511:=0;
	signal idac_update_en,idac_busy:STD_LOGIC;
	signal i2c_in1		: STD_LOGIC;
	-------- PDAC signals
	signal pdacstate,dacstate : integer range 0 to 127:=0;
	signal pdac_update_en,pdac_busy:STD_LOGIC;
	signal pdac_data 	:STD_LOGIC_VECTOR (23 downto 0);	
	-------- Counter signals
	signal fps_cnt,fps_cnt_buf :STD_LOGIC_VECTOR (23 downto 0);	
	signal fps_cnt_en,fps_cnt_stop: STD_LOGIC;	
	signal adc_cnt :STD_LOGIC_VECTOR (15 downto 0);	
	signal adc_cnt_en,adc_cnt_stop: STD_LOGIC;		
	-------- Frame reader signals
	signal i2c_in2,tbs,trip: STD_LOGIC;	
	signal fstate  : integer range 0 to 4095:=0;
	signal rowptr,colptr : integer range 0 to 255:=0;
	signal pstep,rstep : integer range 0 to 31:=0;
	signal frame_en,frame_end,frame_ready,fwr,frd,crd,cwr:STD_LOGIC;
	--signal fdout:STD_LOGIC_VECTOR (7 downto 0);
	signal cycle_cnt,cdata:STD_LOGIC_VECTOR (9 downto 0);
	
		

	COMPONENT usb_controller_mux
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		go : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		dir : IN std_logic;
		txe : IN std_logic;
		rxf : IN std_logic;    
		--ftdi_data : INOUT std_logic_vector(7 downto 0);    
		ftdi_dout : OUT STD_LOGIC_VECTOR(7 downto 0);
		ftdi_din : IN STD_LOGIC_VECTOR(7 downto 0);
		done : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0);
		busy : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic
		);
	END COMPONENT;
	COMPONENT Frame_reader
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		usb_busy : IN std_logic;
		frame_en : IN std_logic;
		coldata : IN std_logic_vector(9 downto 0);
		watout : IN std_logic;
		adc_done : IN std_logic;          
		frame_end : OUT std_logic;
		reg_p23		:in	STD_LOGIC_VECTOR(7 downto 0);
		reg_p24		:in	STD_LOGIC_VECTOR(7 downto 0);
		frame_ready : OUT std_logic;
		data_available : OUT std_logic;
		dout : OUT std_logic_vector(7 downto 0);
		rdec_clk : OUT std_logic;
		rdec_rst : OUT std_logic;
		row_rst : OUT std_logic;
		row_sel : OUT std_logic;
		row_boost : OUT std_logic;
		cdec_clk : OUT std_logic;
		cdec_rst : OUT std_logic;
		col_vln_casc : OUT std_logic;
		col_sh : OUT std_logic;
		amp_rst : OUT std_logic;
		comp_rst1 : OUT std_logic;
		comp_rst2 : OUT std_logic;
		i2c_in1 : OUT std_logic;
		wat0 : OUT std_logic;
		wat1 : OUT std_logic;
		adc_clk : OUT std_logic;
		adc_jump : OUT std_logic;
		ramp_rst : OUT std_logic;
		ramp_set : OUT std_logic
		);
	END COMPONENT;
	

	--USB FSM Signals
	
	signal usb_go, usb_done, usb_busy, usb_dir : STD_LOGIC;
	signal usb_data_in, usb_data_dout : STD_LOGIC_VECTOR(7 downto 0);
	signal ftdi_dout, ftdi_din : STD_LOGIC_VECTOR(7 downto 0);
	signal data_available : STD_LOGIC;
	signal frame_data : STD_LOGIC_VECTOR(7 downto 0);

begin

i2c_in<=((i2c_in1) OR (i2c_in2));
led1<=reg_p22(0);
led2<=reg_p22(1);
led3<=reg_p22(2);
--rd<=(frd);
--wr<=(fwr OR cwr);
Inst_usb_controller_mux: usb_controller_mux PORT MAP(
		clk => clk,
		rst => rst,
		go => usb_go,
		done => usb_done,
		data_in => dout,
		data_out => din,
		dir => dir,
		busy => usb_busy,
		rd => rd,
		wr => wr,
		txe => txe,
		rxf => rxf,
		ftdi_dout => ftdi_dout,
		ftdi_din => ftdi_din
	);


Inst_Frame_reader: Frame_reader PORT MAP(
		clk => clk,
		rst => rst,
		usb_busy => usb_busy,
		reg_p23=> reg_p23,
		reg_p24	=> reg_p24,
		frame_en => frame_en,
		frame_end => frame_end,
		frame_ready => frame_ready,
		data_available => data_available,
		dout => frame_data,
		rdec_clk => rdec_clk ,
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
		coldata => coldata ,
		i2c_in1 => i2c_in1 ,
		wat0 => wat0,
		wat1 => wat1,
		watout => watout,
		adc_clk => adc_clk,
		adc_jump => adc_jump,
		adc_done => adc_done,
		ramp_rst => ramp_rst,
		ramp_set => ramp_set
	);
	
-----------------------------------------------------------------------------
--- USB Communication Finite State Machine (FSM) 	
--- This process handles the communication protocol designed for this test/
--- demo board.It uses the timing of FTDI 2223D chip set timing and DLP-FPGA
--- board from DLP Design Inc. (www.dlpdesign.com)
-----------------------------------------------------------------------------
USB_FSM : process (clk,rst,txe,rxf,dout,frame_end,frame_ready,pdac_busy,idac_busy) is
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
		--	rd	<='1'; 
		--	cwr	<='1';
			dir<= '1'; --1=read from USB/PC, 0=write to USB/PC			
			ustate	<=0;
			reg_ptr  <=0;
			usb_go <= '0';
		--	dout <= "00000000";
			---
			reg_p1   <="10011011";
			reg_p2   <="00110000";
			reg_p3   <="10011011";
			reg_p4   <="00110000";
			reg_p5   <="10000000";
			reg_p6   <="00000000";
			reg_p7   <="10000000";
			reg_p8   <="00000000";
			reg_p9   <="00000000";
			reg_p10  <="00000000";
			reg_p11  <="00000000";
			reg_p12  <="00000000";
			reg_p13  <="00000000";
			reg_p14  <="00000000";
			reg_p15  <="00000000";
			reg_p16  <="00011011";	
			reg_p17  <="00011110";
			reg_p18  <="00010000";
			reg_p19  <="00100000";
			reg_p20  <="00000000";
			reg_p21  <="00000000";
			reg_p22  <="00000000";
			reg_p23  <="00010100";
			reg_p24  <="00000010";
			reg_p25  <="00000000";
			data_buff1 <= "00000000";
			---
			pdac_data		<="000000000000000000000000";
			pdac_update_en	<='0';
			--
			frame_en			<='0';
			idac_update_en	<='0';
		else
			case ustate is  
				-------------------------------------------------------
				--- main listening rutine
				-------------------------------------------------------
				when 0 => --wait for a read command
					
					if(usb_busy = '1') then
						null;
					else
						usb_go <= '1';
						dir <= '1';
						ustate <= ustate + 1;
					end if;
--					dir<= '1'; --1=read from USB/PC, 0=write to USB/PC
--					rd<='1';	
--					cwr<='1';					
--					if (rxf='0') then	ustate<=ustate+1; else	null;	end if;
				when 2 => 
				--	rd<='0';		
				--	cwr<='1';	
					usb_go <= '0';
					if(frame_ready = '1') then
								frame_en <= '1';
							end if;
					if(usb_done = '1') then
						if 	(din="11111111") then ustate<=8;	-- FF means update program registers and DAC
						elsif (din="00001111") then 
							ustate<=18;	-- 0F means go directly the frame read
							
						else ustate <= 0; end if;
					else
						null;
					end if;
					--ustate<=ustate+1;
				when 6 => 
					if(usb_done = '1' or usb_busy = '0') then
						if 	(dout="11111111") then ustate<=8;	-- FF means update program registers and DAC
						elsif (dout="00001111") then 
							ustate<=18;	-- 0F means go directly the frame read					
						else ustate <= 0; end if;
					else
						null;
					end if;									
			--	when 7 => 
				--	rd<='1';		
				--	cwr<='1';	
				--	reg_ptr<=0;
				--	if 	(din="11111111") then ustate<=8;	-- FF means update program registers and DAC
				--	elsif (din="00001111") then ustate<=18;	-- 0F means go directly the frame read
					--elsif (dout="11110000") then ustate<=12;	-- F0 RAMP TEST			
				--	else ustate<=0;
				--	end if;
				-------------------------------------------------------	
				---- PDAC and IDAC update rutine	for data=FF
				-------------------------------------------------------
				when 8 => 	
								pdac_update_en <= '0';
								idac_update_en <= '0';
								if(usb_busy = '0' or usb_done = '1') then
									dir <= '1';
									usb_go <= '1';
									ustate <= ustate + 1;
								else
									null;
								end if;
--								dir<= '1'; --1=read from USB/PC, 0=write to USB/PC
--								pdac_update_en<='0'; 
--								idac_update_en<='0';
--								if (rxf='0') then	ustate<=ustate+1;	else rd<='1';	cwr<='1';	end if;
		--		when 11 => 
--								rd<='0';	
--								cwr<='1';	
----								ustate<=ustate+1;
				when 9 => 	case reg_ptr is--- get 25 program  data
--									--Update PDAC Channel A
									when 0=>		if(usb_done = '1') then reg_p1<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
									when 1=>		if(usb_done = '1') then reg_p2<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p2<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 2=>		pdac_data(15 downto 8)	<=reg_p1(7 downto 0);
													pdac_data(7 downto 0) 	<=reg_p2(7 downto 0);
													pdac_data(23 downto 16)	<="10011000"; 
													pdac_update_en<='1';-- request PDAC update, ChA
													reg_ptr<=reg_ptr+1;
									when 3=>		reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
									when 4=>		if pdac_busy='1' then reg_ptr<=reg_ptr+1; end if;
									when 5=>		if pdac_busy='0' then pdac_update_en<='0';reg_ptr<=reg_ptr+1; 	ustate<=8;end if;								
									--Update PDAC Channel B
									when 6=>		if(usb_done = '1') then reg_p3<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p3<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 7=>		if(usb_done = '1') then reg_p4<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
												--	reg_p4<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 8=>		pdac_data(15 downto 8)	<=reg_p3(7 downto 0);
													pdac_data(7 downto 0) 	<=reg_p4(7 downto 0);
													pdac_data(23 downto 16)	<="10011001"; 
													pdac_update_en<='1';-- request PDAC update, ChB
													reg_ptr<=reg_ptr+1;
									when 9=>		reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
									when 10=>	if pdac_busy='1' then reg_ptr<=reg_ptr+1; end if;
									when 11=>	if pdac_busy='0' then pdac_update_en<='0';reg_ptr<=reg_ptr+1; 	ustate<=8;end if;	
									--Update PDAC Channel C
									when 12=>	if(usb_done = '1') then reg_p5<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p5<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 13=>	if(usb_done = '1') then reg_p6<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p6<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 14=> 	pdac_data(15 downto 8)	<=reg_p5(7 downto 0);
													pdac_data(7 downto 0) 	<=reg_p6(7 downto 0);
													pdac_data(23 downto 16)	<="10011010";
													pdac_update_en<='1';-- request PDAC update, ChC
													reg_ptr<=reg_ptr+1;
									when 15=>	reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
									when 16=>	if pdac_busy='1' then reg_ptr<=reg_ptr+1; end if;
									when 17=>	if pdac_busy='0' then pdac_update_en<='0';reg_ptr<=reg_ptr+1; 	ustate<=8;end if;
									--Update PDAC Channel D
									when 18=>	if(usb_done = '1') then reg_p7<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p7<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 19=>	if(usb_done = '1') then reg_p8<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p8<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 20=> 	pdac_data(15 downto 8)	<=reg_p7(7 downto 0); 
													pdac_data(7 downto 0) 	<=reg_p8(7 downto 0);
													pdac_data(23 downto 16)	<="10011011";
													pdac_update_en<='1'; -- request PDAC update, ChD
													reg_ptr<=reg_ptr+1;
									when 21=>	reg_ptr<=reg_ptr+1; --wait one clk cycle for PDAC routine to respond
									when 22=>	if (pdac_busy='1') then reg_ptr<=reg_ptr+1; end if;
									when 23=>	if (pdac_busy='0') then pdac_update_en<='0';reg_ptr<=reg_ptr+1;ustate<=8; end if;							
									---- get rest of the program registers
									when 24=>	if(usb_done = '1') then reg_p9<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p9 <=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 25=>	if(usb_done = '1') then reg_p10<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p10<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 26=>	if(usb_done = '1') then reg_p11<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p11<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 27=>	if(usb_done = '1') then reg_p12<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p12<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 28=>	if(usb_done = '1') then reg_p13<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p13<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 29=>	if(usb_done = '1') then reg_p14<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p14<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 30=>	if(usb_done = '1') then reg_p15<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p15<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 31=>	if(usb_done = '1') then reg_p16<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p16<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 32=>	if(usb_done = '1') then reg_p17<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p17<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 33=>	if(usb_done = '1') then reg_p18<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p18<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 34=>	if(usb_done = '1') then reg_p19<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p19<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 35=>	if(usb_done = '1') then reg_p20<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p20<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 36=>	if(usb_done = '1') then reg_p21<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p21<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 37=>	if(usb_done = '1') then reg_p22<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p22<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 38=>	if(usb_done = '1') then reg_p23<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p23<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 39=>	if(usb_done = '1') then reg_p24<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
													--reg_p24<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; ustate<=8;
									when 40=>	if(usb_done = '1') then reg_p25<=din; reg_ptr<=reg_ptr+1;ustate<=8; else null; end if;
												--	reg_p25<=din; reg_ptr<=reg_ptr+1;rd<='1';cwr<='1'; 
													idac_update_en<='1';	-- Assume idac_update rutine will responded in one clock
													ustate<=ustate+1;
									when others=> reg_ptr<=reg_ptr+1;
								end case;	

				when 15 => 	ustate<=ustate+1;	
				when 16 => 	if (idac_busy='0') 	--Request idac_update
									then idac_update_en<='0';	ustate<=0;  -- end register update, go listening mode
									else idac_update_en<='1'; 
								end if;
				---------------------------------------------------------------------------	
				-- frame read rutine for first data=0F
				---------------------------------------------------------------------------
				when 18 	=> dir<='0'; --1=read from USB/PC, 0=write to USB/PC
								if(data_available= '1') then
									dout <= frame_data;
									if(usb_busy = '1') then
										null;
									else
										usb_go <= '1';
										frame_en <= '0';
										ustate <= ustate+1;
									end if;
								else
									null;
								end if;
				when 19 	=> usb_go <= '0'; ustate <= ustate + 1;
				when 20 =>
							if(frame_end = '1') then
								frame_en <= '0';
								ustate <= 0;
							else
								frame_en <= '1';
								if(data_available = '1') then
									dout <= frame_data;
									if(usb_busy = '0' or usb_done = '1') then
										usb_go <= '1';
									else
										null;
									end if;
								end if;
							end if;
				when others=>	ustate<=ustate+1;
			end case;
		end if;
	else
		null;
	end if;
end process USB_FSM;
-----------------------------------------------------------------------------
--- End of USB Communication Finite State Machine (FSM) 
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--- DAC (AD5664 - 16bit) controller unit (One DAC version)
-----------------------------------------------------------------------------
DAC_Loader_FSM: process (clk,rst,pdac_update_en,pdac_data)
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
			pdac_busy<='0';
			dacstate<=0;
			pdac_clk<='1';
			pdac_sin<='0';
			pdac_sync<='1';
		elsif (pdac_update_en='1') then
				case dacstate is
					when  0=>	pdac_sync<='0'; 
									pdac_busy<='1';	pdac_sin<=pdac_data(23);	dacstate<=dacstate+1;
					when  1=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  2=>	pdac_clk<='1';		pdac_sin<=pdac_data(22);	dacstate<=dacstate+1;
					when  3=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  4=>	pdac_clk<='1';		pdac_sin<=pdac_data(21);	dacstate<=dacstate+1;
					when  5=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  6=>	pdac_clk<='1';		pdac_sin<=pdac_data(20);	dacstate<=dacstate+1;
					when  7=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when  8=>	pdac_clk<='1';		pdac_sin<=pdac_data(19);	dacstate<=dacstate+1;
					when  9=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 10=>	pdac_clk<='1';		pdac_sin<=pdac_data(18);	dacstate<=dacstate+1;
					when 11=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 12=>	pdac_clk<='1';		pdac_sin<=pdac_data(17);	dacstate<=dacstate+1;
					when 13=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 14=>	pdac_clk<='1';		pdac_sin<=pdac_data(16);	dacstate<=dacstate+1;
					when 15=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 16=>	pdac_clk<='1';		pdac_sin<=pdac_data(15);	dacstate<=dacstate+1;
					when 17=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 18=>	pdac_clk<='1';		pdac_sin<=pdac_data(14);	dacstate<=dacstate+1;
					when 19=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 20=>	pdac_clk<='1';		pdac_sin<=pdac_data(13);	dacstate<=dacstate+1;
					when 21=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 22=>	pdac_clk<='1';		pdac_sin<=pdac_data(12);	dacstate<=dacstate+1;
					when 23=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 24=>	pdac_clk<='1';		pdac_sin<=pdac_data(11);	dacstate<=dacstate+1;
					when 25=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 26=>	pdac_clk<='1';		pdac_sin<=pdac_data(10);	dacstate<=dacstate+1;
					when 27=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 28=>	pdac_clk<='1';		pdac_sin<=pdac_data(9);	dacstate<=dacstate+1;
					when 29=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 30=>	pdac_clk<='1';		pdac_sin<=pdac_data(8);	dacstate<=dacstate+1;
					when 31=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 32=>	pdac_clk<='1';		pdac_sin<=pdac_data(7);	dacstate<=dacstate+1;
					when 33=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 34=>	pdac_clk<='1';		pdac_sin<=pdac_data(6);	dacstate<=dacstate+1;
					when 35=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 36=>	pdac_clk<='1';		pdac_sin<=pdac_data(5);	dacstate<=dacstate+1;
					when 37=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 38=>	pdac_clk<='1';		pdac_sin<=pdac_data(4);	dacstate<=dacstate+1;
					when 39=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 40=>	pdac_clk<='1';		pdac_sin<=pdac_data(3);	dacstate<=dacstate+1;
					when 41=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 42=>	pdac_clk<='1';		pdac_sin<=pdac_data(2);	dacstate<=dacstate+1;
					when 43=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 44=>	pdac_clk<='1';		pdac_sin<=pdac_data(1);	dacstate<=dacstate+1;
					when 45=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 46=>	pdac_clk<='1';		pdac_sin<=pdac_data(0);	dacstate<=dacstate+1;
					when 47=>	pdac_clk<='0';										dacstate<=dacstate+1;
					when 48=>	pdac_clk<='1';	
									pdac_sync<='1';
									pdac_busy<='0';
									dacstate<=dacstate+1;
					when others=> dacstate<=dacstate+1;
				end case;
		else	dacstate<=0; 
		end if;
	else	null;	end if;
end process DAC_Loader_FSM;
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
--- Internal DAC Update Routine
----------------------------------------------------------------------------------------------------
iDAC_Loader_FSM: process (clk,rst,idac_update_en,trip) is
begin
	if (clk='1' and clk'event) then
		if (rst='0') then
			idac_busy<='0'; -- IDAC routine is not busy
			idacstate<=0;
			i2c_in2<='0'; 			
			i2c_clk<='0';
			i2c_rstb<='1'; -- active low reset
			ref_pwron<='0';
		elsif (idac_update_en='1') then 
				case idacstate is
					when    0=>	idac_busy<='1';-- IDAC routine is busy
									i2c_clk<='0';
									i2c_in2<='0';
									i2c_rstb<='0'; -- reset idac
									ref_pwron<='0';-- power OFF reference generator during update
									idacstate<=idacstate+1;
					when    2=>	i2c_rstb<='1';	i2c_in2<=reg_p23(1);	idacstate<=idacstate+1;-- sslar_override
					when    4=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when    6=>	i2c_clk<='0';	i2c_in2<=reg_p21(6);	idacstate<=idacstate+1;-- step6
					when    8=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   10=>	i2c_clk<='0';	i2c_in2<=reg_p21(5);	idacstate<=idacstate+1;-- step5
					when   12=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   14=>	i2c_clk<='0';	i2c_in2<=reg_p21(4);	idacstate<=idacstate+1;-- step4
					when   16=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   18=>	i2c_clk<='0';	i2c_in2<=reg_p21(3);	idacstate<=idacstate+1;-- step3
					when   20=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   22=>	i2c_clk<='0';	i2c_in2<=reg_p21(2);	idacstate<=idacstate+1;-- step2
					when   24=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   26=>	i2c_clk<='0';	i2c_in2<=reg_p21(1);	idacstate<=idacstate+1;-- step1
					when   28=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   30=>	i2c_clk<='0';	i2c_in2<=reg_p21(0);	idacstate<=idacstate+1;-- step0
					when   32=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   34=>	i2c_clk<='0';	i2c_in2<=reg_p22(0);	idacstate<=idacstate+1;-- magdec0
					when   36=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   38=>	i2c_clk<='0';	i2c_in2<=reg_p22(1);	idacstate<=idacstate+1;-- magdec1
					when   40=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   42=>	i2c_clk<='0';	i2c_in2<=reg_p22(2);	idacstate<=idacstate+1;-- magdec2
					when   44=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   46=>	i2c_clk<='0';	i2c_in2<=reg_p20(5);	idacstate<=idacstate+1;-- mag_bias5
					when   48=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   50=>	i2c_clk<='0';	i2c_in2<=reg_p20(4);	idacstate<=idacstate+1;-- mag_bias4
					when   52=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   54=>	i2c_clk<='0';	i2c_in2<=reg_p20(3);	idacstate<=idacstate+1;-- mag_bias3
					when   56=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   58=>	i2c_clk<='0';	i2c_in2<=reg_p20(2);	idacstate<=idacstate+1;-- mag_bias2
					when   60=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   62=>	i2c_clk<='0';	i2c_in2<=reg_p20(1);	idacstate<=idacstate+1;-- mag_bias1
					when   64=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   66=>	i2c_clk<='0';	i2c_in2<=reg_p20(0);	idacstate<=idacstate+1;-- mag_bias0			
					when   68=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   70=>	i2c_clk<='0';	i2c_in2<=reg_p19(5);	idacstate<=idacstate+1;-- event_bias5
					when   72=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   74=>	i2c_clk<='0';	i2c_in2<=reg_p19(4);	idacstate<=idacstate+1;-- event_bias4
					when   76=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   78=>	i2c_clk<='0';	i2c_in2<=reg_p19(3);	idacstate<=idacstate+1;-- event_bias3
					when   80=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   82=>	i2c_clk<='0';	i2c_in2<=reg_p19(2);	idacstate<=idacstate+1;-- event_bias2
					when   84=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   86=>	i2c_clk<='0';	i2c_in2<=reg_p19(1);	idacstate<=idacstate+1;-- event_bias1
					when   88=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   90=>	i2c_clk<='0';	i2c_in2<=reg_p19(0);	idacstate<=idacstate+1;-- event_bias0								
					when   92=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   94=>	i2c_clk<='0';	i2c_in2<=reg_p18(5);	idacstate<=idacstate+1;-- vln5
					when   96=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when   98=>	i2c_clk<='0';	i2c_in2<=reg_p18(4);	idacstate<=idacstate+1;-- vln4
					when  100=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  102=>	i2c_clk<='0';	i2c_in2<=reg_p18(3);	idacstate<=idacstate+1;-- vln3
					when  104=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  106=>	i2c_clk<='0';	i2c_in2<=reg_p18(2);	idacstate<=idacstate+1;-- vln2
					when  108=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  110=>	i2c_clk<='0';	i2c_in2<=reg_p18(1);	idacstate<=idacstate+1;-- vln1
					when  112=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  114=>	i2c_clk<='0';	i2c_in2<=reg_p18(0);	idacstate<=idacstate+1;-- vln0
					when  116=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  118=>	i2c_clk<='0';	i2c_in2<=reg_p17(5);	idacstate<=idacstate+1;-- amp_bias5
					when  120=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  122=>	i2c_clk<='0';	i2c_in2<=reg_p17(4);	idacstate<=idacstate+1;-- amp_bias4
					when  124=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  126=>	i2c_clk<='0';	i2c_in2<=reg_p17(3);	idacstate<=idacstate+1;-- amp_bias3
					when  128=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  130=>	i2c_clk<='0';	i2c_in2<=reg_p17(2);	idacstate<=idacstate+1;-- amp_bias2
					when  132=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  134=>	i2c_clk<='0';	i2c_in2<=reg_p17(1);	idacstate<=idacstate+1;-- amp_bias1
					when  136=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  138=>	i2c_clk<='0';	i2c_in2<=reg_p17(0);	idacstate<=idacstate+1;-- amp_bias0	
					when  140=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  142=>	i2c_clk<='0';	i2c_in2<=reg_p16(5);	idacstate<=idacstate+1;-- comp_bias5
					when  144=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  146=>	i2c_clk<='0';	i2c_in2<=reg_p16(4);	idacstate<=idacstate+1;-- comp_bias4
					when  148=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  150=>	i2c_clk<='0';	i2c_in2<=reg_p16(3);	idacstate<=idacstate+1;-- comp_bias3
					when  152=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  154=>	i2c_clk<='0';	i2c_in2<=reg_p16(2);	idacstate<=idacstate+1;-- comp_bias2
					when  156=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  158=>	i2c_clk<='0';	i2c_in2<=reg_p16(1);	idacstate<=idacstate+1;-- comp_bias1
					when  160=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  162=>	i2c_clk<='0';	i2c_in2<=reg_p16(0);	idacstate<=idacstate+1;-- comp_bias0	
					when  164=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  166=>	i2c_clk<='0';	i2c_in2<=reg_p15(5);	idacstate<=idacstate+1;-- iref_out5
					when  168=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  170=>	i2c_clk<='0';	i2c_in2<=reg_p15(4);	idacstate<=idacstate+1;-- iref_out4
					when  172=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  174=>	i2c_clk<='0';	i2c_in2<=reg_p15(3);	idacstate<=idacstate+1;-- iref_out3
					when  176=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  178=>	i2c_clk<='0';	i2c_in2<=reg_p15(2);	idacstate<=idacstate+1;-- iref_out2
					when  180=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  182=>	i2c_clk<='0';	i2c_in2<=reg_p15(1);	idacstate<=idacstate+1;-- iref_out1
					when  184=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  186=>	i2c_clk<='0';	i2c_in2<=reg_p15(0);	idacstate<=idacstate+1;-- iref_out0	
					when  188=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  190=>	i2c_clk<='0';	i2c_in2<=reg_p10(0);	idacstate<=idacstate+1;-- ref_gen0
					when  192=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  194=>	i2c_clk<='0';	i2c_in2<=reg_p10(1);	idacstate<=idacstate+1;-- ref_gen1
					when  196=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  198=>	i2c_clk<='0';	i2c_in2<=reg_p10(2);	idacstate<=idacstate+1;-- ref_gen2	
					when  200=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  202=>	i2c_clk<='0';	i2c_in2<=reg_p13(0);	idacstate<=idacstate+1;-- wat_0
					when  204=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  206=>	i2c_clk<='0';	i2c_in2<=reg_p13(1);	idacstate<=idacstate+1;-- wat_1
					when  208=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  210=>	i2c_clk<='0';	i2c_in2<=reg_p13(2);	idacstate<=idacstate+1;-- wat_2
					when  212=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  214=>	i2c_clk<='0';	i2c_in2<=reg_p13(3);	idacstate<=idacstate+1;-- wat_3
					when  216=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  218=>	i2c_clk<='0';	i2c_in2<=reg_p13(4);	idacstate<=idacstate+1;-- wat_4
					when  220=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  222=>	i2c_clk<='0';	i2c_in2<=reg_p13(5);	idacstate<=idacstate+1;-- wat_5
					when  224=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  226=>	i2c_clk<='0';	i2c_in2<=reg_p13(6);	idacstate<=idacstate+1;-- wat_6
					when  228=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  230=>	i2c_clk<='0';	i2c_in2<=reg_p13(7);	idacstate<=idacstate+1;-- wat_7
					when  232=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  234=>	i2c_clk<='0';	i2c_in2<=reg_p14(0);	idacstate<=idacstate+1;-- wat_8
					when  236=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  238=>	i2c_clk<='0';	i2c_in2<=reg_p14(1);	idacstate<=idacstate+1;-- wat_9
					when  240=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  242=>	i2c_clk<='0';	i2c_in2<=reg_p23(0);	idacstate<=idacstate+1;-- watermark_en
					when  244=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  246=>	i2c_clk<='0';	i2c_in2<=reg_p12(1);	idacstate<=idacstate+1;-- cryp9
					when  248=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  250=>	i2c_clk<='0';	i2c_in2<=reg_p12(0);	idacstate<=idacstate+1;-- cryp8
					when  252=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  254=>	i2c_clk<='0';	i2c_in2<=reg_p11(7);	idacstate<=idacstate+1;-- cryp7
					when  256=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  258=>	i2c_clk<='0';	i2c_in2<=reg_p11(6);	idacstate<=idacstate+1;-- cryp6
					when  260=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  262=>	i2c_clk<='0';	i2c_in2<=reg_p11(5);	idacstate<=idacstate+1;-- cryp5
					when  264=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  266=>	i2c_clk<='0';	i2c_in2<=reg_p11(4);	idacstate<=idacstate+1;-- cryp4
					when  268=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  270=>	i2c_clk<='0';	i2c_in2<=reg_p11(3);	idacstate<=idacstate+1;-- cryp3
					when  272=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  274=>	i2c_clk<='0';	i2c_in2<=reg_p11(2);	idacstate<=idacstate+1;-- cryp2
					when  276=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  278=>	i2c_clk<='0';	i2c_in2<=reg_p11(1);	idacstate<=idacstate+1;-- cryp1
					when  280=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  282=>	i2c_clk<='0';	i2c_in2<=reg_p11(0);	idacstate<=idacstate+1;-- cryp0
					when  284=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  286=>	i2c_clk<='0';	i2c_in2<=reg_p9(2);	idacstate<=idacstate+1;-- gain2
					when  288=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  290=>	i2c_clk<='0';	i2c_in2<=reg_p9(1);	idacstate<=idacstate+1;-- gain1
					when  292=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  294=>	i2c_clk<='0';	i2c_in2<=reg_p9(0);	idacstate<=idacstate+1;-- gain0
					when  296=>	i2c_clk<='1';								idacstate<=idacstate+1;
					when  298=>	i2c_clk<='0';	
									ref_pwron<=reg_p23(2); -- power ON/OFF reference generator
									i2c_in2<='0';
									idacstate	<=idacstate+1;
					when  300=>	idac_busy	<='0';	  -- IDAC routine is not busy
									idacstate<=idacstate+1;
					when others=> idacstate<=idacstate+1;
				end case;
		else	
			i2c_clk<='0';
			i2c_rstb<='1';
			i2c_in2<='0';
			ref_pwron<=reg_p23(2) AND trip; -- power ON/OFF reference generator
			idac_busy<='0'; -- IDAC routine is not busy
			idacstate<=0;
		end if;
	end if;
end process iDAC_Loader_FSM;
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- Bidirectional USB2 data port mapping
-----------------------------------------------------------------------------------------------------
   inst_IOBUF0 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(0),   -- Buffer output
      IO => d(0),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(0),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF1 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(1),   -- Buffer output
      IO => d(1),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(1),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF2 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(2),   -- Buffer output
      IO => d(2),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(2),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF3 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(3),   -- Buffer output
      IO => d(3),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(3),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF4 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(4),   -- Buffer output
      IO => d(4),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(4),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF5 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(5),   -- Buffer output
      IO => d(5),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(5),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF6 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(6),   -- Buffer output
      IO => d(6),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(6),  -- Buffer input
      T => dir       -- 3-state enable input 
   );
   inst_IOBUF7 : IOBUF
   generic map (
      DRIVE => 12,
      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
      IOSTANDARD => "LVTTL",
      SLEW => "FAST")
   port map (
      O => ftdi_din(7),   -- Buffer output
      IO => d(7),    -- Buffer inout port (connect directly to top-level port)
      I => ftdi_dout(7),  -- Buffer input
      T => dir       -- 3-state enable input 
   );	
	-----------------------
	--- memory data bus
	-----------------------
--	mem_inst_IOBUF0 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(0),   -- Buffer output
--      IO => mdata(0),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(0),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF1 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(1),   -- Buffer output
--      IO => mdata(1),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(1),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF2 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(2),   -- Buffer output
--      IO => mdata(2),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(2),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF3 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(3),   -- Buffer output
--      IO => mdata(3),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(3),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF4 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(4),   -- Buffer output
--      IO => mdata(4),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(4),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF5 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(5),   -- Buffer output
--      IO => mdata(5),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(5),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF6 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(6),   -- Buffer output
--      IO => mdata(6),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(6),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF7 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(7),   -- Buffer output
--      IO => mdata(7),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(7),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF8 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(8),   -- Buffer output
--      IO => mdata(8),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(8),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF9 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(9),   -- Buffer output
--      IO => mdata(9),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(9),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF10 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(10),   -- Buffer output
--      IO => mdata(10),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(10),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF11 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(11),   -- Buffer output
--      IO => mdata(11),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(11),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF12 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(12),   -- Buffer output
--      IO => mdata(12),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(12),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF13 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(13),   -- Buffer output
--      IO => mdata(13),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(13),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF14 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(14),   -- Buffer output
--      IO => mdata(14),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(14),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );	
--	mem_inst_IOBUF15 : IOBUF
--   generic map (
--      DRIVE => 12,
--      IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer, "0"-"16" (Spartan-3E only)
--      IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register, "AUTO", "0"-"8" (Spartan-3E only)
--      IOSTANDARD => "LVTTL",
--      SLEW => "FAST")
--   port map (
--      O => mdin(15),   -- Buffer output
--      IO => mdata(15),    -- Buffer inout port (connect directly to top-level port)
--      I => mdout(15),  -- Buffer input
--      T => mdir       -- 3-state enable input 
--   );		
--------------------
end Behavioral;
