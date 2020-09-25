Alyxandra Spikerman
High Performance Computing: Homework 5.2

Q2.cu

This program takes in a number of values (N) and a number of classes (M) and creates a histogram with M classes with a total number of N values. It outputs the count for each class in ascending order. The values for N numbers are random between 1 and 1000.

This version uses CUDA to calculate the counts by dividing the workload into chunks. Each thread just adds a value from their chunk to the right class. Since CUDA does not have a built in reduction API, each thread gets their own index to add their values to. Then, I sum them all for each class at the end.


--HOW TO COMPILE--
nvcc -arch=sm_35 -O3 Q2.cu -o Q2

OR

make Q2

--HOW TO RUN--

make run_Q2

OR

./Q2 16000 16
