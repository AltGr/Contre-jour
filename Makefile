all: contrejour.exe

contrejour.exe: jpeg.opp contrejour.opa
	opa $(OPAOPT) $^

jpeg.opp: jpeg.ml
	opa-plugin-builder $^ -o $@

clean:
	rm -rf _build _tracks
	rm -rf jpeg.opp
	rm contrejour.exe
