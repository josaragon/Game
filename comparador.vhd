----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:43:22 11/01/2016 
-- Design Name: 
-- Module Name:    comparador - Behavioral 
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

entity comparador is

	Generic (Nbit: integer :=8;
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
end comparador;

architecture Behavioral of comparador is

signal po1,po2,po3 : std_logic;
signal u_data : unsigned (Nbit-1 downto 0);

begin
u_data<= unsigned (data);

sinc : process (clk,reset)
begin
	if (reset='1') then
		o1<='0'; 
		o2<='0';
		o3<='0';
	elsif (rising_edge(clk)) then
		o1<=po1; 
		o2<=po2;
		o3<=po3;
	end if;
	
end process;

comb : process (u_data)
begin
	 
	if (u_data>End_Of_Screen) then
	po1<='1';
	else
	po1<='0';
	end if;
	
	if (u_data>Start_Of_Pulse and u_data<End_Of_Pulse) then
	po2<='0';
	else
	po2<='1';
	end if;
	
	if (u_data=End_Of_Line) then
	po3<='1';
	else
	po3<='0';
	end if;
		
end process;

end Behavioral;

