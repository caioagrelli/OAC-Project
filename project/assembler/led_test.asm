addi x1,x0,1
slli x1,x1,10
addi x1,x1,8
addi x2,x0,-1
sw x2,0(x1)
beq x0,x0,0
