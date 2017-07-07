# Makefile para jkl_tools_check.20120917
# Crea "jklc" a partir de "jkl.l" y "jkl.y"
# (c) JosuKa Díaz Labrador 2012
LEX = flex
YACC = bison
YFLAGS = -dvt
objects = jkl.lex.o jkl.tab.o

jklc: $(objects)
	$(CC) -o $@ $(LDFLAGS) $^

jkl.lex.c: jkl.l jkl.tab.c
	$(LEX) $(LFLAGS) -o $@ $<

jkl.tab.c: jkl2.y
	$(YACC) $(YFLAGS) -o $@ $<

clean:
	$(RM) *.o scan.c
