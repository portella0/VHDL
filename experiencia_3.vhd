----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:26:39 04/07/2021 
-- Design Name: 
-- Module Name:    placar_eletronico_digital - Matheus_Portella 
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

entity placar_eletronico_digital is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           incrementa_a : in  STD_LOGIC;
           decrementa_a : in  STD_LOGIC;
           incrementa_b : in  STD_LOGIC;
           decrementa_b : in  STD_LOGIC;
           display : out  STD_LOGIC_VECTOR (6 downto 0); -- bit 6 = A, bit 0 = G
           display_en : out  STD_LOGIC_VECTOR (3 downto 0));
end placar_eletronico_digital;

architecture Matheus_Portella of placar_eletronico_digital is
	
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

	signal clock_1k : STD_LOGIC := '0';
	signal cont : integer := 0; --contador
	signal dado_a : integer := 0; --dado a unidades
	signal dado_a_dez : integer := 0; --dado a dezenas
	signal dado_b : integer := 0; --dado b unidades
	signal dado_b_dez : integer := 0; --dado b dezenas
	signal dado_a_dez_dec : STD_LOGIC_VECTOR (6 downto 0); --dezenas a decodificadas
	signal dado_a_dec : STD_LOGIC_VECTOR (6 downto 0); --unidades a decodificadas
	signal dado_b_dez_dec : STD_LOGIC_VECTOR (6 downto 0); --dezenas b decodificadas
	signal dado_b_dec : STD_LOGIC_VECTOR (6 downto 0); --unidades b decodificadas
	signal reg_a1, reg_a2, reg_b1, reg_b2 : STD_LOGIC := '0'; 
	signal reg_a1_dec, reg_a2_dec, reg_b1_dec, reg_b2_dec : STD_LOGIC := '0'; 
	signal reg_reset1, reg_reset2 : STD_LOGIC := '0';
	signal enable_a, enable_b, enable_a_dec, enable_b_dec, reset_dados : STD_LOGIC := '0';  

begin
	div_clock:process(clk) --clock
		variable cont_div : integer := 0;
	begin
		if clk'event and clk = '1' then
			if cont_div < 49_999 then
				cont_div := cont_div + 1;
			else
				cont_div := 0;
			end if;
			
			if cont_div < 25_000 then
				clock_1k <= '1';
			else
				clock_1k <= '0';
			end if;
		end if;
	end process div_clock;
	
	shift_register_a:process(clock_1k) 
	begin
		if clock_1k'event and clock_1k = '1' then
			--incrementa a
			reg_a2 <= reg_a1;
			reg_a1 <= incrementa_a;
			
			--incrementa b
			reg_b2 <= reg_b1;
			reg_b1 <= incrementa_b;
			
			--decrementa a
			reg_a2_dec <= reg_a1_dec;
			reg_a1_dec <= decrementa_a;
			
			--decrementa b
			reg_b2_dec <= reg_b1_dec;
			reg_b1_dec <= decrementa_b;
			
			--reset
			reg_reset2 <= reg_reset1;
			reg_reset1 <= reset;
		end if;
	end process shift_register_a;
	
	--permite que os dados sejam alterados
	enable_a <= '1' when (reg_a1 = '1') and (reg_a2 ='0') else 
				   '0';
	enable_b <= '1' when (reg_b1 = '1') and (reg_b2 ='0') else 
				   '0';
	enable_a_dec <= '1' when (reg_a1_dec = '1') and (reg_a2_dec ='0') else 
						 '0';
	enable_b_dec <= '1' when (reg_b1_dec = '1') and (reg_b2_dec ='0') else 
						 '0';
	reset_dados <= '1' when (reg_reset1 = '1') and (reg_reset2 ='0') else 
						'0';					

	contador_gen:process(clock_1k) --contador 0-3
	begin
		if clock_1k'event and clock_1k = '1' then
			if cont < 3 then
				cont <= cont +1;
			else
				cont <= 0;
			end if;
		end if;
	end process contador_gen;
	
	--contador dado a
	contador_dado_a:process(clock_1k) 
	begin
		if clock_1k'event and clock_1k = '1' then
			if reset_dados = '1' then
				dado_a <= 0;
				dado_a_dez <= 0;
			elsif enable_a = '1' then
				if dado_a < 9 then
					dado_a <= dado_a +1;
				elsif dado_a_dez < 9 then
					dado_a <= 0;
					dado_a_dez <= dado_a_dez + 1;
				else 
					dado_a <= 0;
					dado_a_dez <= 0;
				end if;
			elsif enable_a_dec = '1' then
				if dado_a > 0 then
					dado_a <= dado_a - 1;
				elsif dado_a_dez > 0 then
					dado_a <= 9;
					dado_a_dez <= dado_a_dez - 1;
				else 
					dado_a <= 9;
					dado_a_dez <= 9;
				end if;
			end if;
		end if;
	end process contador_dado_a;
	
	--contador dado b
	contador_dado_b:process(clock_1k) 
	begin
		if clock_1k'event and clock_1k = '1' then
			if reset_dados = '1' then
				dado_b <= 0;
				dado_b_dez <= 0;
			elsif enable_b = '1' then
				if dado_b < 9 then
					dado_b <= dado_b +1;
				elsif dado_b_dez < 9 then
					dado_b <= 0;
					dado_b_dez <= dado_b_dez + 1;
				else 
					dado_b <= 0;
					dado_b_dez <= 0;
				end if;
			elsif enable_b_dec = '1' then
				if dado_b > 0 then
					dado_b <= dado_b - 1;
				elsif dado_b_dez > 0 then
					dado_b <= 9;
					dado_b_dez <= dado_b_dez - 1;
				else 
					dado_b <= 9;
					dado_b_dez <= 9;
				end if;
			end if;
		end if;
	end process contador_dado_b;
	
	decodificador_dado_a:process(dado_a_dez, dado_a, dado_b_dez, dado_b) --decodifica os valores dos dados
	begin
		--display dezena a
		case dado_a_dez is
			when 0 => dado_a_dez_dec <= num_0;
			when 1 => dado_a_dez_dec <= num_1;
			when 2 => dado_a_dez_dec <= num_2;
			when 3 => dado_a_dez_dec <= num_3;
			when 4 => dado_a_dez_dec <= num_4;
			when 5 => dado_a_dez_dec <= num_5;
			when 6 => dado_a_dez_dec <= num_6;
			when 7 => dado_a_dez_dec <= num_7;
			when 8 => dado_a_dez_dec <= num_8;
			when 9 => dado_a_dez_dec <= num_9;
			when others => dado_a_dez_dec <= desligado;
		end case;
		
		--display unidade a
		case dado_a is
			when 0 => dado_a_dec <= num_0;
			when 1 => dado_a_dec <= num_1;
			when 2 => dado_a_dec <= num_2;
			when 3 => dado_a_dec <= num_3;
			when 4 => dado_a_dec <= num_4;
			when 5 => dado_a_dec <= num_5;
			when 6 => dado_a_dec <= num_6;
			when 7 => dado_a_dec <= num_7;
			when 8 => dado_a_dec <= num_8;
			when 9 => dado_a_dec <= num_9;
			when others => dado_a_dec <= desligado;
		end case;
		
		--display dezena b
		case dado_b_dez is
			when 0 => dado_b_dez_dec <= num_0;
			when 1 => dado_b_dez_dec <= num_1;
			when 2 => dado_b_dez_dec <= num_2;
			when 3 => dado_b_dez_dec <= num_3;
			when 4 => dado_b_dez_dec <= num_4;
			when 5 => dado_b_dez_dec <= num_5;
			when 6 => dado_b_dez_dec <= num_6;
			when 7 => dado_b_dez_dec <= num_7;
			when 8 => dado_b_dez_dec <= num_8;
			when 9 => dado_b_dez_dec <= num_9;
			when others => dado_b_dez_dec <= desligado;
		end case;
		
		--display unidade b
		case dado_b is
			when 0 => dado_b_dec <= num_0;
			when 1 => dado_b_dec <= num_1;
			when 2 => dado_b_dec <= num_2;
			when 3 => dado_b_dec <= num_3;
			when 4 => dado_b_dec <= num_4;
			when 5 => dado_b_dec <= num_5;
			when 6 => dado_b_dec <= num_6;
			when 7 => dado_b_dec <= num_7;
			when 8 => dado_b_dec <= num_8;
			when 9 => dado_b_dec <= num_9;
			when others => dado_b_dec <= desligado;
		end case;
	end process decodificador_dado_a;
	
	--escreve no display
	mux_a:process(cont, dado_a_dez_dec, dado_a_dec, dado_b_dez_dec, dado_b_dec)
	begin
		if cont = 0 then
			display_en <= "0111";
			display <= dado_a_dez_dec;
		elsif	cont = 1 then
			display_en <= "1011";
			display <= dado_a_dec;
		elsif	cont = 2 then
			display_en <= "1101";
			display <= dado_b_dez_dec;
		elsif	cont = 3 then
			display_en <= "1110";
			display <= dado_b_dec;
		else
			display_en <= "1111";
			display <= desligado;
		end if;
	end process mux_a;
	
end Matheus_Portella;

