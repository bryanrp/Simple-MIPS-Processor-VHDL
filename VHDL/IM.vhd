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

	M1(0) <= x"00000000";
	M1(1) <= x"00000000";
	M1(2) <= x"00000000";
	M1(3) <= x"00000000";
	M1(4) <= x"06000002";
	M1(5) <= x"04010002";
	M1(6) <= x"04220002";
	M1(7) <= x"04430002";
	M1(8) <= x"0FE30000";
	M1(9) <= x"04640002";
	M1(10) <= x"04850002";
	M1(11) <= x"04A60002";
	M1(12) <= x"04C70002";
	M1(13) <= x"0AA80000";
	M1(14) <= x"81074800";
	M1(15) <= x"0AAA0001";
	M1(16) <= x"0FE30021";
	M1(17) <= x"0FE40041";
	M1(18) <= x"0AEB0001";

	R1 <= M1(to_integer(unsigned(D1))) when to_integer(unsigned(D1)) < (N-1) else
	      std_ulogic_vector(to_signed(-1, 32)) when to_integer(unsigned(D1)) > (N-1);
	
	O1 <= R1;
end IM1;
