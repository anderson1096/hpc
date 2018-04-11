#include <stdlib.h>
#include <cuda.h>
#include <stdio.h>



__host__
void fill_vector(float *V, int len){
  float aux = 5.0;
  for (int i = 0; i < len; i++) {
    V[i] = ((float)rand() / (float)(RAND_MAX)) * aux ;
  }
}

__host__
void print(float *V, int len){
  for (int i = 0; i < len; i++) {
    printf("%.2f ", V[i]);
  }
  printf("\n");
}

__global__
void MatrixKernel(float* d_M, float* d_R, int n){
  //calculate row index of element
  int i = threadIdx.x + blockDim.x * blockIdx.x;

  if (i < n) d_R[i] = 2 * d_M[i];
  return;
}


int main(){
  int n = 100;
  int size = n * sizeof(float);

  //CPU
  float *h_M = (float*)malloc(size);
  float *h_R = (float*)malloc(size);
  //GPU
  float *d_M, *d_R;
  cudaMalloc((void**)&d_M, size);
  cudaMalloc((void**)&d_R, size);

  //Fill Matrix
  fill_vector(h_M, size);

  //Copy from CPU to GPU
  cudaMemcpy(d_M, h_M, size, cudaMemcpyHostToDevice);

  //Dimension kernel
  dim3 dimGrid(ceil(n/10.0), 1, 1);
  dim3 dimBlock(10,1,1);
  MatrixKernel<<<dimGrid, dimBlock>>>(d_M, d_R, n);

  cudaMemcpy(h_R, d_R, size, cudaMemcpyDeviceToHost);
  print(h_R, n);


  cudaFree(d_M);
  cudaFree(d_R);
  free(h_M);
  free(h_R);
  
  return 0;
}
