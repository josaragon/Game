library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MaquinaJoystick is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  leido : in  STD_LOGIC;
           inQ1 : in  STD_LOGIC_VECTOR (13 downto 0);--VERTICAL
           inQ2 : in  STD_LOGIC_VECTOR (13 downto 0);--HORIZONTAL
           --sw_enable : in  STD_LOGIC;
			  SW_prueba: in STD_LOGIC;
           up : out  STD_LOGIC;
			  led_up : out STD_LOGIC;
           right : out  STD_LOGIC;
			  led_right : out STD_LOGIC;
           down : out  STD_LOGIC;
			  led_down : out STD_LOGIC;
           left : out  STD_LOGIC;
			  led_left : out STD_LOGIC;
           ADC : out  STD_LOGIC);
end MaquinaJoystick;

architecture Behavioral of MaquinaJoystick is

type estado is (reposo, activarAD, lecturaAD, decision, up_e, right_e, down_e, left_e, medio_e);
signal state, p_state : estado;
signal copiaQ1,copiaQ2 : unsigned (13 downto 0);
signal cuentaO3Y, p_cuentaO3Y: unsigned (5 downto 0);


begin

copiaQ1<=unsigned(inQ1);
copiaQ2<=unsigned(inQ2);

sinc:process(clk,reset)
	begin
		if(reset='1') then
			state<=reposo;
			cuentaO3Y<="000000";
		elsif(rising_edge(clk)) then
			state<=p_state;
			cuentaO3Y<=p_cuentaO3Y;
		end if;
	end process;
	
comb: process(state,copiaQ1,copiaQ2,leido,SW_prueba)--,sw_enable)
	begin
		p_state<=reposo;
		case state is
			when reposo=>
				ADC<='0';
				up<='0';
				right<='0';
				down<='0';
				left<='0';
				led_up<='0';
				led_left<='0';
				led_right<='0';
				led_down<='0';
				if(SW_prueba = '1') then
					if(cuentaO3Y = "000001") then
					p_state<=activarAD;
					p_cuentaO3Y<="000000";
					else
					p_state<=reposo;
					p_cuentaO3Y<=cuentaO3Y+1;
					end if;
				else
					p_state<=reposo;
					p_cuentaO3Y<=cuentaO3Y;
				end if;
				
			when activarAD=>
				ADC<='1';
				up<='0';
				right<='0';
				down<='0';
				left<='0';
				p_state<=lecturaAD;
				led_up<='0';
				led_left<='0';
				led_right<='0';
				led_down<='0';
				p_cuentaO3Y<=cuentaO3Y;
			
			when lecturaAD=>
				ADC<='0';
				up<='0';
				right<='0';
				down<='0';
				left<='0';
				led_up<='0';
				led_left<='0';
				led_right<='0';
				led_down<='0';
				p_cuentaO3Y<=cuentaO3Y;
				if (leido = '1') then
				p_state<=decision;
				else
				p_state<=lecturaAD;
				end if;
				
			when decision=>
				ADC<='0';
				up<='0';
				right<='0';
				down<='0';
				left<='0';
				led_up<='0';
				led_left<='0';
				led_right<='0';
				led_down<='0';
				p_cuentaO3Y<=cuentaO3Y;
						if(copiaQ1>20 and copiaQ1<16363 and copiaQ2>20 and copiaQ2<16363) then
							p_state<=medio_e;
						elsif(copiaQ1>=16363 and copiaQ2<16383) then
							p_state<=up_e;
						elsif(copiaQ2>=16363 and copiaQ1<16383) then 
							p_state<=right_e;
						elsif(copiaQ1<=20 and copiaQ2<16383) then
							p_state<=down_e;
						elsif(copiaQ2<=20 and copiaQ1<16383) then
							p_state<=left_e;
						end if;
				
			when up_e=>
				ADC<='0';
				up<='1';
				right<='0';
				down<='0';
				left<='0';
				led_up<='1';
				led_left<='0';
				led_right<='0';
				led_down<='0';
				if(SW_prueba = '1') then
					if(cuentaO3Y = "100101") then
					p_state<=reposo;
					p_cuentaO3Y<="000000";
					else
					p_state<=up_e;
					p_cuentaO3Y<=cuentaO3Y+1;
					end if;
				else
					p_state<=up_e;
					p_cuentaO3Y<=cuentaO3Y;
				end if;
				
			when right_e=>
				ADC<='0';
				up<='0';
				right<='1';
				down<='0';
				left<='0';
				led_up<='0';
				led_left<='0';
				led_right<='1';
				led_down<='0';
				if(SW_prueba = '1') then
					if(cuentaO3Y = "100101") then
					p_state<=reposo;
					p_cuentaO3Y<="000000";
					else
					p_state<=right_e;
					p_cuentaO3Y<=cuentaO3Y+1;
					end if;
				else
					p_state<=right_e;
					p_cuentaO3Y<=cuentaO3Y;
				end if;
				
			when down_e=>
				ADC<='0';
				up<='0';
				right<='0';
				down<='1';
				left<='0';
				led_up<='0';
				led_left<='0';
				led_right<='0';
				led_down<='1';
				if(SW_prueba = '1') then
					if(cuentaO3Y = "100101") then
					p_state<=reposo;
					p_cuentaO3Y<="000000";
					else
					p_state<=down_e;
					p_cuentaO3Y<=cuentaO3Y+1;
					end if;
				else
					p_state<=down_e;
					p_cuentaO3Y<=cuentaO3Y;
				end if;
				
			when left_e=>
				ADC<='0';
				up<='0';
				right<='0';
				down<='0';
				left<='1';
				led_up<='0';
				led_left<='1';
				led_right<='0';
				led_down<='0';
				if(SW_prueba = '1') then
					if(cuentaO3Y = "100101") then
					p_state<=reposo;
					p_cuentaO3Y<="000000";
					else
					p_state<=left_e;
					p_cuentaO3Y<=cuentaO3Y+1;
					end if;
				else
					p_state<=left_e;
					p_cuentaO3Y<=cuentaO3Y;
				end if;
				
			when medio_e=>
				ADC<='0';
				up<='0';
				right<='0';
				down<='0';
				left<='1';
				led_up<='1';
				led_left<='1';
				led_right<='1';
				led_down<='1';
				if(SW_prueba = '1') then
					if(cuentaO3Y = "100101") then
					p_state<=reposo;
					p_cuentaO3Y<="000000";
					else
					p_state<=medio_e;
					p_cuentaO3Y<=cuentaO3Y+1;
					end if;
				else
					p_state<=medio_e;
					p_cuentaO3Y<=cuentaO3Y;
				end if;
		end case;
	end process;
	
end Behavioral;

