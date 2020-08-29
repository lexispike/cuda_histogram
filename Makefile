# compile Q2.cu
Q2: Q2.cu
	nvcc -arch=sm_35 -O3 Q2.cu -o Q2

# run Q2
run_Q2: Q2
	./Q2 16000 16

# clean the directory
clean:
	rm -f Q2
