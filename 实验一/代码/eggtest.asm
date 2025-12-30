# MIPS 汇编验证程序 
.text
 #addi $v0, $0, 1024    # 设置楼层上限 n
 #addi $v1, $0, 65    # 设置鸡蛋耐摔值 m
 
addi $t2, $0, 1     # 常数1
add $t0, $0, $0     # 左边界 l = 0
add $t1, $0, $v0    # 右边界 r = n
add $s0, $0, $0     # m = 0 ($s0 = 0)
add $s1, $0, $0     # n = 0 ($s1 = 0)

LOOP:
    slt $t3, $t0, $t1       # 检查 l < r
    beq $t3, $0, END        # 如果 l >= r, 跳转到 END
    
    addi $a0, $a0, 1        # 增加总摔鸡蛋次数
    
    add $t4, $t0, $t1       # $t4 = l + r
    addi $t4, $t4, 1        # $t4 = l + r + 1
    sra $t4, $t4, 1         # $t4 = (l + r + 1) >> 1 (mid)
    
    slt $t3, $v1, $t4       # 检查 resistance < mid
    beq $t3, $t2, BROKE     # 如果 resistance < mid, 跳转到 BROKE

RESISIT:                    # 没碎
    add $a2, $0, $0         # 设置最后一个鸡蛋是否碎裂为 0
    add $t0, $0, $t4        # 更新左边界 l = mid
    
    add $s0, $s0, $t4
    
    j LOOP

BROKE:                      # 摔碎
    addi $a1, $a1, 1        # 增加碎裂的鸡蛋数 
    add $a2, $0, $t2        # 设置最后一个鸡蛋是否碎裂为 1
    sub $t1, $t4, $t2       # 更新右边界 r = mid - 1
    
    add $s1, $s1, $t4 
    
    j LOOP

END:
    sll $t5, $s0, 1         # $t5 = m * 2
    add $t5, $t5, $s1       # $t5 = (m*2) + n
    sll $t6, $a1, 2         # $t6 = h * 4
    add $s2, $t5, $t6       # f1 ($s2) = (m*2 + n) + h*4
    sll $t5, $s0, 2         # $t5 = m * 4
    add $t5, $t5, $s1       # $t5 = (m*4) + n
    sll $t6, $a1, 1         # $t6 = h * 2
    add $s3, $t5, $t6       # f2 ($s3) = (m*4 + n) + h*2

DONE:
    j DONE
    
.text ends
