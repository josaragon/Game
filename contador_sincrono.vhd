----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:08:37 10/31/2016 
-- Design Name: 
-- Module Name:    contador_sincrono - Behavioral 
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

entity contador_sincrono is
    Generic (Nbit: INTEGER := 8);
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           resets : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (Nbit-1 downto 0));
end contador_sincrono;

architecture Behavioral of contador_sincrono is
signal p_cuenta, cuenta : unsigned (Nbit-1 downto 0);

begin
Q<=std_logic_vector (cuenta);

sinc : process (clk,	reset, resets)
begin
	if (reset='1') then
		cuenta<=(others=>'0');
		
   elsif(rising_edge(clk)) then 
			if (resets='1') then
				cuenta<=(others=>'0');
			else	
				cuenta<= p_cuenta;	
			end if;
	end if;
end process;

comb : process (enable, cuenta)
begin
	if (enable='1') then
		p_cuenta<=cuenta+1;
	else
		p_cuenta<=cuenta;
	end if;
end process;
end Behavioral;

