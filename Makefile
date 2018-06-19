all:
	make -C src all
	mv src/run run

clean:
	make -C src clean

clean-result:
	make -C src clean-result

clean-all:
	make -C src clean
	make -C src clean-result