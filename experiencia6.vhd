----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:50:23 06/07/2021 
-- Design Name: 
-- Module Name:    cronometro_digital_lcd - Matheus_Portella 
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

entity cronometro_digital_lcd is
    Port ( clock : in  STD_LOGIC;
           clock_sel : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start_stop : in  STD_LOGIC;
           incr_decr : in  STD_LOGIC;
           config_en : in  STD_LOGIC;
           ajustes : in  STD_LOGIC_VECTOR (5 downto 0);
           lcd_data : out  STD_LOGIC_VECTOR (7 downto 0);
           lcd_en : out  STD_LOGIC;
           lcd_rs : out  STD_LOGIC);
end cronometro_digital_lcd;

architecture Matheus_Portella of cronometro_digital_lcd is

	signal estado : integer := 0;
	signal posicao_tb : integer := 0;
	
	type tipo_tabela is array (0 to 19) of std_logic_vector (7 downto 0);
	
	signal tabela : tipo_tabela := (
						x"38", -- config
						x"0F", -- cursor
						x"06", -- deslocamento do cursor
						x"01", -- limpeza
						-- escreve dados
						x"30", -- 0
						x"30", -- 0
						x"3A", -- :
						x"30", -- 0
						x"30", -- 0
						x"3A", -- :
						x"30", -- 0
						x"30", -- 0
						x"C0", -- segunda linha
						x"4D", -- M
						x"4F", -- O
						x"44", -- D
						x"4F", -- O
						x"3D", -- = 
						x"4E", -- N
						x"80" -- primeira linha
					   );

	--controle inicializaçao lcd
	signal inicializar_display : STD_LOGIC := '0';
	
	--valores dos numeros no display
	constant num_1 : STD_LOGIC_VECTOR (7 downto 0) := x"31";
	constant num_2 : STD_LOGIC_VECTOR (7 downto 0) := x"32";
	constant num_3 : STD_LOGIC_VECTOR (7 downto 0) := x"33";
	constant num_4 : STD_LOGIC_VECTOR (7 downto 0) := x"34";
	constant num_5 : STD_LOGIC_VECTOR (7 downto 0) := x"35";
	constant num_6 : STD_LOGIC_VECTOR (7 downto 0) := x"36";
	constant num_7 : STD_LOGIC_VECTOR (7 downto 0) := x"37";
	constant num_8 : STD_LOGIC_VECTOR (7 downto 0) := x"38";
	constant num_9 : STD_LOGIC_VECTOR (7 downto 0) := x"39";
	constant num_0 : STD_LOGIC_VECTOR (7 downto 0) := x"30";
	constant desligado : STD_LOGIC_VECTOR (7 downto 0) := x"20";
	constant letra_N : STD_LOGIC_VECTOR (7 downto 0) := x"4E";
	constant letra_P : STD_LOGIC_VECTOR (7 downto 0) := x"50";

	--clock
	signal clock_div : STD_LOGIC := '0';
	signal clock_mux : STD_LOGIC := '0';
	
	--tempo
	signal hora1 : integer := 0; --dado dezenas horas
	signal hora2 : integer := 0; --dado unidades horas
	signal min1 : integer := 0; --dado dezenas minutos
	signal min2 : integer := 0; --dado unidades minutos
	signal seg1 : integer := 0; --dado dezenas minutos
	signal seg2 : integer := 0; --dado unidades  segundos
	
	signal start_control : STD_LOGIC := '0';
	
	--reset
	signal reg_reset1, reg_reset2 : STD_LOGIC := '0'; 
	signal enable_reset : STD_LOGIC := '0'; 
	
	--ajustes
	signal ajuste_hora_dez : integer := 2; 
	signal ajuste_hora_un : integer := 3; 
	signal ajuste_min_dez : integer := 5; 
	signal ajuste_min_un : integer := 9; 
	signal ajuste_seg_dez : integer := 5;
	signal ajuste_seg_un : integer := 9;
	signal ajuste_hora_dez1, ajuste_hora_dez2 : STD_LOGIC := '0'; 
	signal ajuste_hora_un1, ajuste_hora_un2 : STD_LOGIC := '0'; 
	signal ajuste_min_dez1, ajuste_min_dez2 : STD_LOGIC := '0'; 
	signal ajuste_min_un1, ajuste_min_un2 : STD_LOGIC := '0'; 
	signal ajuste_seg_dez1, ajuste_seg_dez2 : STD_LOGIC := '0'; 
	signal ajuste_seg_un1, ajuste_seg_un2 : STD_LOGIC := '0'; 
	signal enable_ajuste_hora_dez,
			 enable_ajuste_hora_un,
			 enable_ajuste_min_dez, 
			 enable_ajuste_min_un, 
			 enable_ajuste_seg_dez, 
			 enable_ajuste_seg_un : STD_LOGIC := '0'; 
			 
begin

	div_clock:process(clock, clock_sel)
		variable cont : integer := 0;
		variable cont_mux_div : integer := 0;
	begin
		if clock'event and clock = '1' then
			if clock_sel = '0' then
				if cont < 49_999_999 then
					cont := cont + 1;
				else
					cont := 0;
				end if;
			
				if cont < 25_000_000 then
					clock_div <= '1';
				else
					clock_div <= '0';
				end if;
				
			elsif clock_sel = '1' then
				if cont < 4_999_999 then
					cont := cont + 1;
				else
					cont := 0;
				end if;
			
				if cont < 2_500_000 then
					clock_div <= '1';
				else
					clock_div <= '0';
				end if;
			end if;
		end if;
		
		if clock'event and clock = '1' then
			if cont_mux_div < 49_999 then
				cont_mux_div := cont_mux_div + 1;
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
	
	shift_register:process(clock_div) 
	begin
		if clock_div'event and clock_div = '1' then
			--ajustes
			ajuste_hora_dez2 <= ajuste_hora_dez1;
			ajuste_hora_dez1 <= ajustes(5);		
			
			ajuste_hora_un2 <= ajuste_hora_un1;
			ajuste_hora_un1 <=  ajustes(4);	
			
			ajuste_min_dez2 <= ajuste_min_dez1;
			ajuste_min_dez1 <= ajustes(3);		
			
			ajuste_min_un2 <= ajuste_min_un1;
			ajuste_min_un1 <=  ajustes(2);		
			
			ajuste_seg_dez2 <= ajuste_seg_dez1;
			ajuste_seg_dez1 <=  ajustes(1);		
			
			ajuste_seg_un2 <= ajuste_seg_un1;
			ajuste_seg_un1 <=  ajustes(0);		
			
			--reset 
			reg_reset2 <= reg_reset1;
			reg_reset1 <= reset;			
		end if;
	end process shift_register;
	
	--enable reset
	enable_reset <= '1' when (reg_reset1 = '1') and (reg_reset2 ='0') else 
				   '0';
					
	--enable ajustes
	enable_ajuste_hora_dez <= '1' when (ajuste_hora_dez1 = '1') and (ajuste_hora_dez2 ='0') else 
				   '0';
	enable_ajuste_hora_un <= '1' when (ajuste_hora_un1 = '1') and (ajuste_hora_un2 ='0') else 
				   '0';
	enable_ajuste_min_dez <= '1' when (ajuste_min_dez1 = '1') and (ajuste_min_dez2 ='0') else 
				   '0';
	enable_ajuste_min_un <= '1' when (ajuste_min_un1 = '1') and (ajuste_min_un2 ='0') else 
				   '0';
	enable_ajuste_seg_dez <= '1' when (ajuste_seg_dez1 = '1') and (ajuste_seg_dez2 ='0') else 
				   '0';
	enable_ajuste_seg_un <= '1' when (ajuste_seg_un1 = '1') and (ajuste_seg_un2 ='0') else 
				   '0';
	
	--contador tempo
	contador_tempo:process(clock_div, start_stop, incr_decr, config_en, reset, ajustes) 
	begin	
		if clock_div'event and clock_div = '1' then
			if config_en = '1' then
				start_control <= '0';
		
				--aumenta dezena horas
				if enable_ajuste_hora_dez = '1' then
					if ajuste_hora_dez < 2 then
						ajuste_hora_dez <= ajuste_hora_dez +1;
					else 
						ajuste_hora_dez <= 0;
					end if;
				else
					hora1 <= ajuste_hora_dez;
				end if;
				
				--aumenta unidade horas
				if enable_ajuste_hora_un = '1' then
					--passou das 20 horas
					if ajuste_hora_dez < 2 then
						if ajuste_hora_un < 9 then
							ajuste_hora_un <= ajuste_hora_un +1;
						else 
							ajuste_hora_un <= 0;
						end if;
					--menos q 20 horas
					else
						if ajuste_hora_un < 3 then
							ajuste_hora_un <= ajuste_hora_un +1;
						else 
							ajuste_hora_un <= 0;
						end if;
					end if;
				else
					hora2 <= ajuste_hora_un;
				end if;
				
				--aumenta dezena minutos
				if enable_ajuste_min_dez = '1' then
					if ajuste_min_dez < 5 then
						ajuste_min_dez <= ajuste_min_dez +1;
					else 
						ajuste_min_dez <= 0;
					end if;
				else
					min1 <= ajuste_min_dez;
				end if;
				
				--aumenta unidade minutos
				if enable_ajuste_min_un = '1' then
					if ajuste_min_un < 9 then
						ajuste_min_un <= ajuste_min_un +1;
					else 
						ajuste_min_un <= 0;
					end if;
				else
					min2 <= ajuste_min_un;
				end if;
				
				--aumenta dezena segundos
				if enable_ajuste_seg_dez = '1' then
					if ajuste_seg_dez < 5 then
						ajuste_seg_dez <= ajuste_seg_dez +1;
					else 
						ajuste_seg_dez <= 0;
					end if;
				else
					seg1 <= ajuste_seg_dez;
				end if;
				
				--aumenta unidade segundos
				if enable_ajuste_seg_un = '1' then
					if ajuste_seg_un < 9 then
						ajuste_seg_un <= ajuste_seg_un +1;
					else 
						ajuste_seg_un <= 0;
					end if;
				else
					seg2 <= ajuste_seg_un;
				end if;
			end if;
			
			if start_control = '0' and config_en = '0' then
				if incr_decr = '1' then
					hora1 <= 0;
					hora2 <= 0;
					min1 <= 0;
					min2 <= 0;
					seg1 <= 0;
					seg2 <= 0;
				elsif incr_decr = '0' then	
					hora1 <= ajuste_hora_dez;
					hora2 <= ajuste_hora_un;
					min1 <= ajuste_min_dez;
					min2 <= ajuste_min_un;
					seg1 <= ajuste_seg_dez;
					seg2 <= ajuste_seg_un;				
				end if;
				start_control <= '1';
			
			
			elsif enable_reset = '1' then
				if incr_decr = '1' then
					hora1 <= 0;
					hora2 <= 0;
					min1 <= 0;
					min2 <= 0;
					seg1 <= 0;
					seg2 <= 0;
				elsif incr_decr = '0' then	
					hora1 <= 2;
					hora2 <= 3;				
					min1 <= 5;
					min2 <= 9;
					seg1 <= 5;
					seg2 <= 9;				
				end if;
				ajuste_hora_dez <= 2;
				ajuste_hora_un <= 3;
				ajuste_min_dez <= 5;
				ajuste_min_un <= 9;
				ajuste_seg_dez <= 5;
				ajuste_seg_un <= 9;
				start_control <= '0';
			elsif start_stop = '1' and config_en = '0' then
				--incrementa
				if incr_decr = '1' then
					if (hora1 = ajuste_hora_dez) and (hora2 = ajuste_hora_un) and
					(min1 = ajuste_min_dez) and (min2 = ajuste_min_un) and 
					(seg1 = ajuste_seg_dez) and (seg2 = ajuste_seg_un) then
						hora1 <= 0;
						hora2 <= 0;
					   min1 <= 0;
						min2 <= 0;
						seg1 <= 0;
						seg2 <= 0;
					
					elsif seg2 < 9 then
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
									if hora1 < 2 then
										if hora2 < 9 then
											hora2 <= hora2 + 1;
										else
											hora2 <= 0;
											hora1 <= hora1 + 1;	
										end if;
									else
										if hora2 < 3 then
											hora2 <= hora2 + 1;
										else
											hora2 <= 0;
											hora1 <= 0;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;	
				--decrementa
				elsif incr_decr = '0' then
					if (hora1 = 0) and (hora2 = 0) and (min1 = 0) and (min2 = 0) and (seg1 = 0) and (seg2 = 0) then
						hora1 <= ajuste_hora_dez;
						hora2 <= ajuste_hora_un;
						min1 <= ajuste_min_dez;
						min2 <= ajuste_min_un;
						seg1 <= ajuste_seg_dez;
						seg2 <= ajuste_seg_un;	
					
					
					elsif seg2 > 0 then
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
									if hora2 > 0 then
										hora2 <= hora2 -1;
									else
										hora2 <= 9;
										if hora1 > 0 then
											hora1 <= hora1 - 1;
										else
											hora1 <= 2;
											hora2 <= 3;
										end if;
									end if;	
								end if;
							end if;
						end if;
					end if;
				end if;	
			end if;
		end if;
	end process contador_tempo;
	
	fsm_gen:process(clock_mux, inicializar_display)
	begin
		if clock_mux'event and clock_mux = '1' then
			if estado < 2 then
				estado <= estado +1;
			else
				estado <= 0;
				if inicializar_display = '0' then
					if posicao_tb < 3 then
						posicao_tb <= posicao_tb + 1;
					else
						posicao_tb <= posicao_tb + 1;
						inicializar_display <= '1';
					end if; 
				else
					if posicao_tb < 19 then
						posicao_tb <= posicao_tb + 1;
					else
						posicao_tb <= 4;
					end if; 
				end if;
			end if;		
		end if;
	end process fsm_gen;

	atualizar_tabela:process(hora1, hora2, min1, min2, seg1, seg2, config_en)
	begin
		--muda o display para indicar se está em modo de contatem ou programação
		if config_en = '1' then
			tabela(18) <= letra_P;
		else
			tabela(18) <= letra_N;
		end if;
		
		--display dezena horas
		case hora1 is
			when 0 => tabela(4) <= num_0;
			when 1 => tabela(4) <= num_1;
			when 2 => tabela(4) <= num_2;
			when others => tabela(4) <= desligado;
		end case;

		--display unidade horas
		case hora2 is
			when 0 => tabela(5) <= num_0;
			when 1 => tabela(5) <= num_1;
			when 2 => tabela(5) <= num_2;
			when 3 => tabela(5) <= num_3;
			when 4 => tabela(5) <= num_4;
			when 5 => tabela(5) <= num_5;
			when 6 => tabela(5) <= num_6;
			when 7 => tabela(5) <= num_7;
			when 8 => tabela(5) <= num_8;
			when 9 => tabela(5) <= num_9;
			when others => tabela(5) <= desligado;
		end case;

		--display dezena minuto
		case min1 is
			when 0 => tabela(7) <= num_0;
			when 1 => tabela(7) <= num_1;
			when 2 => tabela(7) <= num_2;
			when 3 => tabela(7) <= num_3;
			when 4 => tabela(7) <= num_4;
			when 5 => tabela(7) <= num_5;
			when others => tabela(7) <= desligado;
		end case;
		
		--display unidade minuto
		case min2 is
			when 0 => tabela(8) <= num_0;
			when 1 => tabela(8) <= num_1;
			when 2 => tabela(8) <= num_2;
			when 3 => tabela(8) <= num_3;
			when 4 => tabela(8) <= num_4;
			when 5 => tabela(8) <= num_5;
			when 6 => tabela(8) <= num_6;
			when 7 => tabela(8) <= num_7;
			when 8 => tabela(8) <= num_8;
			when 9 => tabela(8) <= num_9;
			when others => tabela(8) <= desligado;
		end case;
		
		--display dezena segundo
		case seg1 is
			when 0 => tabela(10) <= num_0;
			when 1 => tabela(10) <= num_1;
			when 2 => tabela(10) <= num_2;
			when 3 => tabela(10) <= num_3;
			when 4 => tabela(10) <= num_4;
			when 5 => tabela(10) <= num_5;
			when others => tabela(10) <= desligado;
		end case;
		
		--display unidade segundo
		case seg2 is
			when 0 => tabela(11) <= num_0;
			when 1 => tabela(11) <= num_1;
			when 2 => tabela(11) <= num_2;
			when 3 => tabela(11) <= num_3;
			when 4 => tabela(11) <= num_4;
			when 5 => tabela(11) <= num_5;
			when 6 => tabela(11) <= num_6;
			when 7 => tabela(11) <= num_7;
			when 8 => tabela(11) <= num_8;
			when 9 => tabela(11) <= num_9;
			when others => tabela(11) <= desligado;
		end case;
		
	end process atualizar_tabela;

	decoder_gen: process(estado, tabela, posicao_tb)
	begin 
		if estado = 1 then
			lcd_en <= '1';
		else
			lcd_en <= '0';
		end if;

		lcd_data <= tabela(posicao_tb);

		if posicao_tb < 4 or posicao_tb = 12  or posicao_tb = 19 then
			lcd_rs <= '0';
		else
			lcd_rs <= '1';
		end if;	
	end process decoder_gen;

end Matheus_Portella;

