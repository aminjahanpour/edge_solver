import matplotlib.pyplot as plt
from bitstring import BitArray as B
from scipy import stats

import pandas as pd
import numpy as np


dv_per_solution = 16
bits_per_dv = 16

sol_bitstream_len = dv_per_solution * bits_per_dv
bytes_per_solution = int(sol_bitstream_len / 8)

f_bitstream_len = 32
bytes_per_f = int(f_bitstream_len / 8)

archive_size = 20

base_memory_address = 0

bma_new_sol = base_memory_address;

bma_new_f = bma_new_sol + bytes_per_solution;

bma_sol_archive = bma_new_f + bytes_per_f;

bma_f_archive = bma_sol_archive + archive_size * bytes_per_solution;



def bin_to_float(input):
    l = len(input)

    ret= 0.0

    for i in range(l):
        el = input[i]
        if el == '1':
            ret += 1. / (2 ** (i+1))

    return ret

def bytes_to_f(input):
    data = ''.join(input)
    l = int(len(data) / 2)
    whole = data[:l]
    dec = data[l:]
    whole = B(f"bin=({whole})").int
    dec = bin_to_float(dec)

    if whole >= 0:
        ret = whole + dec
    else:
        ret = - (-whole + dec)

    return ret


def bytes_to_solution(input):
    ret = []
    for i in range(int(bytes_per_solution / 2)):
        p1 = input[2 * i]
        p2 = input[2 * i + 1]

        ret.append(bin_to_float(p1+p2))

    return ret

def display_mem():
    # file_name = "C:\\Users\\jahan\\Desktop\\verilog\\bite\\dumps\\after_initialization.txt"
    file_name = "./dumps/U10_output_file_main_mem.txt"

    with open(file_name, "r") as my_file:
        data = my_file.read().split('\n')[:-1]



    main_memory_depth = base_memory_address + bytes_per_solution + bytes_per_f + archive_size * (
                bytes_per_solution + bytes_per_f);



    new_sol = bytes_to_solution(data[bma_new_sol: bma_new_sol + bytes_per_solution])

    new_f = bytes_to_f(data[bma_new_f: bma_new_f + bytes_per_f])




    df= pd.DataFrame(columns=[f'{i}' for i in range(16)]+['f'])

    for i in range(archive_size):
        sol = bytes_to_solution(data[bma_sol_archive + i * bytes_per_solution: bma_sol_archive + (i + 1) * bytes_per_solution])
        f   = bytes_to_f(       data[bma_f_archive   + i * bytes_per_f: bma_f_archive   + (i + 1) * bytes_per_f])

        # df.loc[arg_sor[i]] = sol + [f]
        df.loc[i] = sol + [f]

        print(sol,f)

    sf=4


def check_uniform():

    with open("./dumps/N0_output_file_random_values.txt", "r") as my_file:
        data = my_file.read().split('\n')[:-1]

    data = [eval(el) for el in data]

    data_u = np.random.uniform(0, 1.0,len(data))

    bins = 100

    fig, axs = plt.subplots(3, 2)


    for idx, bins in enumerate([10,100,1000]):

        axs[idx,0].hist(data,  bins=bins, label='verilog',color='b')
        axs[idx,1].hist(data_u,bins=bins, label='uniform',color='g')

    ret = stats.kstest(data, stats.uniform(loc=0.0, scale=1.0).cdf)
    # assert ret[1] < 0.01
    plt.title(f'p_value: {ret[1]}, statistics:{ret[0]}')
    plt.show()
    dfg=5



def show_optimization_progress():
    with open("./dumps/V1_output_file_evaluations.txt", 'r') as my_file:
        data = my_file.read().split('\n')[:-1]

    num_dec = int(data[0])

    data = data[1:]

    x_0 = []
    x_1 = []
    x_2 = []
    y   = []
    bests_f = []

    best_f = 1000000
    best_x = []

    for el in data:
    #     a,b,c,d = el.split(',')
    #   a=eval(a)
    #     b=eval(b)
    #     c=eval(c)

        d=eval(el.split(',')[-1])


        if d< best_f:
            best_f = d
            best_x = [eval(x) for x in el.split(',')[:num_dec]]

        # x_0.append(a)
        # x_1.append(b)
        # x_2.append(c)
        y.append(d)
        bests_f.append(best_f)

    # plt.scatter(x=x_0, y=y)
    plt.plot(y, c='b')
    plt.plot(bests_f, c='r')
    plt.title(f'SOC (num_dec:{num_dec}) best_f: {best_f} \n best_x: {best_x}')
    plt.show()

    asd=54




if __name__ == '__main__':
    # display_mem()
    # check_uniform()
    show_optimization_progress()