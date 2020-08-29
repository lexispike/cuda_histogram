/*
 * Alyxandra Spikerman
 * High Perfomance Computing
 * Homework 5 - Question 2
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

// CUDA kernel
__global__ void getCount(int* values, int* histogram, int N, int CLASSES) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    // we're working with a data range of 1000, so to get the class size, we need to divide the range by
    // the number of classes
    double CLASS_SIZE = 1000 / (double)CLASSES;

    for (int i = id; i < N; i += stride) {
        atomicAdd(&histogram[(int)ceil(values[i] / CLASS_SIZE) - 1], 1); // atomically add a value to the right class
    }
}

int main(int argc, char* argv[] ) {
    int N, CLASSES;
    if (argc == 3) {
        N = atoi(argv[1]);
        CLASSES = atoi(argv[2]);
        printf("N = %d\nClasses= %d\n", N, CLASSES);
    } else {
        printf("Error: must input 2 arguments, <N> <# of classes>\n");
        return 1;
    }

    // how to do cudaMalloc, cudaMemcpy supplied by provided Oak Ridge National Labs code

    size_t total_bytes = CLASSES * sizeof(int);

    // create the histogram
    int* h_histogram = (int*)malloc(total_bytes);
    int* d_histogram;
    cudaMalloc(&d_histogram, total_bytes);

    for (int i = 0; i < CLASSES; i++){
        h_histogram[i] = 0; // initalize the host histogram values
    }

    size_t N_bytes = N * sizeof(int);
    srand(150);
    int* h_values = (int*)malloc(N_bytes);
    int* d_values;
    cudaMalloc(&d_values, N_bytes);
    for (int i = 0; i < N; i++) {
        h_values[i] = (rand() % 1000) + 1; // calculate the values
    }

    cudaMemcpy(d_histogram, h_histogram, total_bytes, cudaMemcpyHostToDevice); // copy histogram to device
    cudaMemcpy(d_values, h_values, N_bytes, cudaMemcpyHostToDevice); // copy values to device
    time_t begin = time(NULL);
    printf("\nStart kernel\n\n");
    getCount<<< N / 128, 128 >>>(d_values, d_histogram, N, CLASSES); // Execute the kernel
    cudaDeviceSynchronize(); // wait for everything to finish before accessing
    time_t end = time(NULL);

    cudaMemcpy(h_histogram, d_histogram, total_bytes, cudaMemcpyDeviceToHost); // Copy histogram to host

    printf("Total histogram values for %d classes\n", CLASSES);
    for (int i = 0; i < CLASSES; i++) {
        printf("Class %d: %d \n", i, h_histogram[i]);
    }

    printf("Parallel Time = %f\n", end-begin);

    // free allocated memory
    cudaFree(d_values);
    cudaFree(d_histogram);
    free(h_values);
    free(h_histogram);
    return 0;
}
