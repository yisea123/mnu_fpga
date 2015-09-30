----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:53:56 09/29/2015 
-- Design Name: 
-- Module Name:    mul_hive - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram_pool is
  Generic (
    BW : positive;
    DW : positive;
    count : positive
  );
  Port (
    fsmc_bram_a   : in STD_LOGIC_VECTOR  (count*BW-1 downto 0);
    fsmc_bram_di  : in STD_LOGIC_VECTOR  (count*DW-1 downto 0);
    fsmc_bram_do  : out STD_LOGIC_VECTOR (count*DW-1 downto 0);
    fsmc_bram_en  : in STD_LOGIC_vector  (count-1    downto 0);
    fsmc_bram_we  : in std_logic_vector  (count*2-1  downto 0);
    fsmc_bram_clk : in std_logic_vector  (count-1    downto 0)
  );
end bram_pool;



architecture Behavioral of bram_pool is

begin

  bram_pool_array : for i in count downto 1 generate 
  begin
    bram : entity work.bram 
    PORT MAP (
    addra => fsmc_bram_a   (i*BW-1 downto (i-1)*BW),
    dina  => fsmc_bram_di  (i*DW-1 downto (i-1)*DW),
    douta => fsmc_bram_do  (i*DW-1 downto (i-1)*DW),
    ena   => fsmc_bram_en  (i-1),
    wea   => fsmc_bram_we  (i*2-1 downto (i-1)*2),
    clka  => fsmc_bram_clk (i-1),

    web   => (others => '0'),
    addrb => (others => '0'),
    dinb  => (others => '0'),
    doutb => open,
    enb   => '0',
    clkb  => fsmc_bram_clk(0)
  );
  end generate;

end Behavioral;