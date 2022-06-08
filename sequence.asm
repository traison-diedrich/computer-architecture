# ##################################################### #
# sequence.asm                                          #
#                                                       #
# Program for calculating a sequence of numbers         #
#                                                       #
# Traison Diedrich, ID: 800733263                       #
# ##################################################### #

.data

# Constant strings to be output to the terminal
promptOrigin:   .asciiz "Enter the origin of your number sequence (1-5): "
promptFactor:   .asciiz "Enter your multiple factor (2-7): "
promptTotal:    .asciiz "Enter the total number of the numbers (3-30): "
errorInput:     .asciiz "You made an invalid input. Please try again."
promptSum:      .asciiz "Check-sum: "
commaSpace:     .asciiz ", "
linefeed:       .asciiz "\n"

    .text
    .globl main

main:
    # print prompt for origin
    li      $v0, 4 		                        
    la      $a0, promptOrigin                       
    syscall                                         

    # get origin
    li      $v0, 5                                  # code for read_int
    syscall                                         # get int from user, returned in $v0
    move    $t1, $v0                                # move int to $t1 register

    # test if integer is in range
    blt     $t1, 1, originError                      # if int is less than 1
    bgt     $t1, 5, originError                      # if int is greater than 5
    j       factor                                  # jump to next prompt if input is in range

# print error for incorrect origin
originError:
    # print error message
    li      $v0, 4 		                        
    la      $a0, errorInput                         
    syscall                                         

    # print newline
    li      $v0, 4 		                        
    la      $a0, linefeed                           
    syscall                                         

    # jump to main
    j       main

factor:
    # print prompt for factor
    li      $v0, 4 		                        
    la      $a0, promptFactor                       
    syscall                                         

    # get factor
    li      $v0, 5                                  # code for read_int
    syscall                                         # get int from user, returned in $v0
    move    $t2, $v0                                # move int to $t1 register

    # test if integer is in range
    blt     $t2, 2, factorError                     # if int is less than 2
    bgt     $t2, 7, factorError                     # if int is greater than 7
    j       total                                   # jump to next prompt if input is in range

# print error for incorrect factor
factorError:
    # print error message
    li      $v0, 4 		                        
    la      $a0, errorInput                         
    syscall                                         

    # print newline
    li      $v0, 4 		                        
    la      $a0, linefeed                           
    syscall                                         

    # jump to factor
    j       factor

total:
    # print prompt for total
    li      $v0, 4 		                        
    la      $a0, promptTotal                       
    syscall                                         

    # get total
    li      $v0, 5                                  # code for read_int
    syscall                                         # get int from user, returned in $v0
    move    $t3, $v0                                # move int to $t1 register

    # test if integer is in range
    blt     $t3, 3, totalError                      # if int is less than 3
    bgt     $t3, 30, totalError                     # if int is greater than 30

    # print newline
    li      $v0, 4 		                        
    la      $a0, linefeed                           
    syscall

    # jump to printing sequence
    j       sequence                                

# print error for incorrect total
totalError:
    # print error message
    li      $v0, 4 		                        
    la      $a0, errorInput                         
    syscall                                         

    # print newline
    li      $v0, 4 		                        
    la      $a0, linefeed                           
    syscall                                        

    # jump to toatal
    j       total

# prints out the sequence of numbers
sequence:
    # print number
    li      $v0, 1 		                        
    move    $a0, $t1                         
    syscall

    # add $t1 (current number) to $t5, $t5 will be total of all numbers
    add     $t5, $t5, $t1

    # add factor to current number in sequence to get next number
    add		$t1, $t1, $t2

    # add 1 to $t4, $t4 is functioning as counter for while loop
    add		$t4, $t4, 1

    # check if $t4 (counter) is greater than or equal to $t3 (number of numbers to generate)
    bge     $t4, $t3, printSum

    # print comma and space
    li      $v0, 4 		                        
    la      $a0, commaSpace                         
    syscall

    # jump to top of loop
    j		sequence

# prints two newlines and the total sum
printSum:
    # print newline
    li      $v0, 4 		                        
    la      $a0, linefeed                           
    syscall

    # print newline
    li      $v0, 4 		                        
    la      $a0, linefeed                           
    syscall

    # print check-sum
    li      $v0, 4 		                        
    la      $a0, promptSum                           
    syscall

    # print sum
    li      $v0, 1 		                        
    move    $a0, $t5                         
    syscall

# exit the program    
exit:
    jr	$31				
    