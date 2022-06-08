# ##################################################### #
# RoutingTable.asm                                      #
#                                                       #
# Program for processing and analyzing an IP address    #
#   through an IP Routing Table                         #
#                                                       #
# Traison Diedrich, ID: 800733263                       #
# ##################################################### #

.data

# IP Table information
IP_ROUTING_TABLE_SIZE:
		.word	20 

IP_ROUTING_TABLE:
		# line #, x.x.x.x -------------------------------------
		.byte	0, 120, 188,  76, 111	# 120.188.76.111 (class A)
		.byte	1, 202,  57, 233,   3	# 207.57.233.3 (class C)
		.byte	2, 195, 244, 201,  84	# 195.244.201.84 (class C)
		.byte	3, 138,  93, 222, 192	# 138.93.222.192 (class B)
		.byte	4, 131,  55, 141,  22	# 131.55.141.22 (class B)
		.byte	5,  18, 252,  39, 253	# 18.252.39.253 (class A)
		.byte	6,  48, 122, 177,   9	# 48.122.177.9 (class A)
		.byte	7, 197, 165, 210, 192	# 197.165.210.192 (class C)
		.byte	8, 202,  44, 133, 222	# 202.44.133.222 (class C)
		.byte	9,  24, 125,  99,  99	# 24.125.99.99 (CLASS A)
		.byte	20, 146, 163, 255, 255	# 146.163.255.255 (class B)
		.byte	21, 147, 163, 255, 255	# 147.163.255.255 (class B)
		.byte	22, 201,  88,  88,  90	# 201.88.88.90 (class C)
		.byte	23, 182, 151,  44,  56	# 182.151.44.56 (class B)
		.byte	24,  24, 125, 100, 100	# 24.125.100.100 (class A)
		.byte	25, 146, 163, 140,  80	# 146.163.170.80 (class B)
		.byte	26, 146, 163, 147,  80	# 146.163.147.80 (class B)
		.byte	27, 146, 164, 147,  80	# 146.164.147.80 (class B)
		.byte	28, 148, 163, 170,  80	# 148.163.170.80 (class B)
		.byte	29, 193,  77,  77,  10	# 193.77.77.10 (class C)

# constant strings to be output to the terminal
promptIP:       .asciiz "Enter an IP address.\n"
promptFirst:    .asciiz "First: "
promptSecond:   .asciiz "Second: "
promptThird:    .asciiz "Third: "
promptFourth:   .asciiz "Fourth: "
errorNum:       .asciiz "The entered number is not in 1-255.\n"
A:              .asciiz "Class A address\n"
B:              .asciiz "Class B address\n"
C:              .asciiz "Class C address\n"
D:              .asciiz "Class D address\n"
IP:             .asciiz "IP: "
period:         .asciiz "."
matching:       .asciiz "Matching domain found at: "
none:           .asciiz "None"
linefeed:       .asciiz "\n"

    .text
    .globl main

# print prompt for IP address
main:
    li      $v0, 4 		                        
    la      $a0, promptIP                       
    syscall 

##############################
#         USER INPUT         #
##############################

# get first number and check if it is in range
First:
    li      $v0, 4 		                        
    la      $a0, promptFirst                       
    syscall                                         

    li      $v0, 5
    syscall 
    move    $s1, $v0
    
    blt     $s1, 1, rangeFirst
    bgt     $s1, 255, rangeFirst
    j		Second
    
# print range error and return to first
rangeFirst:
    li      $v0, 4 		                        
    la      $a0, errorNum                       
    syscall  

    j       First

# get second number and check if it is in range
Second:
    li      $v0, 4 		                        
    la      $a0, promptSecond                       
    syscall                                         

    li      $v0, 5
    syscall 
    move    $s2, $v0
    
    blt     $s2, 1, rangeSecond
    bgt     $s2, 255, rangeSecond
    j		Third
    
# print range error and return to second
rangeSecond:
    li      $v0, 4 		                        
    la      $a0, errorNum                       
    syscall  

    j       Second

# get third number and check if it is in range
Third:
    li      $v0, 4 		                        
    la      $a0, promptThird                       
    syscall                                         

    li      $v0, 5
    syscall 
    move    $s3, $v0
    
    blt     $s3, 1, rangeThird
    bgt     $s3, 255, rangeThird
    j       Fourth

# print range error and return to third
rangeThird:
    li      $v0, 4 		                        
    la      $a0, errorNum                       
    syscall  

    j       Third

# get fourth number and check if it is in range
Fourth:
    li      $v0, 4 		                        
    la      $a0, promptFourth                       
    syscall                                         

    li      $v0, 5
    syscall 
    move    $s4, $v0
    
    blt     $s4, 1, rangeFourth
    bgt     $s4, 255, rangeFourth

    j       domainClass

# print range error and return to fourth
rangeFourth:
    li      $v0, 4 		                        
    la      $a0, errorNum                       
    syscall  

    j       Fourth

##############################
#     PRINT DOMAIN CLASS     #
##############################

# check the domain class of the IP address
domainClass:
    blt     $s1, 128, classA
    blt     $s1, 192, classB
    blt     $s1, 224, classC
    j		classD

# print class A prompt and jump to loadTable
classA:
    li      $v0, 4
    la      $a0, A
    syscall  

    j       loadTable  

# print class B prompt and jump to loadTable
classB:
    li      $v0, 4
    la      $a0, B
    syscall  

    j       loadTable

# print class C prompt and jump to loadTable
classC:
    li      $v0, 4
    la      $a0, C
    syscall

    j       loadTable

# print class D prompt and jump to loadTable
classD:
    li      $v0, 4
    la      $a0, D
    syscall    

    j       loadTable

##############################
#       TABLE MATCHING       #
##############################

# $s1-4 = user IP
# $t0 = current table line
# $t1-4 = current table IP

# $t6 = match tracker (0 if no match, >0 if match)
# $t7 = matching domain line number

# $t8 = table size/loop counter
# $t9 = routing table address

# load table size and address, then jump to loop
loadTable:
    lw      $t8, IP_ROUTING_TABLE_SIZE
    
    la      $t9, IP_ROUTING_TABLE

    li      $t6, 0

    j       loop

# this loop contains two parts due to the branch jump in order to save the matching line
loop:
    # loading IP from table
    lbu     $t0, ($t9)
    lbu     $t1, 1($t9)
    lbu     $t2, 2($t9)
    lbu     $t3, 3($t9)
    lbu     $t4, 4($t9)

    # printing IP address
    li      $v0, 4
    la      $a0, IP
    syscall

    li      $v0, 1
    move    $a0, $t1
    syscall

    li      $v0, 4
    la      $a0, period
    syscall

    li      $v0, 1
    move    $a0, $t2
    syscall

    li      $v0, 4
    la      $a0, period
    syscall

    li      $v0, 1
    move    $a0, $t3
    syscall

    li      $v0, 4
    la      $a0, period
    syscall

    li      $v0, 1
    move    $a0, $t4
    syscall

    li      $v0, 4
    la      $a0, linefeed
    syscall

    # if first part of user IP matches first part of current table IP
    beq     $s1, $t1, checkSecondNum

    # else
    j		loopEnd

loopEnd:
    # subtract one from loop counter
    sub     $t8, $t8, 1    

    # if at the end of the loop
    ble     $t8, 0, checkMatch

    # offset $t9 to next entry in IP Routing Table
    la      $t9, 5($t9)

    # else
    j       loop

checkSecondNum:
    # if the second part of user IP matches the second part of current table IP
    beq     $s2, $t2, save

    # else
    j       loopEnd

save:
    # saves a matching domain address's line number in $t7
    move    $t7, $t0

    # $t6 is used to check whether or not a match has been found throughout the whole IP Table
    add     $t6, $t6, 1

    # jump to loopEnd
    j		loopEnd

#############################
#        PRINT MATCH        #
############################# 

checkMatch:
    # if $t6 = 0, then no match was found
    beq     $t6, 0, printNoMatch

    # else
    j       printMatch

# print that no match was found, then exit
printNoMatch:
    li      $v0, 4
    la      $a0, matching
    syscall

    li      $v0, 4
    la      $a0, none
    syscall

    jr      $31

# print that a match was found and at what line number, then exit    
printMatch:
    li      $v0, 4
    la      $a0, matching
    syscall

    li      $v0, 1
    move    $a0, $t7
    syscall

    jr      $31