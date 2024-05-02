--**********************
--*                    *
--*                    *
--*	   ---         *
--*	--|(0)|---     *
--*	  |---|        *
--*	--|(1)|---     *
--*       |---|        *
--*	--|(2)|-->     *
--*	  |---|        *
--*         .          *
--          .          *
--*	               *
--**********************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library STD;
use STD.textio.all;

entity IM is
generic(N: integer);
port(I1: in std_ulogic_vector(31 downto 0);
     O1: out std_ulogic_vector(31 downto 0));
end IM;

architecture IM1 of IM is
type MEMORY is array (0 to (N-1)) of std_ulogic_vector(31 downto 0); --N*4 byte memory
signal M1: MEMORY := (others => (others => '0'));
signal D1: std_ulogic_vector(29 downto 0) := (others => '0');
signal R1: std_ulogic_vector(31 downto 0) := (others => '0');
begin
	D1 <= I1(31 downto 2); --PC/4	

	M1(0) <= "00000000000000000000000000000000";
	M1(1) <= "00000000000000000000000000000000";
	M1(2) <= "00000000000000000000000000000000";
	M1(3) <= "00000000000000000000000000000000";
	
	M1(4) <= "00001011111000000000000000000000";
	M1(5) <= "00000000000000000000000000000000";
	M1(6) <= "00001011111000010000000000100000";
	M1(7) <= "00000000000000000000000000000000";
	M1(8) <= "00000000000000000000000000000000";
	M1(9) <= "10000000000000011010000000000000";
	
	M1(10) <= "00001011111000100000000000000000";
	M1(11) <= "00001011111000110000000000100000";
	M1(12) <= "00000000000000000000000000000000";
	M1(13) <= "00000000000000000000000000000000";
	M1(14) <= "10000000010000111010100000000000";

	R1 <= M1(to_integer(unsigned(D1))) when to_integer(unsigned(D1)) < (N-1) else
	      std_ulogic_vector(to_signed(-1, 32)) when to_integer(unsigned(D1)) > (N-1);
	
	O1 <= R1;
end IM1;
