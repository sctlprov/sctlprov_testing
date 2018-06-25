all:
	make -C src all
	mv src/run run

clean:
	make -C src clean
	rm -f run