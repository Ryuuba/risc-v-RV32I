# This program results from the compilation of the file gcd.nested.function.c

# gcd function
# kind: leaf function
# convention: a <-> a0, b <-> a1, temp <-> tp
# access-memory policy: load and store when needed
# return policy: a0 keeps the returned value
    .text
    .globl gcd
gcd:
L3: beqz     a1, L4             # branches if a1 != 0 to L2   
    mv       tp, a1             # temp = b
    rem      a1, a0, a1         # b = a % b
    mv       a0, tp             # a = temp
    j        L3                 # jumps inconditionally to L1
L4: mv       a0, a0             # holds the returned value a in a0
    jr       ra                 # return control to caller

# n_gcd function
# kind: nested function
# convention: a0 <-> *a, a1 <-> size, tp stores temporal calculations
# frame size: 48 bytes
#    - 4 words to back ra and fp up
#    - 4 words to back local variables g and i up
#    - 4 words to back a0 and a1 up
# access-memory policy: load when needed store after update
# return policy: a0 keeps the returned value g
    .globl n_gcd
n_gcd:
    addi     sp, sp, -48        # updates sp
    sw       ra, 48(sp)         # backs ra up
    sw       fp, 44(sp)         # backs fp up
    addi     fp, sp, 48         # updates fp
    lw       tp, 0(a0)          # tp = a[0]
    sw       tp, -16(fp)        # g = a[0]
    li       tp, 1              # tp = 1
    sw       tp, -20(fp)        # i = 1
L1: lw       tp, -20(fp)        # tp = i
    bge      tp, a1, L2         # jumps if i >= size to L2
    # call function, from here there is not guarantee that a1 and a0 hold their 
    # original values.
    sw       a1, -32(fp)        # backs a1 up
    sw       a0, -36(fp)        # backs a0 up
    lw       tp, -20(fp)        # tp = i
    slli     tp, tp, 2          # tp = 4*tp
    lw       a0, -36(fp)        # restores a0
    add      tp, a0, tp         # tp = addr(a) + 4*i
    lw       a1, 0(tp)          # a1 = a[i]
    lw       a0, -16(fp)        # a0 = g
    jal      gcd                # calls gcd
    sw       a0, -16(fp)        # g = gcd(g, a[i])
    lw       a1, -32(fp)        # restores a1
    lw       a0, -36(fp)        # restores a0
    lw       tp, -20(fp)        # tp = i
    addi     tp, tp, 1          # tp = tp + 1
    sw       tp, -20(fp)        # i = i + 1
    j        L1                 # jumps to L1
L2: lw       a0, -16(fp)        # a0 holds the returned value
    lw       ra, 48(sp)         # restores ra
    lw       fp, 44(sp)         # restores fp
    addi     sp, sp, 48         # frees n_gcd frame
    jr       ra

# main function
# kind: nested function
# convention: tp holds auxiliary values
# frame size: 48 bytes
#    - 4 words to back ra and fp up
#    - 8 words to store local variables: a[], g, are_prime_numbers
# access-memory policy: load when needed, store after update
    .globl main
main:
    addi     sp, sp, -48        # updates the stack's top to keep main's frame
    sw       ra, 48(sp)         # backs ra up
    sw       fp, 44(sp)         # backs fp up
    addi     fp, sp, 48         # updates fp
    li       tp, 8191
    sw       tp, -36(fp)        # a[0] = 8191
    li       tp, 127
    sw       tp, -32(fp)        # a[1] = 127
    li       tp, 31
    sw       tp, -28(fp)        # a[2] = 31
    li       tp, 1601
    sw       tp, -24(fp)        # a[3] = 1601
    li       tp, 2011
    sw       tp, -20(fp)        # a[4] = 2011
    li       tp, 1087
    sw       tp, -16(fp)        # a[5] = 1087
    # call function
    li       a1, 6              # a1 = 6
    addi     a0, fp, -36        # a0 = addr(a)
    jal      n_gcd
    sw       a0, -40(fp)        # g = n_gcd(a, 6)
    lw       tp, -40(fp)        # tp = g
    addi     tp, tp, -1         # tp = tp - 1
    seqz     tp, tp             # tp = 1 if tp == 0, otherwise tp = 0
    sb       tp, -44(fp)        # are_prime_numbers = (g == 1) ? 1 : 0
    li       a0, 0              # holds the return value 0 in a0
    lw       ra, 48(sp)         # restores ra
    lw       fp, 44(sp)         # restores fp
    addi     sp, sp, 48         # frees main's frame
    jr       ra                 # returns control to OS