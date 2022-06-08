# ##################################################### #
# speeding.asm                                          #
#                                                       #
# Program for calculating the punishment for how much   #
#       a user is speeding                              #
#                                                       #
# Traison Diedrich, ID: 800733263                       #
# ##################################################### #

    .data
# Constant strings to be output to the terminal
promptSpeed:    .asciiz "Enter your current driving speed in MPH (1 to 200): "
promptLimit:    .asciiz "Enter the absolute speed limit spcified for the road you are currntly running on(15 - 70): "
errorSpeed:     .asciiz "You made an invalid input for your current driving speed. Enter a valid input for your current driving speed."
errorLimit:     .asciiz "You made an invalid input for the absolute speed limit. Enter a valid input for the speed limit."
promptSafe:     .asciiz "You are a safe driver!"
prompt120:      .asciiz "$120 fine."
prompt140:      .asciiz "$140 fine."
promptClassB:   .asciiz "Class B misdemeanor and carries up to six months in jail and a maximum $1,500 in fines."
promptClassA:   .asciiz "Class A misdemeanor and carries up to one year in jail and a maximum $2,500 in fines."
linefeed:       .asciiz "\n"

    .text
    .globl main


main:   
        # print prompt for speed
        li      $v0, 4 		                        
        la      $a0, promptSpeed                        
        syscall                                         

        # get driving speed
        li      $v0, 5                                  # code for read_int
        syscall                                         # get int from user, returned in $v0
        move    $t1, $v0                                # move int to $t1 register

        # test if integer is in range
        blt     $t1, 1, printSpeedError                 # if int is less than 1
        bgt     $t1, 200, printSpeedError               # if int is greater than 200
        j       speedLimit                              # jump to next prompt if input is in range

# print error for incorrect vehicle speed
printSpeedError:
        # print error message
        li      $v0, 4 		                        
        la      $a0, errorSpeed                         
        syscall                                         

        # print newline
        li      $v0, 4 		                        
        la      $a0, linefeed                           
        syscall                                         

        # jump to main
        j       main		                          

# get speed limit      
speedLimit:
        # print speed limit prompt
        li      $v0, 4 		                        
        la      $a0, promptLimit                       
        syscall                                        

        # get input from user
        li      $v0, 5                                  # code for read_int
        syscall                                         # get int from user, returned in $v0
        move    $t2, $v0                                # speedLimit stored in $t2

        # check if in range
        blt     $t2, 15, printLimitError                # if int is less than 15
        bgt     $t2, 70, printLimitError                # if int is greater than 70
        j       getResult                               # jump to result if in range

# print speed limit error if number out of range
printLimitError:
        # print error
        li      $v0, 4 		    
        la      $a0, errorLimit     
        syscall                     

        # print newline
        li      $v0, 4 		    
        la      $a0, linefeed       
        syscall                     

        # jump back to speed limit prompt
        j       speedLimit	    

# calculates result and sends to correct branch for final message
getResult:
        # subtract driving speed from speed limit, stored in $t3
        sub     $t3, $t1, $t2

        # newline
        li      $v0, 4
        la      $a0, linefeed
        syscall 

        # finding correct prompt based on how much the user is speeding
        blt     $t3, 1,  printSafe                      # if < 1
        blt     $t3, 21, print120                       # if < 21
        blt     $t3, 25, print140                       # if < 25
        blt     $t3, 35, printClassB                    # if < 35
        j       printClassA	                        # else

# print safe driver and exit        
printSafe:
        li      $v0, 4 		    
        la      $a0, promptSafe    
        syscall 

        j       exit

# print $120 fine and exit
print120: 
        li      $v0, 4 		    
        la      $a0, prompt120    
        syscall 

        j       exit

# print $140 fine and exit
print140:
        li      $v0, 4 		    
        la      $a0, prompt140    
        syscall 

        j       exit

# print class B misdemeanor and exit
printClassB:
        li      $v0, 4 		    
        la      $a0, promptClassB    
        syscall

        j       exit

# print class A misdemeanor and exit
printClassA:
        li      $v0, 4 		    
        la      $a0, promptClassA   
        syscall

# exiting the program
exit:
        jr      $31