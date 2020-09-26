----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:21:01 12/29/2016 
-- Design Name: 
-- Module Name:    fms_Alb - Behavioral 
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

entity fms_Alb is
Port ( clk : in STD_LOGIC;
rst : in STD_LOGIC;
Up : in STD_LOGIC;
Down : in STD_LOGIC;
Leftt : in STD_LOGIC;
Rightt : in STD_LOGIC;
swe : in STD_LOGIC;
O3_y : in STD_LOGIC;
data_out_A : in std_logic_vector(4 downto 0);
Addr_A : out std_logic_vector(9 downto 0);
Write_A: out std_logic_VECTOR(0 DOWNTO 0); --- Aquí cambia
Data_in_A : out std_logic_vector(4 downto 0));
end fms_Alb;

architecture Behavioral of fms_Alb is

type estado is (start, repose, direccion, move, borro, draw, die, swait);
signal state,p_state : estado;
--Posicion_serpiente
signal pxnext,pynext,xnext,ynext: unsigned(4 downto 0);
constant inicio : std_logic_vector := "0111101111";
--Contador
signal cont,pcont : unsigned (4 downto 0);
signal sat : std_logic;
--constant maxcuenta : unsigned := "11111"; --31
constant maxcuenta : unsigned := "01111"; --31

-- botones
signal button,p_button: unsigned(1 downto 0);
-- numero de crecimientos y seta
signal p_crec,crec: unsigned(4 downto 0);
signal hset,phset : std_logic; -- hay seta o no
-- direccion previa
signal addr_ant,p_addr_ant :  std_logic_vector(9 downto 0);

signal ab,pab : unsigned(9 downto 0);

begin


 -- RESET ASINCRONO --
 Sinc: process(clk,rst)
 begin
 if(rst='1') then
	state <= start;
	cont<=(others=>'0');
	button<=(others=>'0');
	crec<=(others=>'0');
	addr_ant<=(others=>'0');
	hset<='0';
	xnext<="01111";
	ynext<="01111";
	cont<=(others=>'0');
	ab<=(others=>'0');
	button<=(others=>'0');
	addr_ant<=(others=>'0');
 elsif (rising_edge(clk)) then
	state<= p_state;
	xnext<=pxnext;
	ynext<=pynext;
	cont<=pcont;
	button<=p_button;
	crec<=p_crec;
	addr_ant<=p_addr_ant;
	hset<=phset;
	ab<=pab;
 end if;
 end process; 
 
 count : process(O3_y,cont)
 begin	
	if (O3_y='1') then
		if (cont>=maxcuenta) then
			pcont<=(others=>'0');
		else
			pcont<=cont+1;
		end if;					
	else
		pcont<= cont ;
	end if;
				
	if (cont>=maxcuenta)
		then sat <= '1';	
	else
		sat <= '0'; 
	end if;		

end process;

maquina : process (xnext,ynext,button,crec,state,Up,Down,Leftt,Rightt,swe,sat,data_out_A,addr_ant,hset,ab)
begin

case state is
	-- Aquí empieza el juego , todo parado, esperando a que pulsemos swe
	when start =>
	-- salidas --
	Addr_A <=inicio;
	Write_A <="0";
	Data_in_A <=(others=>'0');
	phset<=hset;
	pab<=(others=>'0');
	pxnext<=xnext;
	pynext<=ynext;
	p_button<=button;
	p_crec<=crec;
	p_addr_ant<=std_logic_vector(ynext&xnext);
	--
	if (swe='1') then
	p_state<=repose;
	else
	p_state<=start;
	end if;
	
	-- En este estado esperamos a sat y algun boton
	when repose =>
	-- salidas --
	Addr_A <=inicio;
	Write_A <="0";
	Data_in_A <=(others=>'0');
	phset<=hset;
	pab<=(others=>'0');
   p_addr_ant<=std_logic_vector(ynext&xnext); -- direccion en la que estamos
	pxnext<=xnext;
	pynext<=ynext;
	p_crec<=crec;
	--
	if(up='1')then p_button<="00";
	
	elsif(down='1')then p_button<="01";
	
	elsif(leftt='1')then p_button<="10";
	
	elsif(rightt='1')then p_button<="11";
	else p_button<=button;
	end if;
	
	if (sat='1') then
	p_state<=direccion;
	else
	p_state<=repose;
	end if;
	
	-- aqui ya hemos captado los botones hay que irse a la dirección
	-- como la direccion se actualiza en el siguiene ciclo hay que meter otro estado
	when direccion =>
	-- salidas --
	Addr_A <=std_logic_vector(ynext&xnext);
	Write_A <="0";
	Data_in_A <=(others=>'0');
	phset<=hset;
	p_button<=button;
	p_crec<=crec;
	pab<=(others=>'0');
	p_addr_ant<=addr_ant; -- direccion en la que estamos
	pxnext<=xnext;
	pynext<=ynext;
	--
	if(button="00")then----------------arriba
	pxnext<=xnext;pynext<=ynext-1;			
	elsif(button="01")then-----------abajo
	pxnext<=xnext;pynext<=ynext+1;			
	elsif(button="10")then-----------izquierda
	pxnext<=xnext-1;pynext<=ynext;			
	elsif(button="11")then-----------derecha
	pxnext<=xnext+1;pynext<=ynext;
	end if;
	p_state<=move;
	
	
	-- Aqui ya podemos utilizar la direcion a la que queremos ir
	-- vemos que hay y hacemos una cosa u otra
	-- si hay hueco o seta borramos cola o no 
	-- si hay muro o serpiente morimos
	when move =>
	-- salidas -- 
	Addr_A <=std_logic_vector(ynext&xnext); -- direccion a la que queremos ir
	Write_A <="0";
	Data_in_A <=(others=>'0');
	pxnext<=xnext;pynext<=ynext;
	phset<=hset;
	p_button<=button;
	pab<=(others=>'0');
	p_addr_ant<=addr_ant; -- direccion en la que estamos
	pxnext<=xnext;
	pynext<=ynext;
	p_state<=swait;
	p_crec<=crec;
	--
	
	
	-- hay que esperar un ciclo para que este el dato
	when swait=>
	Addr_A <=std_logic_vector(ynext&xnext); -- direccion a la que queremos ir
	Write_A <="0";
	Data_in_A <=(others=>'0');
	pxnext<=xnext;pynext<=ynext;
	p_button<=button;
	pab<=(others=>'0');
	p_addr_ant<=addr_ant; -- direccion en la que estamos
	pxnext<=xnext;
	pynext<=ynext;
	--SETA
	if(data_out_A="11110")then
		p_crec<=crec+1;	phset<='1';	p_state<=borro;
    -- HUECO
	elsif(data_out_A="00000") then 
		p_crec<=crec;	phset<='0';	p_state<=borro;
    -- OTRO
	else
		p_crec<=crec;	phset<='0';	p_state<=die;
	end if;
	
	-- aqui si hay seta sumo uno a la cola y si no la borro
	when borro =>
	
		if (hset='1') then
			Addr_A <=addr_ant;
			Write_A <="1";
			Data_in_A <=std_logic_vector(unsigned(data_out_A)+1);
		else
			Addr_A <=addr_ant;
			Write_A <="1";
			Data_in_A <=(others=>'0');
		end if;
		p_state<=draw;
		p_crec<=crec;
		pxnext<=xnext;pynext<=ynext;
		phset<=hset;
		p_button<=button;
		pab<=(others=>'0');
		p_addr_ant<=addr_ant; -- direccion en la que estamos
		pxnext<=xnext;
	   pynext<=ynext;
		
		
	-- una vez borrada la cola debo sumar a todos los cuerpos unos
	--al hueco al que voy pongo uno
	when draw => 
		-- salidas
		Addr_A <=std_logic_vector(ynext&xnext); -- direccion a la que queremos ir
		Write_A <="1";
		Data_in_A <="00001"; -- pongo la cabeza
		p_crec<=crec;
		pxnext<=xnext;pynext<=ynext;
		phset<=hset;
		p_button<=button;
		p_addr_ant<=addr_ant;
		pxnext<=xnext;
	   pynext<=ynext;
		
		Addr_A<=std_logic_vector(ab);
		pab<=ab+1;
		-- si no es ni hueco ni muro ni seta
		-- sumo uno
		if (data_out_A/="00000"  or data_out_A/="11111" or data_out_A/="11110") then
		Write_A <="1";
		Data_in_A <=std_logic_vector(unsigned(data_out_A)+1);
		else
		Write_A <="0";
		Data_in_A <=(others=>'0');
		end if;
		--end loop;
		if (ab=1023) then
		p_state<=draw;
		else
		p_state<=repose;
		end if;
	
	-- aqui morimos
	when die =>
		-- salidas
		Addr_A <=std_logic_vector(ynext&xnext); -- direccion a la que queremos ir
		Write_A <="0";
		Data_in_A <=(others=>'0'); -- pongo la cabeza
		p_crec<=crec;
		p_state<=start;
		pxnext<=xnext;pynext<=ynext;
		phset<=hset;
		p_button<=button;
		pab<=(others=>'0');
		p_addr_ant<=addr_ant;
		pxnext<=xnext;
	   pynext<=ynext;
	end case;
end process;

end Behavioral;

