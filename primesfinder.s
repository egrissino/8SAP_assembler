// Test Case 02
// 8 bit SAP1 Computer

.x 0x00 0x01
JMP #1

// Registers
.d 0x01 0xF // Offset 1, size 15
0xF0        //  1 : *enter()
0xF4        //  2 : *exit()
0x00        //  3 : 0
0x00        //  4 : 
0x00        //  5 : 
0x00        //  6 : remainder 
0x00        //  7 : decriment
0x20        //  8 : *subtract()
0x00        //  9 : i
0x60        // 10 : *this_prime
0x01        // 11 : 1
0x10        // 12 : *incriment()
0x30        // 13 : *checkPrime()
0x40        // 14 : *addToPrimes()
0x60        // 15 : *primes = 64

// Incriment routine
.x 0x10 0x10
LDA #9      // Load current value (i) to A                  
LDB #11     // Load incriment (1) to B                      
ADD         // Incriment value into A                       
JPC #2      // If (next prime will overflow), rt            if (i+1 > 255) exit;
STR #9      // Store New value in (i)                       else: i = i+1;
LDA #15     // else, Load *primes pointer to A              
STR #10     // set this_prime to primes, go to subtract     this_prime = &primes[0];
LDA #9      // Load i to A                                  
STR #6      // Store in remainder                           remainder = i;
LDA #10     // Load *this_prime to A                        
LDM         // Derefernce to A
STR #7      // Copy A to decriment (for division)           decriment = this_prime[0];
JMP #8      // Jump to *subtract to start dividing          subtract();

// Subtract routine, divides and checks for divisibility
.x 0x20 0x08 // Offset 32, size 8
LDA #6      // Load remainder to A                          remainder -= decriment;
LDB #7      // Load decriment to B
SUB         // Subtract
STR #6      // Store result to remainder
JPZ #12     // Jump to incriment if zero (divisible)        if(remainder == 0) incriment();
JPC #13     // Jump to check for more primes                if(remainder < 0) checkPrime();
JMP #8      // Jump to *subtract to keep dividing           subtract();

// Check for next primes routine
.x 0x30 0x0C // Offset 44, size 12
LDA #10     // Load *this_prime pointer                     this_prime += 1; incriment address of prime pointer
LDB #11      // Load incriment of 1
ADD         // Add to A
STR #10     // Store *this_prime pointer
LDM         // dereference *this_prime
STR #7      // Store it in the decriment                     
LDB #3      // load 0 to B                                  if(*this_prime == 0)
ADD         // Add to self                                      addToPrimes();
JPZ #14     // If this_prime is zero, add i to primes       else
LDA #9
STR #6
JMP #8      // else, Jump to *subtract to check next prime      subtract();

// Add to primes list routine
.x 0x40 0x08 // Offset 56, size 8
LDA #9      // Load i                                  ( *this_prime = i; )
LDB #10     // Load *this_prime pointer
SUB         // Subtract to A to get difference         diff = i - (int)this_prime;
MOV         // move A to B                              
LDA #10     // Load *this_prime pointer to A            
STM         // Store (i) to *this_prime                *this_prime = this_prime + diff;
JMP #12     // Jump to incriment                            incriment();
NOP

// =========================================
// Prime Array
.d 0x60 0x40 // Offset 96, size 64
0x02


// Entry
.x 0xF0 0x04    // offset 248, sizze 4
LDI #2      // Load start value                                i = 2;
STR #9      // Set i
JMP #12     // Jump to incriment                       incrimewnt
NOP

// Exit
.x 0xF4 0x04
HLT
NOP

