import math

def bonus(n):
    if n >= 10:
        y = 2*bonus(math.floor(n*3/4))+math.floor(n*0.875)-137
        return y
    elif n >= 1:
        y = 2*bonus(n-1)
        return y
    else:
        return 7

if __name__ == '__main__':
    # Modify your test pattern here
    n = 11

    with open('bonus_data.txt', 'w') as f_data:
        f_data.write('{:0>8x}\n'.format(n))

    with open('bonus_data_ans.txt', 'w') as f_ans:
        f_ans.write('{:0>8x}\n'.format(n))
        f_ans.write('{:0>8x}\n'.format(bonus(n)))