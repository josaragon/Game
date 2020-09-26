----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:09:35 11/01/2016 
-- Design Name: 
-- Module Name:    VGA_DRIVER - Behavioral 
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

entity VGA_DRIVER is
			Generic (Nbit: INTEGER := 10);
			Port ( clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			-----------
			RED_in : in STD_LOGIC;
			GRN_in : in STD_LOGIC;
			BLUE_in : in STD_LOGIC;
			-----------
			ejex : out STD_LOGIC_VECTOR (Nbit-1 downto 0);
			ejey : out STD_LOGIC_VECTOR (Nbit-1 downto 0);
			-----------
			o3y : out std_logic;
			VS : out STD_LOGIC;
			HS : out STD_LOGIC;
			RED : out STD_LOGIC;
			GRN : out STD_LOGIC;
			BLUE : out STD_LOGIC);
end VGA_DRIVER;

architecture Behavioral of VGA_DRIVER is
---------------- SEÑALES ---------------------------------
signal p_clk_pixel : std_logic;
--- gen color --------
signal blank_h :  STD_LOGIC;
signal blank_v :  STD_LOGIC;
--------frec_pixel------
signal clk_pixel:  std_logic;
------------------------
signal o3s1,o3s2 : std_logic;
signal ejex_s,ejey_s : STD_LOGIC_VECTOR (Nbit-1 downto 0);
signal encv: std_logic;

-------------- COMPONENTES -------------------------------
component contador_sincrono
    Generic (Nbit: INTEGER := 10);
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end component;

component comparador
	Generic (Nbit: integer :=10;
	End_Of_Screen: integer :=10; --00001010
	Start_Of_Pulse: integer :=20; --00010100
	End_Of_Pulse: integer := 30; --00011110
	End_Of_Line: integer := 40); --00101000
	
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data : in  STD_LOGIC_vector (Nbit-1 downto 0);
           o1 : out  STD_LOGIC;
           o2 : out  STD_LOGIC;
           o3 : out  STD_LOGIC);
end component;
-------------------fin componentes-------------------------------------------


begin

ejex<=ejex_s;
ejey<=ejey_s;
o3y<=o3s2;

	and1 : process (clk_pixel,o3s1)
	begin
	encv<=(clk_pixel and o3s1);
	end process;

	gen_color:process(Blank_H, Blank_V, RED_in, GRN_in,BLUE_in)
	begin
		if (Blank_H='1' or Blank_V='1') then
		RED<= '0'; 
		GRN<='0';
		BLUE<='0';
		else
		RED<=RED_in; 
		GRN<=GRN_in;
		BLUE<=BLUE_in;
		end if;
	end process;
	
	p_clk_pixel <= not clk_pixel;
	div_frec:process(clk,reset)
	begin
		if (reset='1') then
		clk_pixel<='0';
		elsif (rising_edge(clk)) then
		clk_pixel<= p_clk_pixel;
		end if;
	end process;
	
	
	--gucjhxf--
	---- INSTANCIAS-------------------
	conth : contador_sincrono
	GENERIC MAP (Nbit=>10)
	PORT MAP (clk=>clk,	reset=>reset,	enable=>clk_pixel,	resets=>o3s1,	Q=>ejex_s);
		
	contv : contador_sincrono
	GENERIC MAP (Nbit=>10)
	PORT MAP (clk=>clk,	reset=>reset,	enable=>encv,	resets=>o3s2,	Q=>ejey_s);	
	
	comph : comparador
	GENERIC MAP (Nbit=>10,	End_Of_Screen=>639,	Start_Of_Pulse=>655,	End_Of_Pulse=>751,	End_Of_Line=>799)
   PORT MAP( clk=>clk,	reset=>reset,	data=>ejex_s,	o1=>blank_h,	o2=>HS,	o3=>o3s1);
   
	compv : comparador
	GENERIC MAP (Nbit=>10,	End_Of_Screen=>479,	Start_Of_Pulse=>489,	End_Of_Pulse=>491,	End_Of_Line=>520)
   PORT MAP( clk=>clk,	reset=>reset,	data=>ejey_s,	o1=>blank_v,	o2=>VS,	o3=>o3s2);
   
end Behavioral;

