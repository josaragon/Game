library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity setaleatoria is
  generic (nbit: integer := 10); 
  port (
    enable : in std_logic;
    rst  : in  std_logic;
    clk    : in  std_logic;
    addrb  : out std_logic_vector (nbit-1 downto 0)
  );
end entity;

architecture Behavioral of setaleatoria is
    signal addrb_i    : std_logic_vector (nbit-1 downto 0);
    signal realim     : std_logic;

begin
    realim <= not(addrb_i(nbit-1) xor addrb_i(nbit-5));               
	addrb <= addrb_i;
	
    sinc : process (rst, clk, addrb_i) 
        begin
        if (rst = '1') then
               addrb_i <= (others=>'0');
        elsif (rising_edge(clk)) then
           if (enable = '1') then
                addrb_i <= std_logic_vector (unsigned(addrb_i(nbit-2 downto 0) & realim)+"101010101");
			end if;
			
        end if;
    end process;
			   
end architecture;