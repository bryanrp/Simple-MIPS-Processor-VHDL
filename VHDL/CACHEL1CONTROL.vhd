library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CACHEL1CONTROL is
port(I1,I2: in std_ulogic_vector(31 downto 0);
     O1,O2: out std_ulogic_vector(31 downto 0); --read down below (it's quite long)
     O3, O4: out std_ulogic; --hit AND ready (ready is '1' if all rainbows and sunshines)
     C1, C2: in std_ulogic); --controls whether this is write or read operation
end CACHEL1CONTROL;

architecture CACHEL1CONTROL1 of CACHEL1CONTROL is
component CACHEL1 is
  port(I1,I2: in std_ulogic_vector(31 downto 0);
        O1,O2: out std_ulogic_vector(31 downto 0);
        O3, O4: out std_ulogic;
        C1, C2, C3: in std_ulogic);
  end component;

signal D1, D2: std_ulogic_vector(31 downto 0) := (others => '0');
signal D3, D4: std_ulogic := '0';
signal R21, R31: std_ulogic_vector(31 downto 0) := (others => '0');
signal D51, HIT1, READY1: std_ulogic := '0';
signal R22, R32: std_ulogic_vector(31 downto 0) := (others => '0');
signal D52, HIT2, READY2: std_ulogic := '0';
signal R2, R3: std_ulogic_vector(31 downto 0) := (others => '0');
signal HIT, READY: std_ulogic := '0';
begin
	D1 <= transport I1; --address (TAG&POINTER) (address size is 32 bits)
	D2 <= transport I2; --Write Data (data size is 32 bits)
	D3 <= transport C1; --MemWrite (either 0 OR 1)
	D4 <= transport C2; --MemRead (either 0 OR 1)
  D51 <= transport '1' when I1(0) = '0' else '0';
	D52 <= transport '1' when I1(0) = '1' else '0'; --MemRead (either 0 OR 1)

  CACHEL11: CACHEL1 port map(D1, D2, R21, R31, HIT1, READY1, D3, D4, D51);
  CACHEL12: CACHEL1 port map(D1, D2, R22, R32, HIT2, READY2, D3, D4, D52);
  
  control:process(R21, R31, HIT1, READY1, R22, R32, HIT2, READY2)
  begin
    if (I1(0) = '0') then
      R2 <= R21;
      R3 <= R31;
      HIT <= HIT1;
      READY <= READY1;
    else
      R2 <= R22;
      R3 <= R32;
      HIT <= HIT2;
      READY <= READY2;
    end if;
  end process;

	O1 <= R2; --data read OR address to read in memory OR address to write the write back
	O2 <= R3; --data to be written into memory (write back)
	O3 <= HIT; --hit
	O4 <= READY; --ready

end CACHEL1CONTROL1;
