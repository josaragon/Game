library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity SpiJoystick is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           ADC : in  STD_LOGIC;
           SPI_MISO : in  STD_LOGIC;
			  SW_in: in STD_LOGIC;
			  --SW_prueba: in STD_LOGIC;
			  --SW_prueba2: in STD_LOGIC;
           leido : out  STD_LOGIC;
           CH0 : out  STD_LOGIC_VECTOR (13 downto 0);
           CH1 : out  STD_LOGIC_VECTOR (13 downto 0);
           AD_CONV : out  STD_LOGIC;
           SCK_M : out  STD_LOGIC;
           SHDN : out  STD_LOGIC;
           C_S : out  STD_LOGIC;
           SPI_MOSI : out  STD_LOGIC);
end SpiJoystick;

architecture Behavioral of SpiJoystick is

type estado is (inicio, C_Senable, SCK_MOSI_up, SCK_MOSI_down, reposo, genADC, esperar, SCK_MISO_up, SCK_MISO_down);
signal state,p_state: estado;
signal cuenta,p_cuenta: unsigned(2 downto 0);
signal cuentaSPI,p_cuentaSPI: unsigned(5 downto 0);
signal cuenta2ADC,p_cuenta2ADC : unsigned (1 downto 0);
signal GainVector,p_GainVector: unsigned(7 downto 0);
signal p_Q0,Q0,p_Q1,Q1: unsigned(13 downto 0);

begin

CH0<=std_logic_vector(Q0);
CH1<=std_logic_vector(Q1);

sinc:process(clk,reset)
	begin
		if(reset='1') then
			state<=inicio;
			cuenta<="000";
			cuentaSPI<="000000";
			cuenta2ADC<="00";
			GainVector<="00010001";
			Q0<="01111111111111";
			Q1<="01111111111111";
		elsif(rising_edge(clk)) then
			state<=p_state;
			cuenta<=p_cuenta;
			cuentaSPI<=p_cuentaSPI;
			GainVector<=p_GainVector;
			Q0<=p_Q0;
			Q1<=p_Q1;
			cuenta2ADC<=p_cuenta2ADC;
		end if;
	end process;
	
comb:process(state, ADC, SPI_MISO, cuenta, p_cuenta, cuentaSPI, p_cuentaSPI,SW_in,Q0,Q1,p_Q1,p_Q0,GainVector,cuenta2ADC)--,SW_prueba2)--, SW_prueba)
	begin
		case state is
			
			when inicio=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<='1';
--			p_Q0<="01111111111111";
--			p_Q1<="01111111111111";
			p_Q0<="00000000000000";
			p_Q1<="00000000000000";
			C_S<='1';
			leido<='0';
			p_cuenta<="000";
			p_cuentaSPI<="000000";
			p_cuenta2ADC<="00";
			p_GainVector<="00010001";--Se pone al reves porque comienza a enviar por el mas significativo
			if(SW_in = '1') then
				p_state<=C_Senable;
			else
				p_state<=inicio;
			end if;
			
			when C_Senable=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<='0';--Antes de comenzar debe de haber un cero porque GainVector="00010001";Ver datasheet
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='0';
			leido<='0';
			p_cuenta<="000";
			p_cuentaSPI<="000000";
			p_cuenta2ADC<=cuenta2ADC;
			p_GainVector<=GainVector;
			if(cuenta = "010") then 
				p_cuenta<="000";
				p_state<=SCK_MOSI_up;
			else
				p_cuenta<=cuenta+1;
				p_state<=C_Senable;
			end if;
			
			when SCK_MOSI_up=>
			SCK_M<='1';
			SHDN<='0';
			AD_CONV<='0';
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='0';
			p_cuenta2ADC<=cuenta2ADC;
			if(cuenta = "101") then 
				p_cuenta<="000";
				if(cuentaSPI = "000111") then
					p_state<=reposo;
					p_GainVector<=GainVector;
					p_cuentaSPI<=cuentaSPI;
					SPI_MOSI<='1';
					leido<='1';
				else
					SPI_MOSI<=GainVector(7);
					p_GainVector<=rotate_left(GainVector,1);
					p_cuentaSPI<=cuentaSPI+1;
					p_state<=SCK_MOSI_down;
					leido<='0';
				end if;
			else
				p_cuenta<=cuenta+1;
				p_state<=SCK_MOSI_up;
				p_GainVector<=GainVector;
				p_cuentaSPI<=cuentaSPI;
				SPI_MOSI<=GainVector(7);
				leido<='0';
			end if;
				
			when SCK_MOSI_down=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<=GainVector(7);
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='0';
			leido<='0';
			p_cuentaSPI<=cuentaSPI;
			p_GainVector<=GainVector;
			p_cuenta2ADC<=cuenta2ADC;
			if(cuenta = "101") then 
				p_cuenta<="000";
				p_state<=SCK_MOSI_up;
			else
				p_cuenta<=cuenta+1;
				p_state<=SCK_MOSI_down;
			end if;
			
			when reposo=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<='1';
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='1';
			leido<='0';
			p_cuenta<="000";
			p_cuentaSPI<="000000";
			p_GainVector<=GainVector;
			p_cuenta2ADC<=cuenta2ADC;
			if(ADC = '1') then
				p_state<=genADC;
			else
				p_state<=reposo;
			end if;
			
			when genADC=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='1';
			SPI_MOSI<='1';
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='1';
			leido<='0';
			p_cuenta<="000";
			p_cuentaSPI<="000000";
			p_GainVector<=GainVector;
			p_state<=esperar;
			p_cuenta2ADC<=cuenta2ADC;
			
			when esperar=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<='1';
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='1';
			leido<='0';
			p_cuenta<="000";
			p_cuentaSPI<=cuentaSPI;
			p_GainVector<=GainVector;
			p_state<=SCK_MISO_up;
			p_cuenta2ADC<=cuenta2ADC;
			
			when SCK_MISO_up=>
			SCK_M<='1';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<='1';
			p_Q0<=Q0;
			p_Q1<=Q1;
			C_S<='1';
			leido<='0';
			p_GainVector<=GainVector;
			p_cuentaSPI<=cuentaSPI;
			p_cuenta2ADC<=cuenta2ADC;
			if(cuenta = "101") then 
				p_cuenta<="000";
				p_state<=SCK_MISO_down;
			else
				p_cuenta<=cuenta+1;
				p_state<=SCK_MISO_up;
			end if;
			
			when SCK_MISO_down=>
			SCK_M<='0';
			SHDN<='0';
			AD_CONV<='0';
			SPI_MOSI<='1';
			C_S<='1';
			p_GainVector<=GainVector;
			if(cuenta = "101") then 
				p_cuenta<="000";
				p_Q0<=Q0;
				p_Q1<=Q1;
				p_cuenta2ADC<=cuenta2ADC;
				if(cuentaSPI<"000001") then
					p_Q0<=Q0;
					p_Q1<=Q1;
					p_state<=SCK_MISO_up;
					leido<='0';
					p_cuentaSPI<=cuentaSPI+1;
					p_cuenta2ADC<=cuenta2ADC;
				elsif(cuentaSPI>="000001" and cuentaSPI<"001111") then
					p_Q0(12 downto 0)<=Q0(13 downto 1);
					p_Q0(13)<=SPI_MISO;
					p_state<=SCK_MISO_up;
					leido<='0';
					p_cuentaSPI<=cuentaSPI+1;
					p_cuenta2ADC<=cuenta2ADC;
				elsif(cuentaSPI>="001111" and cuentaSPI<"010001") then
					p_Q0<=Q0;
					p_Q1<=Q1;
					p_state<=SCK_MISO_up;
					leido<='0';
					p_cuentaSPI<=cuentaSPI+1;
					p_cuenta2ADC<=cuenta2ADC;
				elsif(cuentaSPI>="010001" and cuentaSPI<"011111") then
					p_Q1(12 downto 0)<=Q1(13 downto 1);
					p_Q1(13)<=SPI_MISO;
					p_state<=SCK_MISO_up;
					leido<='0';
					p_cuentaSPI<=cuentaSPI+1;
					p_cuenta2ADC<=cuenta2ADC;
				elsif(cuentaSPI>="011111" and cuentaSPI<="100000") then
					p_Q0<=Q0;
					p_Q1<=Q1;
					p_state<=SCK_MISO_up;
					leido<='0';
					p_cuentaSPI<=cuentaSPI+1;
					p_cuenta2ADC<=cuenta2ADC;
				else
					p_Q0<=Q0;
					p_Q1<=Q1;
					p_cuentaSPI<=cuentaSPI;
					if(cuenta2ADC = "00") then
					p_state<=genADC;
					p_cuenta2ADC<=cuenta2ADC+1;
					leido<='0';
					else
					p_state<=reposo;
					p_cuenta2ADC<="00";
					leido<='1';
					end if;
				end if;
			else
				p_Q0<=Q0;
				p_Q1<=Q1;
				p_cuenta<=cuenta+1;
				p_state<=SCK_MISO_down;
				leido<='0';
				p_cuentaSPI<=cuentaSPI;
				p_cuenta2ADC<=cuenta2ADC;
			end if;
			
	end case;
	end process;
	
end Behavioral;

