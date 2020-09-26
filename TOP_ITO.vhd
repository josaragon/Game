----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:20:00 11/25/2016 
-- Design Name: 
-- Module Name:    TOP_ITO - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_ITO is
			Generic (Nbit: INTEGER := 10);
			Port ( clk : in STD_LOGIC;
			reset : in STD_LOGIC;
			--upin : in std_logic;
			--downin : in std_logic;
			--leftin : in std_logic;
			--rightin : in std_logic;
			led_up : out std_logic;
			led_right : out std_logic;
			led_down: out std_logic;
			led_left: out std_logic;
			swein :in std_logic;
			SPI_MISO : in  STD_LOGIC;
         --SW_in : in  STD_LOGIC;
			--SW_prueba : in STD_LOGIC;
			SCK : out  STD_LOGIC;
         SHDN : out  STD_LOGIC;
         C_S : out  STD_LOGIC;
			DAC_CS: out STD_LOGIC;
			SF_CE0: out STD_LOGIC;
			FPGA_INIT_B: out STD_LOGIC;
         AD_Conv : out  STD_LOGIC;
         SPI_MOSI : out  STD_LOGIC;
			VS : out STD_LOGIC;
			HS : out STD_LOGIC;
			RED : out STD_LOGIC;
			GRN : out STD_LOGIC;
			BLUE : out STD_LOGIC);
			
end TOP_ITO;


architecture Behavioral of TOP_ITO is
-- Represent == DRAW
signal datab_toDRAW: std_logic_vector(4 downto 0);
signal addrb_toRAM : std_logic_vector(9 downto 0); 

signal dataA_toFSM: std_logic_vector(4 downto 0);
signal dataA_toRAM: std_logic_vector(4 downto 0);
signal addrA_toRAM : std_logic_vector(9 downto 0); 

signal ejex_toDRAW,ejey_toDRAW : STD_LOGIC_VECTOR (Nbit-1 downto 0);

signal red_tovga , grn_tovga, blue_tovga : STD_LOGIC;

signal o3y_driver_toFSM : std_logic;

signal wea_fsm_toRAM : std_logic_VECTOR(0 DOWNTO 0);

signal addr_dibuja_torom : STD_LOGIC_VECTOR (12 downto 0);

signal douta_rom_todibuja : STD_LOGIC_VECTOR (2 downto 0);

signal addr_dibuja_torom_GO : STD_LOGIC_VECTOR (13 downto 0);

signal douta_rom_todibuja_GO : STD_LOGIC_VECTOR (2 downto 0);

signal fsm_todibuja_gameover : std_logic;

signal ADCleido,ADconvertir,up_s,down_s,left_s,right_s: std_logic;
signal Qvertical,Qhorizontal: std_logic_vector(13 downto 0);

COMPONENT VGA_DRIVER
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
end COMPONENT;

COMPONENT RAM_SNAKE
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
  );
END COMPONENT;


COMPONENT MYROM
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

COMPONENT rom_gameover
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;

COMPONENT dibuja 
	Port ( 	eje_x : in STD_LOGIC_VECTOR (9 downto 0);
				eje_y : in STD_LOGIC_VECTOR (9 downto 0);
				--- ram---
				datab : in STD_LOGIC_VECTOR (4 downto 0);
				addrb: out STD_LOGIC_VECTOR (9 downto 0);
				------ rom -------
				addr_ROM : out STD_LOGIC_VECTOR (12 downto 0);
				data_rom : in STD_LOGIC_VECTOR (2 downto 0);
				-------------------
				RED : out STD_LOGIC;
				GRN : out STD_LOGIC;
				BLUE : out STD_LOGIC;
				---------------------
				game_over : in std_logic;
				addr_ROM_GO : out STD_LOGIC_VECTOR (13 downto 0);
				data_rom_GO : in STD_LOGIC_VECTOR (2 downto 0));
end COMPONENT;

	COMPONENT fsm_def
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
		Write_A: out std_logic_vector(0 downto 0);
		Data_in_A : out std_logic_vector(4 downto 0);
		fgame_over: out std_logic);
	END COMPONENT;

	COMPONENT MaquinaJoystick
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
	END COMPONENT;
	
	COMPONENT SpiJoystick
	Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           ADC : in  STD_LOGIC;
           SPI_MISO : in  STD_LOGIC;
			  SW_in: in STD_LOGIC;
           leido : out  STD_LOGIC;
           CH0 : out  STD_LOGIC_VECTOR (13 downto 0);
           CH1 : out  STD_LOGIC_VECTOR (13 downto 0);
           AD_CONV : out  STD_LOGIC;
           SCK_M : out  STD_LOGIC;
           SHDN : out  STD_LOGIC;
           C_S : out  STD_LOGIC;
           SPI_MOSI : out  STD_LOGIC);
	END COMPONENT;

attribute box_type : string; 
attribute box_type of RAM_SNAKE : component is "black_box"; 

-------------------------------------------------------------
	begin
	
	MyRAM : RAM_SNAKE
  PORT MAP (
    clka => clk,
    wea => wea_fsm_toRAM,
    addra => addrA_toRAM,
    dina => dataA_toRAM,
    douta => dataA_toFSM,
    clkb => clk,
    web => "0",
    addrb => addrb_toRAM,
    dinb => (others=>'0'),
    doutb => datab_toDRAW
  );
  
  Represent :  dibuja
	Port MAP ( 	eje_x => ejex_toDRAW,
					eje_y => ejey_toDRAW,
					--- ram---
					datab =>  datab_toDRAW,
					addrb =>  addrb_toRAM,
					---- rom
					addr_ROM=> addr_dibuja_torom,
					data_rom=> douta_rom_todibuja,
					----
					RED  =>   red_tovga,
					GRN  =>	 grn_tovga,
					BLUE =>	 blue_tovga,
					---- ROM GO
					game_over => fsm_todibuja_gameover,
					addr_ROM_GO=> addr_dibuja_torom_GO,
					data_rom_GO=> douta_rom_todibuja_GO
					);

  VGA_driver1 : VGA_DRIVER
  Generic MAP(Nbit => 10)
  
  Port MAP( clk   => clk,
				reset => reset,
				-----------
				RED_in =>  red_tovga,
				GRN_in =>  grn_tovga,
				BLUE_in => blue_tovga,
				-----------
				ejex =>	ejex_toDRAW,
				ejey =>	ejey_toDRAW,
				-----------
				o3y => 	o3y_driver_toFSM, 
				VS =>		VS,
				HS =>		HS,
				RED =>	RED,
				GRN =>	GRN,
				BLUE =>	BLUE
				);
			
	mi_fsm : fsm_def
		Port Map( 
				clk => clk,
				rst => reset,
				Up => up_s,
				Down => down_s,
				Left => left_s,
				Right => right_s,
				Swe => swein,
				O3_y => o3y_driver_toFSM,
				data_out_A => dataA_toFSM,
				Addr_A=> addrA_toRAM,
				Write_A=> wea_fsm_toRAM,
				Data_in_A=> dataA_toRAM,
				fgame_over =>fsm_todibuja_gameover);
				
	mi_rom : MYROM
  PORT MAP (
    clka => clk,
    addra => addr_dibuja_torom,
    douta => douta_rom_todibuja
  );
  
  mi_rom_GO : rom_gameover
  PORT MAP (
    clka => clk,
    addra => addr_dibuja_torom_GO,
    douta => douta_rom_todibuja_GO
  );
  
  maquina_joystick: MaquinaJoystick
	PORT MAP (
		clk=>clk,
      reset=>reset,
		leido=>ADCleido,
      inQ1=>Qvertical,
      inQ2=>Qhorizontal,
		SW_prueba=>o3y_driver_toFSM,
		--sw_enable=>sw_in,
      up=>up_s,
      right=>right_s,
      down=>down_s,
      left=>left_s,
		led_up=>led_up,
		led_right=>led_right,
		led_down=>led_down,
		led_left=>led_left,
      ADC=>ADconvertir);
		
	Joystick: SpiJoystick
	PORT MAP (
		clk=>clk,
      reset=>reset,
      ADC=>ADconvertir,
      SPI_MISO=>SPI_MISO,
		SW_in=>swein,
      leido=>ADCleido,
      CH0=>Qvertical,
      CH1=>Qhorizontal,
      AD_CONV=>AD_Conv,
      SCK_M=>SCK,
      SHDN=>SHDN,
      C_S=>C_S,
      SPI_MOSI=>SPI_MOSI);
				
FPGA_INIT_B<='0';
SF_CE0<='1';
DAC_CS<='1';

end Behavioral;

