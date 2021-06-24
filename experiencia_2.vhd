----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:43:42 04/03/2021 
-- Design Name: 
-- Module Name:    divisor_clock_multiplexado - Matheus_Portella 
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

entity divisor_clock_multiplexado is
Port 
( 
	clk_in : in  STD_LOGIC;
	selecao : in  STD_LOGIC_VECTOR (1 downto 0);
	clk_out : out  STD_LOGIC
);
end divisor_clock_multiplexado;

architecture Matheus_Portella of divisor_clock_multiplexado is

	signal cont : integer := 0;

begin
	gen_cont:process(clk_in,selecao)
	begin
		if clk_in'event and clk_in = '1' then
			if selecao = 0 then
				if cont < 249 then 		-- numero de ciclos
					cont <= cont + 1;
				else
					cont <= 0;
				end if;	
			elsif selecao = 1 then
				if cont < 499 then 		-- numero de ciclos
					cont <= cont + 1;
				else
					cont <= 0;
				end if;
			elsif selecao = 2 then
				if cont < 9 then 		-- numero de ciclos
					cont <= cont + 1;
				else
					cont <= 0;
				end if;
			elsif selecao = 3 then
				if cont < 49 then 		-- numero de ciclos
					cont <= cont + 1;
				else
					cont <= 0;
				end if;
			end if;	
		end if;
	end process gen_cont;
	
	dec_cont:process(cont,selecao)
	begin
		if selecao = 0 then
			if cont < 125 then 			
				clk_out <= '1';
			else
				clk_out <= '0';
			end if;
		elsif selecao = 1 then
			if cont < 450 then 			
				clk_out <= '1';
			else
				clk_out <= '0';
			end if;
		elsif selecao = 2 then
			if cont < 2 then 			
				clk_out <= '1';
			else
				clk_out <= '0';
			end if;
		elsif selecao = 3 then
			if cont < 15 then 			
				clk_out <= '1';
			else
				clk_out <= '0';
			end if;
		end if;	
	end process dec_cont;
	
end Matheus_Portella;
