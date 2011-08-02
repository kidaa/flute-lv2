BUNDLE = lv2-Flute.lv2
INSTALL_DIR = /usr/local/lib/lv2

$(BUNDLE): manifest.ttl flute.ttl Flute.so FluteGUI.so
	rm -rf $(BUNDLE)
	mkdir $(BUNDLE)
	cp $^ $(BUNDLE)

Flute.so: Flute.cpp gen/Flute.peg gen/FluteMeta.h gen/dsp.cpp
	g++ -shared -Wall -fPIC -DPIC Flute.cpp dsp.cpp `pkg-config --cflags --libs paq` -lm -I/usr/local/lib/faust/ -o Flute.so

FluteGUI.so: FluteGUI.cpp gen/Flute.peg gen/FluteMeta.h
	g++ -shared -Wall -fPIC -DPIC FluteGUI.cpp `pkg-config --cflags --libs paq` -o FluteGUI.so

demo: gen/Flute.peg gen/FluteMeta.h gen/dsp.cpp
	g++ -Wall demos/LongNote.cpp Flute.cpp dsp.cpp `pkg-config --cflags --libs paq` -lm -I/usr/local/lib/faust/ -lsndfile -o demo.out
	./demo.out

standalone: 
	faust -a alsa-gtk.cpp faust/flute.dsp     > gen/flute-alsa-gtk.cpp
	g++ -Wall gen/flute-alsa-gtk.cpp  `pkg-config --cflags --libs alsa` `pkg-config --cflags --libs gtk+-2.0` -lm -I/usr/local/lib/faust/ -o alsa-gtk

gen/dsp.cpp:
	faust -a minimal.cpp faust/flute.dsp > gen/dsp.cpp

gen/Flute.peg:
	lv2peg flute.ttl gen/Flute.peg

gen/FluteMeta.h:
	python portmeta.py

test: runner.cpp gen/Flute.peg gen/FluteMeta.h gen/dsp.cpp
	g++ -Wall runner.cpp -o runner.out
	./runner.out
	rm runner.cpp

runner.cpp: tests/ControlPortTest.cpp
	cxxtestgen.py -o $@ --error-printer $^

install: $(BUNDLE)
	mkdir -p $(INSTALL_DIR)
	rm -rf $(INSTALL_DIR)/$(BUNDLE)
	cp -R $(BUNDLE) $(INSTALL_DIR)

svg:
	faust -svg -sn faust/flute.dsp

clean:
	rm -rf $(BUNDLE) *.so *.out *.wav gen/* alsa-gtk 
