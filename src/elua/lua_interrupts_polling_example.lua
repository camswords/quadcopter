function int_select( int_table )
  while true do
    for i = 1, #int_table do
      local t = int_table[ i ]
      if cpu.get_int_flag[ t[ 1 ], t[ 2 ] ) then
        return t[ 1 ], t[ 2 ]
      end
    end
 end
end

cpu.cli( cpu.INT_GPIO_NEGEDGE, pio.P0_0 )
cpu.cli( cpu.INT_TMR_MATCH, tmr.VIRT0 )
local ints = { { cpu.INT_GPIO_NEGEDGE, pio.P0_0 }, { cpu.INT_TMR_MATCH, tmr.VIRT0 } }
-- int_select will wait for either INT_GPIO_NEGEDGE or INT_TMR_MATCH to become active
print( int_select( ints ) )