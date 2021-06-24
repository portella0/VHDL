----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:22:12 05/10/2021 
-- Design Name: 
-- Module Name:    cronometro_digital - Matheus_Portella 
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cronometro_digital is
    Port ( clock : in  STD_LOGIC; 
           reset : in  STD_LOGIC;
           start_stop : in  STD_LOGIC;
           incr_decr : in  STD_LOGIC;
           display : out  STD_LOGIC_VECTOR (6 downto 0);
           display_en : out  STD_LOGIC_VECTOR (3 downto 0));
end cronometro_digital;

architecture Matheus_Portella of cronometro_digital is

	--valores dos numeros no display
	constant num_1 : STD_LOGIC_VECTOR (6 downto 0) := "1001111";
	constant num_2 : STD_LOGIC_VECTOR (6 downto 0) := "0010010";
	constant num_3 : STD_LOGIC_VECTOR (6 downto 0) := "0000110";
	constant num_4 : STD_LOGIC_VECTOR (6 downto 0) := "1001100";
	constant num_5 : STD_LOGIC_VECTOR (6 downto 0) := "0100100";
	constant num_6 : STD_LOGIC_VECTOR (6 downto 0) := "0100000";
	constant num_7 : STD_LOGIC_VECTOR (6 downto 0) := "0001111";
	constant num_8 : STD_LOGIC_VECTOR (6 downto 0) := "0000000";
	constant num_9 : STD_LOGIC_VECTOR (6 downto 0) := "0000100";
	constant num_0 : STD_LOGIC_VECTOR (6 downto 0) := "0000001";
	constant desligado : STD_LOGIC_VECTOR (6 downto 0) := "1111111";
	
	signal clock_1Hz : STD_LOGIC := '0';
	signal clock_mux : STD_LOGIC := '0';
	signal cont_mux : integer := 0; --contador mux
	signal min1 : integer := 0; --dado dezenas minutos
	signal min2 : integer := 0; --dado unidades minutos
	signal seg1 : integer := 0; --dado dezenas minutos
	signal seg2 : integer := 0; --dado unidades  segundos
	signal min1_dec : STD_LOGIC_VECTOR (6 downto 0); 
	signal min2_dec : STD_LOGIC_VECTOR (6 downto 0); 
	signal seg1_dec : STD_LOGIC_VECTOR (6 downto 0); 
	signal seg2_dec : STD_LOGIC_VECTOR (6 downto 0); 
	signal reg_reset1, reg_reset2 : STD_LOGIC := '0'; 
	signal enable_reset : STD_LOGIC := '0';   

begin
	
	div_clock:process(clock)
		variable cont : integer := 0;
		variable cont_mux_div : integer := 0;
	begin
		if clock'event and clock = '1' then
			if cont < 49_999_999 then
				cont := cont + 1;
			else
				cont := 0;
			end if;
			
			if cont < 25_000_000 then
				clock_1Hz <= '1';
			else
				clock_1Hz <= '0';
			end if;
		end if;
		
		if clock'event and clock = '1' then
			if cont_mux_div < 49_999 then
				cont_mux_div := cont + 1;
			else
				cont_mux_div := 0;
			end if;
			
			if cont_mux_div < 25_000 then
				clock_mux <= '1';
			else
				clock_mux <= '0';
			end if;
		end if;
	end process div_clock;

	shift_register:process(clock_1Hz) 
	begin
		if clock_1Hz'event and clock_1Hz = '1' then
			--reset 
			reg_reset2 <= reg_reset1;
			reg_reset1 <= reset;			
		end if;
	end process shift_register;
	
	enable_reset <= '1' when (reg_reset1 = '1') and (reg_reset2 ='0') else 
				   '0';
	
	contador_mux:process(clock_mux) --contador 0-3
	begin
		if clock_mux'event and clock_mux = '1' then
			if cont_mux < 3 then
				cont_mux <= cont_mux +1;
			else
				cont_mux <= 0;
			end if;
		end if;
	end process contador_mux;

	--contador tempo
	contador_tempo:process(clock_1Hz, start_stop, incr_decr) 
	begin
		if clock_1Hz'event and clock_1Hz = '1' then
			if enable_reset = '1' then
				min1 <= 0;
				min2 <= 0;
				seg1 <= 0;
				seg2 <= 0;
			elsif start_stop = '1' then
				if incr_decr = '1' then
					if seg2 < 9 then
						seg2 <= seg2 +1;
					else
						seg2 <= 0;
						if seg1 < 5 then
							seg1 <= seg1 + 1;
						else
							seg1 <= 0;
							if min2 < 9 then
								min2 <= min2 + 1;
							else
								min2 <= 0;	
								if min1 < 5 then
									min1 <= min1 + 1;
								else
									min1 <= 0;	
								end if;
							end if;
						end if;
					end if;	
				elsif incr_decr = '0' then
					if seg2 > 0 then
						seg2 <= seg2 -1;
					else
						seg2 <= 9;
						if seg1 > 0 then
							seg1 <= seg1 - 1;
						else
							seg1 <= 5;
							if min2 > 0 then
								min2 <= min2 - 1;
							else
								min2 <= 9;	
								if min1 > 0 then
									min1 <= min1 - 1;
								else
									min1 <= 5;	
								end if;
							end if;
						end if;
					end if;
				end if;	
			end if;
		end if;
	end process contador_tempo;

	decodificador:process(min1, min2, seg1, seg2) --decodifica os valores dos dados
	begin
		--display dezena minuto
		case min1 is
			when 0 => min1_dec <= num_0;
			when 1 => min1_dec <= num_1;
			when 2 => min1_dec <= num_2;
			when 3 => min1_dec <= num_3;
			when 4 => min1_dec <= num_4;
			when 5 => min1_dec <= num_5;
			when others => min1_dec <= desligado;
		end case;
		
		--display unidade minuto
		case min2 is
			when 0 => min2_dec <= num_0;
			when 1 => min2_dec <= num_1;
			when 2 => min2_dec <= num_2;
			when 3 => min2_dec <= num_3;
			when 4 => min2_dec <= num_4;
			when 5 => min2_dec <= num_5;
			when 6 => min2_dec <= num_6;
			when 7 => min2_dec <= num_7;
			when 8 => min2_dec <= num_8;
			when 9 => min2_dec <= num_9;
			when others => min2_dec <= desligado;
		end case;
		
		--display dezena segundo
		case seg1 is
			when 0 => seg1_dec <= num_0;
			when 1 => seg1_dec <= num_1;
			when 2 => seg1_dec <= num_2;
			when 3 => seg1_dec <= num_3;
			when 4 => seg1_dec <= num_4;
			when 5 => seg1_dec <= num_5;
			when others => seg1_dec <= desligado;
		end case;
		
		--display unidade segundo
		case seg2 is
			when 0 => seg2_dec <= num_0;
			when 1 => seg2_dec <= num_1;
			when 2 => seg2_dec <= num_2;
			when 3 => seg2_dec <= num_3;
			when 4 => seg2_dec <= num_4;
			when 5 => seg2_dec <= num_5;
			when 6 => seg2_dec <= num_6;
			when 7 => seg2_dec <= num_7;
			when 8 => seg2_dec <= num_8;
			when 9 => seg2_dec <= num_9;
			when others => seg2_dec <= desligado;
		end case;
	end process decodificador;

	--escreve no display
	mux:process(cont_mux, min1_dec, min2_dec, seg1_dec, seg2_dec)
	begin
		if cont_mux = 0 then
			display_en <= "0111";
			display <= min1_dec;
		elsif	cont_mux = 1 then
			display_en <= "1011";
			display <= min2_dec;
		elsif	cont_mux = 2 then
			display_en <= "1101";
			display <= seg1_dec;
		elsif	cont_mux = 3 then
			display_en <= "1110";
			display <= seg2_dec;
		else
			display_en <= "1111";
			display <= desligado;
		end if;
	end process mux;
	
end Matheus_Portella;

