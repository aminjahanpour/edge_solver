MEMORY
{
   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x7AD0  /* 0x1800=6144 bytes    0xC48=3144 bytes*/
}
SECTIONS
{
    everything :
    {
	. = ALIGN(4);
	/home/amin/bucking_html/risc-v/hex_c/start.o (.text)
        *(.*)
    } >BRAM
}
