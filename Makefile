PROJECT_NAME=caesar_cipher

all: objFolder $(PROJECT_NAME)

$(PROJECT_NAME): $(PROJECT_NAME).o
	@ echo 'Building target using GCC linker: $<'
	gcc -m32 ./objects/$(PROJECT_NAME).o -o $(PROJECT_NAME)
	@ echo ' '

$(PROJECT_NAME).o: ./src/$(PROJECT_NAME).asm                          
	@ echo 'Mounting target using nasm assembler: $<'
	nasm -f elf32 ./src/$(PROJECT_NAME).asm -o ./objects/$(PROJECT_NAME).o
	@ echo ' '

objFolder:
	@ mkdir -p objects

clean:
	@ rm -rf ./objects/*.o
	@ rmdir objects

.PHONY: all clean
