# Simplified RC4 Stream Cipher Implementation
This project implements a hardware module for a simplified version of the RC4 stream cipher, designed for encrypting plaintext. The implementation includes both the Key Scheduling Algorithm (KSA) and the Pseudo-Random Generation Algorithm.

## Project Structure
- rc4.sv: Contains the rc4 module, the source code for the hardware implementation of the RC4 cipher.
- rc4_tb.sv: Contains the rc4_tb testbench module, which drives, stimulates, and validates the behavior of the rc4 module.

## Key Features
- Fixed Key Length: Employs a 16-byte symmetric key
- Encryption Logic: XOR operation combines the generated keystream with plaintext bytes for ciphertext output.
- State Machine: Operates according to a six-state Finite State Machine.
- Key_Valid Signal: Enables introduction of new symmetric keys without full system reset.

## Signals
### Input
clk, rst_n, key_valid, key_input, din, din_valid 
### Output
key_stream_valid, dout, dout_ready
### Registers
Key_stream, Key, i, j, S
