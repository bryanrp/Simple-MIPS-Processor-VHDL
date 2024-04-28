library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CACHEL1 is
port(I1,I2: in std_ulogic_vector(31 downto 0);
     O1,O2: out std_ulogic_vector(31 downto 0); --read down below (it's quite long)
     O3, O4: out std_ulogic; --hit AND ready (ready is '1' if all rainbows and sunshines)
     C1, C2: in std_ulogic);
end CACHEL1;

architecture CACHEL11 of CACHEL1 is
type MEMORY is array (0 to 31) of std_ulogic_vector(59 downto 0);
signal M1: MEMORY := (others => (others => '0'));
signal D1, D2, R2, R3: std_ulogic_vector(31 downto 0) := (others => '0');
signal D3, D4, HIT, READY: std_ulogic := '0';
begin
	D1 <= transport I1 after 13 ns; --address (TAG&POINTER)
	D2 <= transport I2 after 13 ns; --Write Data
	D3 <= transport C1 after 13 ns; --MemWrite
	D4 <= transport C2 after 13 ns; --MemRead

	-- D1(4 downto 0) 5 pointer bits (32 possible addresses in the cache) !! offset not present
	-- D1(31 downto 5) 27 bits of tag (instruction)
	-- R1(58 downto 32) 27 bits of tag
	-- R1(59) valid

	Control:process(D1, D2, D3, D4)
	variable MEMDATA: std_ulogic_vector(59 downto 0) := (others => '0');
	variable VALIDFLAG, TAGFLAG, HITFLAG, READYFLAG: std_ulogic := '0';
	begin
		if(to_integer(unsigned(D1(4 downto 0))) < 32) then
			MEMDATA := M1(to_integer(unsigned(D1(4 downto 0))));
			VALIDFLAG := MEMDATA(59);
		end if;

		if(D1(31 downto 5) = MEMDATA(58 downto 32)) then --check if address tag same
			TAGFLAG := '1';
		else
			TAGFLAG := '0';
		end if;

		if(D3 = '0' and D4 = '0' and MEMDATA = "000000000000000000000000000000000000000000000000000000000000") then --idk what happs here
			HITFLAG := '1';
		else
			HITFLAG := VALIDFLAG and TAGFLAG;
		end if;

		READYFLAG := '0'; --all cases below will check READYFLAG to 1

		if(D3 = '0' and D4 = '1') then --reading
			if(HITFLAG = '1') then --get data from cache
				R2 <= MEMDATA(31 downto 0); --R2 is the data
				READYFLAG := '1';
			else --output the address of the data to be taken into memory
				R2 <= D1;
				READYFLAG := '1';
			end if;
		else if(D3 = '1' and D4 = '0') then --writing
			if(VALIDFLAG = '0') then --I write the data in the cache (I have hit = '0' as the previous data is NOT valid)
				M1(to_integer(unsigned(D1(4 downto 0)))) <= '1'&D1(31 downto 5)&D2; --concat '1', D1 (address), and the data D2. Total 60 bits
				HITFLAG := '1';
				READYFLAG := '1';
			else if(VALIDFLAG = '1') then
				if(HITFLAG = '1') then --I update the data
					M1(to_integer(unsigned(D1(4 downto 0)))) <= '1'&D1(31 downto 5)&D2; --valid data, same tag, new data
					READYFLAG := '1';
				else --mismatched tags -> write back
					R3 <= MEMDATA(31 downto 0); --data to be written into write-back memory
					R2 <= MEMDATA(58 downto 32)&D1(4 downto 0); --address to write the write back
					M1(to_integer(unsigned(D1(4 downto 0)))) <= '1'&D1(31 downto 5)&D2; --valid data, different tag, new data
					READYFLAG := '1';
				end if;
			end if;
			end if;			
		end if;
		end if;
		HIT <= HITFLAG;
		READY <= READYFLAG;
	end process;

	O1 <= R2; --data read OR address to read in memory OR address to write the write back
	O2 <= R3; --data to be written into memory (write back)
	O3 <= HIT; --hit
	O4 <= READY; --ready

end CACHEL11;
