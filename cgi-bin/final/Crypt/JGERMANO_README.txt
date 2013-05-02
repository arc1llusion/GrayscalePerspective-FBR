The Crypt::SHA module has been modified for this project to use the PurePerl version of Digest SHA encryption algorithms. 
The original version of Digest is in C, however to keep from compiling I chose to use the Perl implementation.

This has performance drawbacks, and should I be in complete control I'd have used the C version. For simplicity at the moment and unsure of a C compiler for crux,
the Perl implementation was used. This required some modifications in the SaltedHash.pm because the package and path is different. Once changing the package,
the script ran just fine and encryption works.

CRUX only supports 32 bit, so we use SHA-256 encryption for user passwords.