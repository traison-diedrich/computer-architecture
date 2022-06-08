# ##################################################### #
# InterestCalculator.asm                                #
#                                                       #
# Program for creating a compund interst calculator     #
#   using recursive subroutine calls                    #
#                                                       #
# Traison Diedrich, ID: 800733263                       #
# ##################################################### #

.data

# constant strings to be output to the terminal
promptPrincipal:    .asciiz "Enter the principal ($100.00 < principal < $5,000,000.00): "
promptInterest:     .asciiz "Enter interest rate (0.0 < interest < 1.0, 0.01 for 1%): "
promptBalance:      .asciiz "Enter the target balance ($101.00 < balance < $5,000,001.00): "
promptYears:        .asciiz "Enter the number of the last years you would like to see the balance (-1: all): "
errorInput:         .asciiz "You made an invalid input. Please try again."
printBalance:       .asciiz "The balance at the end of a year:"
printY:             .asciiz "Year "
printColon:         .asciiz ": $"
printItTakes:       .asciiz "It takes "
printYears:         .asciiz " year(s)."
linefeed:           .asciiz "\n"

# constant floats
A:          .float 100.00
B:          .float 5000000.00
D:          .float 5000001.00
E:          .float 0.0
F:          .float 1.0

    .text
    .globl main

# $f20 = principal min
# $f21 = principal max
# $f22 = user principal

main:
    # print prompt for principal
    li      $v0, 4 		                        
    la      $a0, promptPrincipal                       
    syscall                                         

    # loading min principal
    la      $a0, A
    lwc1    $f20, ($a0)

    # loading max principal
    la      $a0, B
    lwc1    $f21, ($a0)

    # reading user principal and storing in $f22
    li      $v0, 6
    syscall 
    mov.s   $f22, $f0

    # if principal <= min
    c.le.s  $f22, $f20
    bc1t    errorPrincipal

    # if max <= principal
    c.le.s  $f21, $f22
    bc1t    errorPrincipal

    # else
    j       interest

# print error message for out of range input
errorPrincipal:
    li      $v0, 4 		                        
    la      $a0, errorInput                       
    syscall 

    li      $v0, 4 		                        
    la      $a0, linefeed                      
    syscall

    # jump to main
    j       main

# $f23 = min interest
# $f24 = max interst
# $f25 = user interest

interest:
    # print prompt for interest
    li      $v0, 4 		                        
    la      $a0, promptInterest                       
    syscall                                         

    # loading min interest
    la      $a0, E
    lwc1    $f23, ($a0)

    # loading max interest
    la      $a0, F
    lwc1    $f24, ($a0)

    # reading user interest and storing in $f25
    li      $v0, 6
    syscall 
    mov.s   $f25, $f0

    # if user interest <= min
    c.le.s  $f25, $f23
    bc1t    errorInterest

    # if max <= user interest
    c.le.s  $f24, $f25 
    bc1t    errorInterest

    # else
    j       balance

# print error message for out of range input
errorInterest:
    li      $v0, 4 		                        
    la      $a0, errorInput                       
    syscall 

    li      $v0, 4 		                        
    la      $a0, linefeed                      
    syscall

    j       interest 

# $f26 = min balance
# $f27 = max balance
# $f28 = user balance

balance:
    # print prompt for balance
    li      $v0, 4 		                        
    la      $a0, promptBalance                     
    syscall                                         

    # loading min balance
    la      $a0, C
    lwc1    $f26, ($a0)

    # loading max balance
    la      $a0, D
    lwc1    $f27, ($a0)

    # reading user balance and storing in $f28
    li      $v0, 6
    syscall 
    mov.s   $f28, $f0

    # if user balance < min
    c.le.s  $f28, $f26
    bc1t    errorBalance

    # if max < user balance
    c.le.s  $f27, $f28
    bc1t    errorBalance

    # else
    j       years

# print error message for out of range input
errorBalance:
    li      $v0, 4 		                        
    la      $a0, errorInput                       
    syscall 

    li      $v0, 4 		                        
    la      $a0, linefeed                      
    syscall

    j       balance 

# $s4 = user number of years

years:
    # print prompt for years
    li      $v0, 4 		                        
    la      $a0, promptYears                     
    syscall                                         

    # get user number of years
    li      $v0, 5                                  
    syscall                                         
    move    $s4, $v0 

    # $s0 will be loop counter
    li      $s0, 0

    # create initial stack space
    subu    $sp, $sp, 12

    # save return address, loop counter, and current principal
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    swc1    $f22, 8($sp)

    # jump and link to calculate
    jal     calculate

    # restore return address, loop counter, and principal
    lwc1    $f22, 8($sp)
    lw		$s0, 4($sp)
    lw		$ra, 0($sp)

    # place stack pointer in correct position
    addu    $sp, $sp, 12

    jr      $31

# $f22 = user principal
# $f25 = user interest
# $f28 = user balance
# $s4 = user num of years

calculate:
    # create initial stack space
    subu    $sp, $sp, 12

    # save return address, loop counter, and current principal
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    swc1    $f22, 8($sp)

    # if current principal is >= desired balance, jump to print statements
    c.le.s  $f22, $f28
    bc1f    printFirst

    # find next principal amount (principal = principal + (principal * rate))
    mul.s   $f29, $f22, $f25
    add.s   $f22, $f22, $f29

    # add one to loop counter
    add     $s0, $s0, 1

    # recurse to calculate
    jal     calculate

    # restore return address, loop counter, and principal
    lwc1    $f22, 8($sp)
    lw		$s0, 4($sp)
    lw		$ra, 0($sp)

    # place stack pointer in correct position
    addu    $sp, $sp, 12

    # jump to return address
    jr      $ra

printFirst:
    # print balance statement ("The balance at...")
    li      $v0, 4
    la      $a0, printBalance
    syscall

    #print newline
    li      $v0, 4
    la      $a0, linefeed
    syscall

    # jump to next part of printing results
    j       print

print:
    # subtract one from desired number of year balances
    sub     $s4, $s4, 1

    # print beginning ("Year")
    li      $v0, 4
    la      $a0, printY
    syscall

    # print the current year number from the stack
    li      $v0, 1
    lw      $a0, 4($sp)
    syscall

    # print the colon (":")
    li      $v0, 4
    la      $a0, printColon
    syscall

    # print the current principal amount from the stack
    li      $v0, 2
    lwc1    $f12, 8($sp)
    syscall

    # print newline
    li      $v0, 4
    la      $a0, linefeed
    syscall

    # load the current year number into $t0
    lw      $t0, 4($sp)

    # move the stack pointer to the next stack frame
    addu    $sp, $sp, 12

    # if $t0 (current year number) is 1, exit
    beq     $t0, 1, exit

    # if desired years remaining is negative, jump to print
    blt     $s4, 0, print

    # if desired years remaining is greater than zero, jump to print
    bgt     $s4, $zero, print

    # else
    j       exit

exit:
    # print intial part of last statement
    li      $v0, 4
    la      $a0, printItTakes
    syscall

    # print how many years it took to reach desired balance
    li      $v0, 1
    move    $a0, $s0
    syscall

    # print the end of the statement
    li      $v0, 4
    la      $a0, printYears
    syscall

    # exit the program
    jr      $31    