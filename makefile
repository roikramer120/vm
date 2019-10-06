OBJS = $(patsubst src/%.c, obj/%.o, $(wildcard src/*.c))
TESTS = $(patsubst test/%.c, bin/%, $(wildcard test/*.c))
LIB = lib/libvm.so
LIB_NAME = vm
COMPILER = BytecodeCompiler.jar
COMPILER_FOLDER = bytecode_compiler
COMPILER_SRCS = $(wildcard $(COMPILER_FOLDER)/src/*.java)
COMPILER_CLASS_FILES = $(patsubst $(COMPILER_FOLDER)/src/%.java, $(COMPILER_FOLDER)/class/%.class, $(COMPILER_SRCS))
COMPILER_CLASSES = $(patsubst $(COMPILER_FOLDER)/src/%.java, $(COMPILER_FOLDER)/class/%, $(COMPILER_SRCS))

$(LIB): $(OBJS)
	gcc -shared -o $@ $^

.PHONY: build_test
build_test: $(TESTS) 

.PHONY: compiler
compiler: $(COMPILER_FOLDER)/$(COMPILER)
	@echo "Running compiler..."
	@java -jar $(COMPILER_FOLDER)/$(COMPILER)
	
bin/%: test/%.c $(LIB)
	gcc -o $@ $< -Iinclude/ -Llib/ -l$(LIB_NAME)

obj/%.o: src/%.c
	gcc -fPIC -c -o $@ $< -I include/

$(COMPILER_FOLDER)/$(COMPILER): $(COMPILER_CLASS_FILES)
	@echo "Building compiler"
	@echo "Main-Class: BytecodeCompiler" > $(COMPILER_FOLDER)/manifest.txt
	@echo "Class-Path: class/" >> $(COMPILER_FOLDER)/manifest.txt
	@jar -cvfm $(COMPILER_FOLDER)/$(COMPILER) $(COMPILER_FOLDER)/manifest.txt $(COMPILER_FOLDER)/class/*.class 1>/dev/null

$(COMPILER_FOLDER)/class/%.class: $(COMPILER_FOLDER)/src/%.java
	@javac -d $(COMPILER_FOLDER)/class -classpath $(COMPILER_FOLDER)/src $<

.PHONY: clean
clean:
	@echo "cleaning..."
	@rm $(OBJS) $(LIB) $(TESTS) $(COMPILER_FOLDER)/$(COMPILER) $(COMPILER_CLASS_FILES) $(COMPILER_FOLDER)/manifest.txt 2>/dev/null || true