----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:11:18 09/28/2015 
-- Design Name: 
-- Module Name:    fsmc_3to8_decoder - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity demuxer is
  generic (
    AW : positive;  -- address width (select bits count)
    DW : positive;  -- data width 
    cnt : positive  -- actual outputs count
  );
  port(
    A  : in  STD_LOGIC_VECTOR(AW-1 downto 0);
    di : in  STD_LOGIC_VECTOR(DW-1 downto 0);
    do : out STD_LOGIC_VECTOR(cnt*DW-1 downto 0)
  );
end demuxer;


architecture Behavioral of demuxer is
  signal addr : integer range 0 to 2**AW;
begin

  assert cnt <= 2**AW
    report "Not enough address bits"
    severity Failure;
    
  addr <= conv_integer(A);
  process(addr, di) begin
    do <= (others => '0');
    
    if (addr > cnt-1) then -- overflow handling
      --do <= (others => '0');
    else
      do((addr+1)*DW-1 downto addr*DW) <= di;
    end if;
    
  end process;
end Behavioral;

