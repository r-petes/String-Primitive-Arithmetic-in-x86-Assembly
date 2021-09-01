TITLE Project 6     (Proj6_petersr5.asm)

; Author: Rachel Peterson
; Last Modified: 8/12/2021
; Description: This program prompts the user for 10 signed decimal integers that will fit within a 32-bit register. It validates those numbers and re-prompts if the number is too
;				big or too small, something other than a number, a "-" or a "+", or if the user did not enter a number. It will convert the strings into an array of integers in order
;				to do arithmetic calculations. Then it converts those integers back to strings and prints out each string that the user entered. After that, the program converts the string  
;				input to an integer, calculates the total sum of all ten numbers, and their average, and converts those numbers from integers into strings that it then will display
;				along with their corresponding labels. 

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt for the user to input a number, then puts the user�s keyboard input into a memory location
;
; Preconditions: integerPrompt and rePrompt are set as strings to prompt the user for an integer.
;				If the user previously entered an invalid string, the macro will be passed rePrompt, otherwise
;				it will be passed integerPrompt. inputString is initialized as an empty string of max length 12. 
;				charsRead is initialized to 0 to be filled with the number of characters read from the user's string. 
;
; Postconditions:  None
;
; Receives: prompt string, either integerPrompt or rePrompt via the parameter prompt
; 
; Returns: user's keyboard input (by reference) into the inputString via the macro parameter integerString,
;			number of characters read by the macro passed via numberofCharsRead to charsRead (by reference)
; ---------------------------------------------------------------------------------

mGetString MACRO integerString:REQ, prompt:REQ, numberofCharsRead:REQ

	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	PUSH	EDI

; Display a prompt (input parameter, by reference) 
	MOV		EDX, prompt
	CALL	WriteString

; Get the users keyboard input into a memory location (output parameter, by reference)
	MOV		EDX, integerString
	MOV		ECX, 12							; Set the maximum length of the input string to 12
	CALL	ReadString
	MOV		EDI, numberofCharsRead			; Store the number of characters read 
	MOV		[EDI], EAX


	POP		EDI
	POP		EAX
	POP		ECX
	POP		EDX


ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Print the string which is stored in outputString to the macro
;
; Preconditions: outputString is set to the string of the number to be printed and is passed by reference
;					to the macro
; 
; Postconditions: None
;
; Receives: outString parameter which is string stored in outputString (by reference)
;
; Returns: Prints the string in outputString
; ---------------------------------------------------------------------------------

mDisplayString MACRO outString:REQ

	PUSH	EDX
	PUSH	EBP
	MOV		EBP, ESP


;  Print the string stored in a specified memory location
	MOV		EDX, outString
	CALL	WriteString

	POP		EBP
	POP		EDX

ENDM

; Constants

ARRAYSIZE = 10												
SETUP_ESI_LO TEXTEQU <MOV ESI, OFFSET lowestBound>			; Sets ESI to a string with the lowest negative 32-bit integer		
SETUP_ESI_HI TEXTEQU <MOV ESI, OFFSET highestBound>			; Sets ESI to a string with the highest 32-bit integer
LO = -2147483648											; Global constant with the lowest 32 bit integer									

.data

; User prompts and print descriptions: 
introduction		BYTE	"Project 6: Designing low-level I/O Procedures and Using Macros", 13, 10 ,0
programmerIntro		BYTE	"By Rachel Peterson", 13, 10, 13, 10 , 0 
promptDescription	BYTE	"Please provide 10 signed decimal integers.", 13, 10,
							"Each number must be small enough to fit into a 32 bit register. After you have finished ", 
							"inputting the raw numbers I will display a list of the integers, their sum, and their average.", 13, 10, 0
integerPrompt		BYTE	"Please enter a signed number: ",0
integerError		BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
rePrompt			BYTE	"Please try again: ",0
displayNumbers		BYTE	"You entered the following numbers: ", 0
displaySum			BYTE	"The sum of these numbers is: ",0
displayRoundedAvg	BYTE	"The rounded average is: ",0
goodbye				BYTE	"Thanks for playing!",0

; Constant strings
lowestBound			BYTE	"2147483648",0
highestBound		BYTE	"2147483647",0

; Data variables
inputString			BYTE	12 DUP(?)
totalSum			SDWORD	?
roundedAvg			SDWORD	?
charsRead			SDWORD	0
numericValue		SDWORD	?
numericValueArray	SDWORD	ARRAYSIZE DUP(?)
outputString		BYTE	12 DUP(?)


.code
main PROC USES ECX ESI EDX EAX

; Display the intro message
	MOV		EDX, OFFSET introduction
	CALL	WriteString
	
	MOV		EDX, OFFSET programmerIntro
	CALL	WriteString
	
	MOV		EDX, OFFSET promptDescription
	CALL	WriteString

	MOV		ECX, 10
	MOV		ESI, OFFSET numericValueArray

; Loop to get 10 valid integers from the user 
_LoopToFillArray:	
	PUSH	ESI
	PUSH	OFFSET charsRead
	PUSH	OFFSET integerPrompt
	PUSH	OFFSET integerError
	PUSH	OFFSET rePrompt
	PUSH	OFFSET inputString
	CALL	ReadVal							; Call ReadVal to get those integers
	ADD		ESI, TYPE numericValueArray		; Increment the address of the array being pointed to, so as to fill each element of the array
	LOOP	_LoopToFillArray
	
	MOV		ECX, 10
	MOV		ESI, OFFSET numericValueArray

; Print string for displaying numbers
	MOV		EDX, OFFSET displayNumbers
	CALL	WriteString

; Display the integers
_LoopToPrintArray:

	; Call WriteVal to display each number
	PUSH	OFFSET outputString
	PUSH	[ESI]
	CALL	WriteVal					
	ADD		ESI, TYPE numericValueArray		; Point to the next number in the array
	CMP		ECX, 1
	JE		_SkipLastComma					; Skip printing the last comma
	
	; Print comma and space in between
	MOV		AL, ","
	CALL	WriteChar
	MOV		AL, " "
	CALL	WriteChar
_SkipLastComma:
	LOOP	_LoopToPrintArray
	CALL	CrLf


; Calculate the total sum of the integer array
	MOV		ECX, 10
	MOV		ESI, OFFSET numericValueArray
	MOV		EAX, 0
	
_LoopToSumArray:
	ADD		EAX, [ESI]	
	ADD		ESI, TYPE numericValueArray		; Point to the next number in the array
	LOOP	_LoopToSumArray
	MOV		totalSum,  EAX					; Store the sum in the variable totalSum

; 	print sum display
	MOV		EDX, OFFSET displaySum
	CALL	WriteString

; Display the sum
	PUSH	OFFSET outputString
	PUSH	totalSum
	CALL	WriteVal						; Call WriteVal to display the sum
	CALL	CrLf


; Calculate the average
	; divide totalSum by 10
	MOV		ECX, ARRAYSIZE
	MOV		EAX, totalSum
	CDQ
	IDIV	ECX
	MOV		roundedAvg, EAX

	; round (floor) the average
	CMP		EDX, 0
	JGE		_storeRoundedAvg				; If there is no remainder or the number is positive, just print the average as is
	SUB		EAX, 1							; Otherwise, the negative number must be rounded down (floored)

; Store result in roundedAvg
_storeRoundedAvg:
	MOV		roundedAvg, EAX

; Print the message for displaying the rounded average: 
	MOV		EDX, OFFSET displayRoundedAvg
	CALL	WriteString

; Display the average
	PUSH	OFFSET	outputString
	PUSH	roundedAvg
	CALL	WriteVal						; Call WriteVal to display the number
	CALL	CrLf
	

; Display the outro message	
	MOV		EDX, OFFSET goodbye
	CALL	WriteString
	

	Invoke ExitProcess,0					; Exit to operating system

	RET
main ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: Calls the mGetString macro and then converts the resulting string into its numeric value 
; representation, and validates that the user's input is a valid SDWORD integer. 
;
; Preconditions: numericValueArray is a 10 element, SDWORD array 
;					charsRead is initialized to 0, integerPrompt is a string which prompts the user for an integer, 
;					integerError is a string error message for invalid inputs, rePrompt is a string with instructions
;					to enter another integer after an erroneous attempt, inputString is an empty string initialized to size 12.
;					All variables are passed by reference on the stack. 
;
; Postconditions: inputString has been set by the macro mGetString, charsRead contains the number of characters that a user has 
;					inputted
;
; Receives: inputString, a user-inputted string from mGetString macro, and charsRead, integerError, integerPrompt, rePrompt,
;				 inputString, and numericValueArray passed by reference
;
; Returns: User-inputted integers in their corresponding place in the numericValueArray
; ---------------------------------------------------------------------------------

ReadVal PROC USES ESI EAX ECX EDI EDX EBX

	PUSH	EBP

	MOV		EBP, ESP

	MOV		ESI, [EBP + 32]				; Access the address of the string to be filled
	MOV		EAX, [EBP + 44]				; Access the address of the integer prompt message
	MOV		EBX, 0						; Track if the number is negative 1 = negative
	
_readNewVal:
; Invoke the mGetString macro to get user input in the form of a string of digits
	mGetString ESI, EAX, [EBP + 48]

; --------------------------
; Validates that the string that the user entered is within the SDWORD bounds, also 
;		ensures that the user entered at least one character, and prompts an error
;		message if those conditions are not met
; --------------------------

	; Check if mGetString read zero characters
	MOV		ECX, [EBP + 48]
	MOV		ECX, [ECX]
	CMP		ECX, 0									; If the characters read is zero, trigger the error message
	JE		_errorMessage

	MOV		EBX, [EBP + 48]
	MOV		ECX, [EBX]
	CMP		ECX, 11									; If the user has inputted a string of more than 11 characters, cause an error message
	JG		_errorMessage
	JNE		_CheckIfTooHigh

	; Check if the number is lower than the SDWORD bounds
	SETUP_ESI_LO
	MOV		EDI, [EBP + 32]
	; Check if first char is the negative sign
	MOV		AL, "-"
	CLD
	SCASB 
	JNZ	_checkIfTooHigh								; If the first character in the input string is positive, check if it exceeds the upper bounds of a SDWORD
	MOV		ECX, 10
	MOV		EBX, 1

; Compare the input char to the bound of SDWORDS
_CompareInputToCharInBounds:
	CLD	
	CMPSB											; If the inputted character is larger than the number should be at that place, then return an error
	JL		_errorMessage
	LOOP	_CompareInputToCharInBounds				; Loop through both strings comparing the values
	JMP		_convertToInteger			

_checkIfTooHigh:
	MOV		EBX, [EBP + 48]
	MOV		ECX, [EBX]
	CMP		ECX, 10
	JG		_checkIfFirstIsPlusSign					; Check for exceeding upper bounds slightly differently if the first character is a "+" sign
	JNE		_convertToInteger						; If the positive string is not 10 or more characters, then it does not exceed upper bounds

	; Check if the number is higher than the SDWORD bounds
	SETUP_ESI_HI
	MOV		EDI, [EBP + 32]
	MOV		ECX, 10
	JMP		_CompareInputToCharInBounds				

; Check that if the number is positive and 11 characters long, the first character must be a "+" sign or it will prompt an error
_checkIfFirstIsPlusSign:
	MOV		ESI, [EBP + 32]	
	CLD
	LODSB
	CMP		AL, 43
	JNE		_errorMessage
	JMP		_CompareInputToCharInBounds

; --------------------------
; Checks that each character in the user-entered string is an integer, and then
;		converts that string into an SDWORD integer value
; --------------------------

_convertToInteger:

	MOV		EBX, 0
	; Check if the number is the lowest possible, if so, manually convert the integer in the array to that number. 
	SETUP_ESI_LO
	MOV		EDI, [EBP + 32]
	ADD		EDI,  1
	; Compare the input string (from +1 character to the end) to the ESI LO number
	MOV		ECX, 10

_compareLowestNumber:
	CLD
	CMPSB
	JE		_reLoopComparison
	MOV		EBX, 1							; If the numbers are ever not equal, move 1 into EBX register

_reLoopComparison:
	LOOP	_compareLowestNumber
; If, when loop finished, and the numbers are determined to be equal then change the number in the array manually to -2147483648 
	CMP		EBX, 0
	JNE		_converToIntegerNormally
	MOV		EAX, LO
	MOV		EDI, [EBP + 52]
	MOV		[EDI], EAX	
	JMP		_readValSuccessful


_converToIntegerNormally:

	MOV		EBX, 0							; Set EBX to zero, will be used to convert to negative integer representation

	MOV		ESI, [EBP + 32]	
	MOV		EDI, [EBP + 52]					; Access the address of the numeric value representation
	MOV		EDX, [EBP + 48]					; Loop through the number of characters read
	MOV		ECX, [EDX]

	; check if the first ASCII character is a number
	CLD
	LODSB
	CMP		AL, 43							; Check if the first character is a "+"
	JNE		_checkifMinus
	DEC		ECX								; Manually decrement ECX to move through only the length of the charsRead 
	JMP		_checkNextCharacter				; If it was a plus sign, move to check the next number after storing "+" at that location

_checkifMinus:
	CMP		AL, 45
	JNE		_checkifNumber					; If it is not a minus sign, check that it is a number
	MOV		EBX, 1
	DEC		ECX								; Manually decrement ECX to move through only the length of the charsRead 
	JMP		_checkNextCharacter				; If it was a minus sign, move to check the next number after storing "-" at that location


; Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD)
_checkNextCharacter:
	CLD
	LODSB					
_checkifNumber:
	CMP		AL, 48							; Check if the character entered was a valid integer 0-9
	JL _errorMessage
	CMP		AL, 57
	JG	_errorMessage

	SUB		AL, 48							; Convert the character to ASCII - 48
	MOV		EDX, [EDI]
	IMUL	EDX, 10
	MOV		[EDI], EDX
	ADD		[EDI], AL						; Add that number to the integer total

	LOOP	_checkNextCharacter

	CMP		EBX, 1							; If number is positive, conversion to integer representation is finished
	JNE		_readValSuccessful				
	MOV		EAX, [EDI]
	IMUL	EAX, -1
	MOV		[EDI], EAX					
	JMP		_readValSuccessful				; Otherwise, convert to negative representation and finish


; --------------------------
; Displays an error message if the user has entered an invalid string
;		and then re-prompts the user for a new number by looping to the
;		beginning of the procedure
; --------------------------

_errorMessage:

		MOV		EDX, [EBP + 40]
		CALL	WriteString
		CALL	CrLf

	; For every character entered by the user, clear that value
	MOV		EAX, 0
	MOV		[EDI], EAX
	MOV		ECX, [EBP + 48]
	MOV		ECX, [ECX]
	CMP		ECX, 0
	JE		_rePrompt
	MOV		EDI, [EBP + 32]

_clearValue:
	MOV		AL, 0
	CLD
	STOSB
	LOOP	_clearValue

; Reprompt for a new integer after an invalid integer input
_rePrompt:
	MOV		ESI, [EBP + 32]					; Access the address of the string to be filled
	MOV		EAX, [EBP +  36]				; Access the address of the integer prompt message
	JMP		_readNewVal

_readValSuccessful:

	POP EBP

	RET 24

ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: Converts a numeric (SDWORD) value to a string of ASCII digits and invoke the mDisplayString macro
; to print the ascii representation of the SDWORD value to output. 
;
; Preconditions: outputString is initialized as an empty string to be filled by the number to be converted and printed to output
;				outputString has been passed to the procedure by reference and the relevant SDWORD integer to be converted into a string 
;				has been passed by value
;
; Postconditions: None
;
; Receives: outputString passed by reference, an SDWORD integer passed by value
;
; Returns: Prints the string representation of the integers passed to the procedure to output
; ---------------------------------------------------------------------------------

WriteVal PROC USES EBX EDI ECX EBX EAX 

	PUSH	EBP

	MOV		EBP, ESP

	MOV		EBX, [EBP + 28]							; Access the integer SDWORD value 
	MOV		EDI, [EBP + 32]							; Access the reference to outputString

; --------------------------
; Identifies the size of the integer, which will be used to separate the
;	integer into its component tens places and then convert each into a
;	string value
; --------------------------

	
	MOV		ECX, 10
	MOV		EAX, EBX
	CDQ	
	IDIV	ECX
	MOV		EBX, EAX
	MOV		ECX, 1
	CMP		EBX, 0
	JG		_findPositiveLength								; If the integer divided by 10 is greater than 0, do the calculations for a positive integer conversion
	JE		_OneDecimalPlacePrint					; If the integer divided by 10 is zero, then do the calculations for integers between -10 and 10

	MOV		AL, "-"									; Store a "-" symbol in the first character of the string, and point to the next character
	CLD
	STOSB
	MOV		ECX, -1						
_findNegativeLength:
	IMUL	ECX, 10
	CMP		ECX, EBX								; Find the size of the current integer by looping multiplying ECX by 10 comparing it to ECX
	JGE		_findNegativeLength						
	MOV		EBX, [EBP + 28]							; Re-set the value of EBX to the integer value (as it was previously divided by 10 to calculate its size)
	JMP		_convertToAscii
_findPositiveLength:
	IMUL	ECX, 10
	CMP		ECX, EBX								; Find the size of the current integer by looping multiplying ECX by 10 comparing it to ECX
	JLE		_findPositiveLength						
	MOV		EBX, [EBP + 28]							; Re-set the value of EBX to the integer value (as it was previously divided by 10 to calculate its size)
	JMP		_convertToAscii


; For only printing numbers with one decimal place, reset ECX to 1 
_oneDecimalPlacePrint:								
	MOV		ECX, 1
	MOV		EBX, [EBP + 28]	
	CMP		EBX, 0
	JGE		_convertToAscii							; Add the negative indicator to ECX if integer is negative
	MOV		AL, "-"
	CLD
	STOSB
	MOV		ECX, -1

; --------------------------
; Convert the number at each tens place in the integer to its corresponding string
; --------------------------

	

_convertToAscii:
	MOV		EAX, EBX
	CDQ
	IDIV	ECX					; Divide EBX by the largest tens place in the current EBX value, starting from the total SDWORD integer value
	ADD		EAX, 48
	CLD
	STOSB						; Store the quotient of this calculation in the string character at that position in outputString

	MOV		EBX, EDX			; Set the remainder as the new EBX value to find the next character
	MOV		EAX, ECX
	MOV		ECX, 10
	CDQ		
	IDIV	ECX					; Divide ECX by 10 to get the next tens place in the SDWORD integer
	CMP		EAX, 0				
	MOV		ECX, EAX
	JNE		_convertToAscii		; Continue converting to ASCII until ECX reaches zero

; --------------------------
; Print the full string and then clear the display string so as to reset
;	the memory for the next string to be printed
; --------------------------


	; Invoke mDisplayString macro to print the string in ascii representation to output
	MOV		EDI, [EBP + 32]		
	
	mDisplayString EDI

	; Clear the display string so that the next string can be written without issue
	MOV		ECX, 12
	CLD
	MOV		AL, 0
	REP		STOSB
	
	POP EBP

	RET 8

WriteVal ENDP

END main
