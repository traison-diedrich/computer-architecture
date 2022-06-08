# ##################################################### #
# loan.asm                                              #
#                                                       #
# Program for calculating monthly interest payments     #
#                                                       #
# Traison Diedrich, ID: 800733263                       #
# ##################################################### #

.data

# Constant strings to be output to the terminal
promptPrincipal:.asciiz "Enter the principal in $ (100.00 - 1,000,000.00): "
promptInterest: .asciiz "Enter the annual interest rate (0.005 - 0.399): "
promptPayment:  .asciiz "Enter the monthly payment amount in $ (1.00 - 2,000,000.00): "
errorInput:     .asciiz "You made an invalid input. Please try again."
promptMonth:    .asciiz "month "
promptCurrent:  .asciiz ": current principal = "
promptIt:       .asciiz "It will take "
promptMonths:   .asciiz " months to complete the loan."
linefeed:       .asciiz "\n"
# constant floats
A:              .float 100.00
B:              .float 1000000.00
C:              .float 0.005
D:              .float 0.399
E:              .float 1.00
F:              .float 2000000.00
G:              .float 0.08219
zero:           .float 0.00000000000000001

    .text
    .globl main

# $f20 = 100.00
# $f21 = 1,000,000.00
# $f22 = User Principal

main:
    #loading monthly fraction
    la      $a0, G
    lwc1    $f13, ($a0)
    
    #loading effective zero (number is 0.000....001 to prevent another payment being made if principal == 0)
    la      $a0, zero
    lwc1    $f15, ($a0)

    # print prompt for principal
    li      $v0, 4 		                        
    la      $a0, promptPrincipal                       
    syscall                                         

    # loading min pincipal
    la      $a0, A
    lwc1    $f20, ($a0)

    # loading max principal
    la      $a0, B
    lwc1    $f21, ($a0)

    # reading user principal and storing in $f22
    li      $v0, 6
    syscall 
    mov.s   $f22, $f0

    # if principal < min
    c.lt.s  $f22, $f20
    bc1t    errorPrincipal

    # if max < principal
    c.lt.s  $f21, $f22
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

    #jump to main
    j main

# $f23 = 0.005
# $f24 = 0.399
# $f25 = User Interest

interest:
    # print prompt for interest
    li      $v0, 4 		                        
    la      $a0, promptInterest                       
    syscall                                         

    # loading min interest
    la      $a0, C
    lwc1    $f23, ($a0)

    # loading max interest
    la      $a0, D
    lwc1    $f24, ($a0)

    # reading user interest and storing in $f25
    li      $v0, 6
    syscall 
    mov.s   $f25, $f0

    # if user interest < min
    c.lt.s  $f25, $f23
    bc1t    errorInterest

    # if max < user interest
    c.lt.s  $f24, $f25
    bc1t    errorInterest

    # else
    j       payment

# print error message for out of range input
errorInterest:
    li      $v0, 4 		                        
    la      $a0, errorInput                       
    syscall 

    li      $v0, 4 		                        
    la      $a0, linefeed                      
    syscall

    j interest 

# $f26 = 1.00
# $f27 = 2,000,000.00
# $f28 = User Payment

payment:
    # print prompt for payment
    li      $v0, 4 		                        
    la      $a0, promptPayment                     
    syscall                                         

    # loading min payment
    la      $a0, E
    lwc1    $f26, ($a0)

    # loading max payment
    la      $a0, F
    lwc1    $f27, ($a0)

    # reading user payment and storing in $f28
    li      $v0, 6
    syscall 
    mov.s   $f28, $f0

    # if user payment < min
    c.lt.s  $f28, $f26
    bc1t    errorPayment

    # if max < user payment
    c.lt.s  $f27, $f28
    bc1t    errorPayment

    #else
    j       calculations

# print error message for out of range input
errorPayment:
    li      $v0, 4 		                        
    la      $a0, errorInput                       
    syscall 

    li      $v0, 4 		                        
    la      $a0, linefeed                      
    syscall

    j       payment 

# $f22 = User Principal
# $f25 = User Interest 
# $f28 = User Payment
# $f13 = monthly fraction
# $f14 = monthly interest
# $f15 = 0

calculations:
    # adding one to $t0, $t0 will be the month counter
    add		$t0, $t0, 1

    # print prompt for month up to month #
    li      $v0, 4
    la		$a0, promptMonth
    syscall

    # print month #
    li      $v0, 1
    move	$a0, $t0
    syscall

    # print from current up to principal amount
    li      $v0, 4
    la		$a0, promptCurrent
    syscall

    # print current principal amount
    li      $v0, 2
    mov.s   $f12, $f22
    syscall

    # print newline
    li      $v0, 4
    la		$a0, linefeed
    syscall

    #calculate monthly interest
    mul.s   $f29, $f22, $f25        # user principal ($f22) * user interest ($f25) = $f29
    mul.s   $f29, $f29, $f13        # $f29 * monthly fraction ($f13) = monthly interest ($f29)

    #calculate payment to the principal
    sub.s   $f14, $f28, $f29        # user payment ($f28) - monthly interest ($f29) = payment to principal ($f14)

    #calculate new principal
    sub.s   $f22, $f22, $f14        # user principcal ($f22) - payment to principal ($f14) = new principal ($f22)

    # if new principal < 0, then jump to complete
    c.lt.s  $f22, $f15
    bc1t    complete  

    # else repeat
    j		calculations

complete:
    # print newline
    li      $v0, 4
    la		$a0, linefeed
    syscall

    # print It up to # of months
    li      $v0, 4
    la		$a0, promptIt
    syscall

    # print total # of months it took to complete the loan
    li      $v0, 1
    move    $a0, $t0
    syscall

    # print months to the end
    li      $v0, 4
    la		$a0, promptMonths
    syscall

    # print newline
    li      $v0, 4
    la		$a0, linefeed
    syscall

# exit the program
exit:
    jr      $31    