// Test Case 02
// 8 bit SAP1 Computer

// Entry - Reset Vector
// 0: 0 188 240 0
.x 0x00 0x04
NOP         
JMP #5      // Jump to program entry                        entry();
HLT
NOP

// Variables
// 4: 2 0 0 0 32 2 64 1 16 48 56 64
.d 0x04 0x0C // Offset 8, size 12
0x02        //  4 : *exit()
0x28        //  5 : *enter()
0x03        //  6 : remainder 
0x02        //  7 : start i
0x20        //  8 : *subtract()
0x40        //  9 : stack
0x60        // 10 : *this_prime = 64
0x01        // 11 : inc = 1
0x10        // 12 : *incriment()
0x2A        // 13 : *checkPrime()
0x38        // 14 : *addToPrimes()
0x60        // 15 : *primes = 64

// Incriment routine
// 16: 25 43 64 57 26 64 164 31
// 24: 58 25 54 26 128 48 184 0
.x 0x10 0x10
LDA #9      // Load current value (i) to A                  i += 1;
LDB #11     // Load incriment (1) to B
ADD         // Incriment value into A
STR #9      // Store New value in (i)
LDA #10     // Load *this_prime pointer to A                
ADD         // Add 1 to this_prime                          if(*this_prime + 1 < 0)
JPC #2      // If (next prime will overflow), rt              exit;
LDA #15     // else, Load *primes pointer to A              else 
STR #10     // set this_prime to primes, go to subtract       this_prime = &primes[0];
LDA #9      // Load i to A                                  remainder = i;
STR #6      // Store in remainder
LDA #10     // Load *this_prime to A                        decriment = this_prime[0];
LDM         // Derefernce to A
STR #3      // Copy A to decriment (for division)
JMP #8      // Jump to *subtract to start dividing          subtract();
NOP

// Subtract routine, divides and checks for divisibility
// 32:  25 80 54 156 173 184
.x 0x20 0x08 // Offset 32, size 8
LDA #6      // Load remainder to A                          remainder -= decriment;
LDB #3      // Load decriment to B
SUB         // Subtract
STR #6      // Store result to remainder
JPZ #12     // Jump to incriment if zero (divisible)        if(remainder == 0) incriment();
JPC #13     // Jump to check for more primes                if(remainder < 0) checkPrime();
JMP #8      // Jump to *subtract to keep dividing           subtract();

// 40: 26 57 188 0
// Entry
.x 0x28 0x04    // offset 40, sizze 4
LDA #7      // Load Start i                                 i = 2;
STR #9      // push to i stack
JMP #12     // Jump to incriment
NOP

// Check for next primes routine
// 44: 
.x 0x2A 0x0A // Offset 44, size 10
LDA #10     // Load *this_prime pointer                     this_prime += 1; incriment address of prime pointer
LDB #11     // Load incriment of 1
ADD         // Add to A
STR #10     // Store *this_prime pointer
LDM         // dereference *this_prime                      
MOV         // move *this_prime to B
LDI #0      // load 0 to A                                  if(*this_prime == 0)
ADD         // Add to self                                      addToPrimes();
JPZ #14     // If this_prime is zero, add i to primes       else
JMP #8      // else, Jump to *subtract to check next prime      subtract();
NOP

// Add to primes list routine
// 56: 25 40 80 208 26 192 188 0
.x 0x38 0x08 // Offset 56, size 8
LDA #9      // Load i                                  ( *this_prime = i; )
LDB #10     // Load *this_prime pointer
SUB         // Subtract to A to get difference         diff = i - (int)this_prime;
MOV         // move A to B                              
LDA #10     // Load *this_prime pointer to A            
STM         // Store (i) to *this_prime                *this_prime = this_prime + diff;
JMP #12     // Jump to incriment                            incriment();
NOP

// Stack
.d 0x40 0x20

// =========================================
// Prime Array
.d 0x60 0x40 // Offset 96, size 64
0x02 0x03
