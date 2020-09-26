----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:21:47 11/27/2016 
-- Design Name: 
-- Module Name:    Maquina_Estados - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsmm is

Port ( clk : in STD_LOGIC;
rst : in STD_LOGIC;
Up : in STD_LOGIC;
Down : in STD_LOGIC;
Left : in STD_LOGIC;
Right : in STD_LOGIC;
Swe : in STD_LOGIC;
O3_y : in STD_LOGIC;
data_out_A : in std_logic_vector(4 downto 0);
Addr_A : out std_logic_vector(9 downto 0);
Write_A: out std_logic_VECTOR(0 DOWNTO 0); --- Aquí cambia
Data_in_A : out std_logic_vector(4 downto 0));


end fsmm;
                                                                                                                                                             architecture Behavioral of fsmm is
type estado is(Start, Repose, Goal, Siguiente,siguiente1,botones,leerg,leerg1,leerm,leerm1, move, grow,head,head1,die);--------Estados
signal estado_actual,p_estado: estado;---------------------------------------------------Gestion
signal p_cont,cont:unsigned(9 downto 0);-------------------------------------------------Leer_ram
signal p_cont2,cont2:unsigned(4 downto 0);------------------------------------------------O3_y
signal Pxnext,pynext,xnext,ynext:unsigned(4 downto 0);-----------------------------------Posicion_serpiente
signal p_crec,crec: unsigned(4 downto 0);
signal p_regtemp,regtemp: unsigned(4 downto 0);
signal button,p_button: unsigned(1 downto 0);
signal addaleat : std_logic_vector (9 downto 0);
signal enal : std_logic;

component setaleatoria is
  generic (nbit: integer := 10); 
  port (
    enable : in std_logic;
    rst  : in  std_logic;
    clk    : in  std_logic;
    addrb  : out std_logic_vector (nbit-1 downto 0)
  );
end component;





begin

myaleat : setaleatoria 
generic map (nbit=>10)
Port Map(enable=> enal,	rst=> rst, clk=>clk,	addrb=>addaleat);


Sinc: process(clk,rst)

 begin
 if(rst='1') then
	estado_actual <= Start;
 elsif (rising_edge(clk)) then
	estado_actual<= p_estado;
	cont<=p_cont;
	cont2<=p_cont2;
	crec<=p_crec;
	xnext<=pxnext;
	regtemp<=p_regtemp;
	ynext<=pynext;
	button<=p_button;
 end if;
 end process; 

Comb: process(estado_actual, data_out_A,Up,down,left,right,swe,O3_y,crec,cont,button,cont2,regtemp,xnext,ynext)
begin
	case estado_actual is

	when Start => ---------------------------------------------//////////////START///////////////
	pXnext<="01111";--------------------------------------------la_cabeza
	pynext<="01111";
	p_button<="11";
	p_cont<=(others=>'0');
	p_cont2<="00001";
	p_crec<="00001";
	write_A<="0";
	data_in_A<="00000";
	p_regtemp<=(others=>'0');
	addr_A<="0111101111";------direccion_first
	
		if(Swe='1')then	
			p_estado<=Repose;
		else
			p_estado<=Start;
		end if;
	
	when Repose => --------------------------------------------/////////////REPOSE///////////////
	p_crec<=crec;
	p_regtemp<=(others=>'0');
	p_cont<=(others=>'0');
	write_A<="0";
	data_in_A<="00000";
	pxnext<=xnext;
	pynext<=ynext;
	addr_A<=std_logic_vector(ynext&xnext);
	p_button<=button;
	
	if(O3_y='1') then
	
				if(cont2="11111")then
					p_cont2<=cont2;
					p_estado<=goal;
				else
					p_cont2<=cont2+2;
					p_estado<=botones;
				end if;
	else
				p_cont2<=cont2;			
				p_estado<=repose;		
	end if;
	
	
		
	when botones=>----------------------------------------------///////////////BOTONES////////////////
	p_crec<=crec;
	p_regtemp<=(others=>'0');
	p_cont<=(others=>'0');
	p_cont2<=cont2;
	write_A<="0";
	data_in_A<="00000";
	pxnext<=xnext;
	pynext<=ynext;
	addr_A<=std_logic_vector(ynext&xnext);
	p_estado<=repose;
	
	if(up='1')then
	p_button<="00";
	elsif(down='1')then
	p_button<="01";
	elsif(left='1')then
	p_button<="10";
	elsif(right='1')then
	p_button<="11";
	else
	p_button<=button;
	end if;
	
	when Goal =>------------------------------------------------////////////////GOAL/////////////////
	p_cont<=(others=>'0');
	p_cont2<=(others=>'0');
	p_crec<=crec;	
	p_regtemp<=(others=>'0');
	p_button<=button;
	write_A<="0";
	data_in_A<="00000";
	pxnext<=xnext;
	pynext<=ynext;
	addr_A<=std_logic_vector(ynext&xnext);
	
		if(button="00")then----------------arriba
			pxnext<=xnext;
			pynext<=ynext-1;
			p_estado<=siguiente;
		elsif(button="01")then-----------abajo
			pxnext<=xnext;
			pynext<=ynext+1;
			p_estado<=siguiente;
		elsif(button="10")then-----------izquierda
			pxnext<=xnext-1;
			pynext<=ynext;
			p_estado<=siguiente;
		elsif(button="11")then----------------------------derecha
			pxnext<=xnext+1;
			pynext<=ynext;
			p_estado<=siguiente;		
		end if;
	
	when Siguiente => -------------------------------------------////////////////Siguiente/////////////////
	p_cont<=(others=>'0');
	p_cont2<=(others=>'0');
	p_regtemp<=(others=>'0');
	p_button<=button;
	pxnext<=xnext;
	pynext<=ynext;
	write_A<="0";
	data_in_A<="00000";
	addr_A<=std_logic_vector(ynext&xnext);
	p_estado<=siguiente1;
	
		if(data_out_A="11110")then-------------------------------------------seta
			p_crec<=crec+1;
		else------------------------------------------------------muro, serpiente o hueco
			p_crec<=crec;
	
	end if;
	
	when Siguiente1 => -------------------------------------------///////////////////Siguiente1/////////////////
	p_cont<=(others=>'0');
	p_cont2<=(others=>'0');
	p_regtemp<=(others=>'0');
	p_button<=button;
	pxnext<=xnext;
	pynext<=ynext;
	write_A<="0";
	data_in_A<="00000";
	addr_A<=std_logic_vector(ynext&xnext);
	p_crec<=crec;
	
		if(data_out_A="11110")then-------------------------------------------seta
			p_estado<=leerg;
		elsif(data_out_A="00000")then----------------------------------------hueco
			p_estado<=leerm;
		else------------------------------------------------------muro_o_serpiente
			p_estado<=die;
	   end if;
	
	when leerg=>--------------------------------------------------------////////////////LEERG/////////////
	p_cont<=cont;
	pxnext<=xnext;
	pynext<=ynext;
	p_cont2<=(others=>'0');
	p_crec<=crec;
	write_A<="0";
	data_in_A<="00000";
	p_button<=button;
	addr_A<=std_logic_vector(cont);
	p_regtemp<=unsigned(data_out_A);
	p_estado<=leerg1;
	
	when leerg1=>-----------------------------------------------------/////////////LEERG1/////////////
	p_cont<=cont;
	pxnext<=xnext;
	pynext<=ynext;
	p_cont2<=(others=>'0');
	p_crec<=crec;
	write_A<="0";
	data_in_A<="00000";
	p_button<=button;
	addr_A<=std_logic_vector(cont);
	p_regtemp<=unsigned(data_out_A);
	p_estado<=grow;
	
	when leerm=>--------------------------------------------------------//////////////LEERM////////////
	p_cont<=cont;
	pxnext<=xnext;
	pynext<=ynext;
	p_cont2<=(others=>'0');
	p_button<=button;
	p_crec<=crec;
	write_A<="0";
	data_in_A<="00000";
	addr_A<=std_logic_vector(cont);
	p_regtemp<=unsigned(data_out_A);
	p_estado<=leerm1;
	
	when leerm1=>---------------------------------------------------------//////////////LEERM1////////////
	p_cont<=cont;
	pxnext<=xnext;
	pynext<=ynext;
	p_cont2<=(others=>'0');
	p_button<=button;
	p_crec<=crec;
	write_A<="0";
	data_in_A<="00000";
	addr_A<=std_logic_vector(cont);
	p_regtemp<=unsigned(data_out_A);
	p_estado<=move;
	
	
	when Grow => ---------------------------------------------------------///////////////////GROW////////////////
	p_crec<=crec;
	p_button<=button;
	p_cont2<=(others=>'0');
	pxnext<=xnext;
	pynext<=ynext;
	addr_A<=std_logic_vector(cont);
	p_cont<=cont+1;
	
	if(cont/="1111111110") then  ------------ pq 1022 ??
		if(regtemp/="00000" and regtemp/="11111" and regtemp/="11110") then-----mover_serpiente
			write_A<="1";
			p_regtemp<=regtemp+1;
			p_estado<=leerg;
			data_in_A<=std_logic_vector(regtemp);
		else 
			write_A<="0";
			data_in_A<="00000";
			p_regtemp<=regtemp;
			p_estado<=leerg;
		end if;
	else
	write_A<="0"; --------------------------------- /** 0 o 1 **/
	data_in_A<="00001";
	p_regtemp<=(others=>'0');
	p_estado<=head;
	end if;
	
	when Move => -------------------------------------------------------------//////////////MOVE///////////// 
	p_crec<=crec;
	p_button<=button;
	p_cont2<=(others=>'0');
	pxnext<=xnext;
	pynext<=ynext;
	
	
	if(cont/="1111111111") then-----------------------------------------------si_no_he_terminado_recorrer_memoria
		addr_A<=std_logic_vector(cont);
		p_cont<=cont+1;
		p_estado<=leerm;
		if(regtemp/="00000" and regtemp/="11111" and regtemp/="11110") then-----hay_serpiente
			write_A<="1";
			if(regtemp=crec)then------------------------------------------------------borrar_cola			
				p_regtemp<=regtemp;
				data_in_A<="00000";
			else--------------------------------------------------------------------mover_serpiente		
				p_regtemp<=regtemp+1;
				data_in_A<=std_logic_vector(regtemp); --?
				----------
			end if;
		else 
			write_A<="0";
			data_in_A<="00000";
			p_regtemp<=regtemp;
		end if ;
	else----------------------------------------------------------------------he_llegao_al_final_memoria
	data_in_A<="11111";
	write_A<="0";
	p_regtemp<=(others=>'0');
	p_cont<=(others=>'0');
	pxnext<=xnext;
	pynext<=ynext;
	addr_A<=std_logic_vector(ynext&xnext);
	p_estado<=head;
	end if;
	
	when head =>------------------------------------------------------///////////////////////HEAD//////////////
			
			pxnext<=xnext;
			pynext<=ynext;
			p_button<=button;
			p_crec<=crec;
			p_cont<=(others=>'0');
			p_cont2<=(others=>'0');
			p_regtemp<=(others=>'0');
			addr_A<=std_logic_vector(ynext&xnext);
			write_A<="1";------------------------------------------escribir
			data_in_A<="00001";-------------------------------------cabeza
			p_estado<=head1;
			
		when head1 =>------------------------------------------------------//////////////////HEAD1//////////////////
			
			pxnext<=xnext;
			pynext<=ynext;
			p_button<=button;
			p_crec<=crec;
			p_cont<=(others=>'0');
			p_cont2<="00001";
			p_regtemp<=(others=>'0');
			addr_A<=std_logic_vector(ynext&xnext);
			write_A<="1";------------------------------------------escribir
			data_in_A<="00001";-------------------------------------cabeza
			p_estado<=repose;
			
	 
	when die=> -----------------------------------------------------///////////////////////DIE//////////////////////
	
	p_crec<=crec;
	write_A<="0";
	p_button<=button;
	p_cont<=(others=>'0');
	p_cont2<="00001";
	p_estado<=Start;
	data_in_A<="00000";
	p_regtemp<=(others=>'0');
	pxnext<=xnext;
	pynext<=ynext;
	addr_A<=std_logic_vector(ynext&xnext);
end case;
end process;	

end Behavioral;


