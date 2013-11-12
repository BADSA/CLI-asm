FileName = cli
$(FileName): $(FileName).o
	ld -m elf_i386 -o $(FileName) $(FileName).o

$(FileName).o: $(FileName).asm
	nasm -f elf -g -F stabs $(FileName).asm -l $(FileName).lst
