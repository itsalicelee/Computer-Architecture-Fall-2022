def perm(n,r):
    if r < 1:
        return 1
    else:
        return n*perm(n-1,r-1)

if __name__ == '__main__':
    # Modify your test pattern here
    n = 10
    r = 3

    with open('perm_data.txt', 'w') as f_data:
        f_data.write('{:0>8x}\n'.format(n))
        f_data.write('{:0>8x}\n'.format(r))

    with open('perm_data_ans.txt', 'w') as f_ans:
        f_ans.write('{:0>8x}\n'.format(n))
        f_ans.write('{:0>8x}\n'.format(r))
        f_ans.write('{:0>8x}\n'.format(perm(n,r)))