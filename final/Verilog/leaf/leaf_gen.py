def leaf(a,b,c,d):
    f = (a^b) + (b^c) - (c^d)
    return f
def toHex(x):
    if x >= 0:
        return x
    else:
        return 2**32+x

if __name__ == '__main__':
    # Modify your test pattern here
    a = 6
    b = 9
    c = 14
    d = 4

    with open('leaf_data.txt', 'w') as f_data:
        f_data.write('{:0>8x}\n'.format(toHex(a)))
        f_data.write('{:0>8x}\n'.format(toHex(b)))
        f_data.write('{:0>8x}\n'.format(toHex(c)))
        f_data.write('{:0>8x}\n'.format(toHex(d)))

    with open('leaf_data_ans.txt', 'w') as f_ans:
        f_ans.write('{:0>8x}\n'.format(toHex(a)))
        f_ans.write('{:0>8x}\n'.format(toHex(b)))
        f_ans.write('{:0>8x}\n'.format(toHex(c)))
        f_ans.write('{:0>8x}\n'.format(toHex(d)))
        f_ans.write('{:0>8x}\n'.format(toHex(leaf(a,b,c,d))))