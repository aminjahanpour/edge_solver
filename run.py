import shutil
import os


try:
    os.remove("./.sconsign.dblite")
    os.remove("./git_tb.out")
    os.remove("./hardware.out")
except:
    pass

os.system('clear')
os.system('apio sim')

"""
assign clk = CLK;
assign resetn = RESET;


wire clk;    // internal clock
wire resetn; // internal reset signal, goes low on reset
   
"""


