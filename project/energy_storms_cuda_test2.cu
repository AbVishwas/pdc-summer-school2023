/*
 * Simplified simulation of high-energy particle storms
 *
 * Parallel computing (Degree in Computer Engineering)
 * 2017/2018
 *
 * Version: 2.0
 *
 * Code prepared to be used with the Tablon on-line judge.
 * The current Parallel Computing course includes contests using:
 * OpenMP, MPI, and CUDA.
 *
 * (c) 2018 Arturo Gonzalez-Escribano, Eduardo Rodriguez-Gutiez
 * Grupo Trasgo, Universidad de Valladolid (Spain)
 *
 * This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
 * https://creativecommons.org/licenses/by-sa/4.0/
 */
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<limits.h>
#include<sys/time.h>

/* Headers for the CUDA assignment versions */
#include<cuda.h>

#define TPB 32 // threads per block in x direction (columns)
#define RAD 1 // radius for ghost cells

/*
 * Macros to show errors when calling a CUDA library function,
 * or after launching a kernel
 */
#define CHECK_CUDA_CALL( a )	{ \
	cudaError_t ok = a; \
	if ( ok != cudaSuccess ) \
		fprintf(stderr, "-- Error CUDA call in line %d: %s\n", __LINE__, cudaGetErrorString( ok ) ); \
	}
#define CHECK_CUDA_LAST()	{ \
	cudaError_t ok = cudaGetLastError(); \
	if ( ok != cudaSuccess ) \
		fprintf(stderr, "-- Error CUDA last in line %d: %s\n", __LINE__, cudaGetErrorString( ok ) ); \
	}


/* Use fopen function in local tests. The Tablon online judge software 
   substitutes it by a different function to run in its sandbox */
#ifdef CP_TABLON
#include "cputilstablon.h"
#else
#define    cp_open_file(name) fopen(name,"r")
#endif

/* Function to get wall time */
double cp_Wtime(){
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + 1.0e-6 * tv.tv_usec;
}


#define THRESHOLD    0.001f

/* Structure used to store data for one storm of particles */
typedef struct {
    int size;    // Number of particles
    int *posval; // Positions and values
} Storm;

/* THIS FUNCTION CAN BE MODIFIED */
/* Function to update a single position of the layer */
/* This function returns 0 if the energy is lower than the threshold */
__device__ float update(int cp, int layer_size, int imp_pos, float energy) {
    /* 1. Compute the absolute value of the distance between the
        impact position and the k-th position of the layer */
    int distance = imp_pos - cp;
    if ( distance < 0 ) distance = - distance;

    /* 2. Impact cell has a distance value of 1 */
    distance = distance + 1;

    /* 3. Square root of the distance */
    /* NOTE: Real world atenuation typically depends on the square of the distance.
       We use here a tailored equation that affects a much wider range of cells */
    float atenuacion = sqrtf( (float)distance );

    /* 4. Compute attenuated energy */
    float energy_k = energy / layer_size / atenuacion;

    /* 5. If lower than the threshold do not take the energy into account (equivalent to
     * doing the layer[k] += 0 in the serial code) */
    if ( energy_k >= THRESHOLD / layer_size || energy_k <= -THRESHOLD / layer_size ) {
        return energy_k;
    } else {
        return 0.0f;
    }
}

/* Bombardment loop*/
__global__ void bombardment(int storm_size, int layer_size, float *layer_d, int *posval_d) {
  int cp = blockIdx.x * blockDim.x + threadIdx.x;

  if ( cp < layer_size ) {

    float energy;
    int imp_pos;

    for (int j=0; j < storm_size; j++) {

      energy = ((float)posval_d[2*j + 1]) * 1000.0f;
      imp_pos = posval_d[2*j];
      layer_d[cp] += update(cp, layer_size, imp_pos, energy);

    }
  }
}

/* Relaxation loop */
__global__ void relaxation(int layer_size, float *layer_d) {

  int i = blockIdx.x * blockDim.x + threadIdx.x;

  __shared__ float sm_layer[TPB + 2*RAD];

  if (i < layer_size) { // i goes from 0 to 34

    // threadIdx from 0 to 34
    int s_idx = threadIdx.x + RAD; // from 1 to 35

    // Regular cells
    sm_layer[s_idx] = layer_d[i];

    //Halo cells
    if (threadIdx.x < RAD) {
      sm_layer[s_idx - RAD] = layer_d[i - RAD];
      sm_layer[s_idx + blockDim.x] = layer_d[i + blockDim.x];
    }

    __syncthreads();

    if ( i != 0 && i != layer_size - 1)
      layer_d[i] = (sm_layer[s_idx-1] + sm_layer[s_idx] + sm_layer[s_idx+1])/3;
  }
}

/* ANCILLARY FUNCTIONS: These are not called from the code section which is measured, leave untouched */
/* DEBUG function: Prints the layer status */
void debug_print(int layer_size, float *layer, int *positions, float *maximum, int num_storms ) {
    int i,k;
    /* Only print for array size up to 35 (change it for bigger sizes if needed) */
    if ( layer_size <= 35 ) {
        /* Traverse layer */
        for( k=0; k<layer_size; k++ ) {
            /* Print the energy value of the current cell */
            printf("%10.4f |", layer[k] );

            /* Compute the number of characters. 
               This number is normalized, the maximum level is depicted with 60 characters */
            int ticks = (int)( 60 * layer[k] / maximum[num_storms-1] );

            /* Print all characters except the last one */
            for (i=0; i<ticks-1; i++ ) printf("o");

            /* If the cell is a local maximum print a special trailing character */
            if ( k>0 && k<layer_size-1 && layer[k] > layer[k-1] && layer[k] > layer[k+1] )
                printf("x");
            else
                printf("o");

            /* If the cell is the maximum of any storm, print the storm mark */
            for (i=0; i<num_storms; i++) 
                if ( positions[i] == k ) printf(" M%d", i );

            /* Line feed */
            printf("\n");
        }
    }
}

/*
 * Function: Read data of particle storms from a file
 */
Storm read_storm_file( char *fname ) {
    FILE *fstorm = cp_open_file( fname );
    if ( fstorm == NULL ) {
        fprintf(stderr,"Error: Opening storm file %s\n", fname );
        exit( EXIT_FAILURE );
    }

    Storm storm;    
    int ok = fscanf(fstorm, "%d", &(storm.size) );
    if ( ok != 1 ) {
        fprintf(stderr,"Error: Reading size of storm file %s\n", fname );
        exit( EXIT_FAILURE );
    }

    storm.posval = (int *)malloc( sizeof(int) * storm.size * 2 );
    if ( storm.posval == NULL ) {
        fprintf(stderr,"Error: Allocating memory for storm file %s, with size %d\n", fname, storm.size );
        exit( EXIT_FAILURE );
    }
    
    int elem;
    for ( elem=0; elem<storm.size; elem++ ) {
        ok = fscanf(fstorm, "%d %d\n", 
                    &(storm.posval[elem*2]),
                    &(storm.posval[elem*2+1]) );
        if ( ok != 2 ) {
            fprintf(stderr,"Error: Reading element %d in storm file %s\n", elem, fname );
            exit( EXIT_FAILURE );
        }
    }
    fclose( fstorm );

    return storm;
}

/*
 * MAIN PROGRAM
 */
int main(int argc, char *argv[]) {

    int i,k;

    /* 1.1. Read arguments */
    if (argc<3) {
        fprintf(stderr,"Usage: %s <size> <storm_1_file> [ <storm_i_file> ] ... \n", argv[0] );
        exit( EXIT_FAILURE );
    }

    int layer_size = atoi( argv[1] );
    int num_storms = argc-2;
    Storm storms[ num_storms ];

    /* 1.2. Read storms information */
    for(i=2; i<argc; i++ )
        storms[i-2] = read_storm_file( argv[i] );

    /* 1.3. Intialize maximum levels to zero */
    float maximum[ num_storms ];
    int positions[ num_storms ];
    for (i=0; i<num_storms; i++) {
        maximum[i] = 0.0f;
        positions[i] = 0;
    }

    /* 2. Begin time measurement */
	CHECK_CUDA_CALL( cudaSetDevice(0) );
	CHECK_CUDA_CALL( cudaDeviceSynchronize() );
    double ttotal = cp_Wtime();

    /* START: Do NOT optimize/parallelize the code of the main program above this point */

    /* 3. Allocate memory for the layer and initialize to zero */
    float *layer = (float *)malloc( sizeof(float) * layer_size );
    if ( layer == NULL) {
        fprintf(stderr,"Error: Allocating the layer memory\n");
        exit( EXIT_FAILURE );
    }
    for( k=0; k<layer_size; k++ ) layer[k] = 0.0f;

    /******************************************************/
    /*                       CUDA                         */
    /******************************************************/
    /* Preliminary definitions for grid/block dimensions */
    dim3 blockDim(TPB);
    dim3 gridDim(ceil(((float)layer_size) / ((float)blockDim.x)));

    float *layer_d;
    int *posval_d;

    // Allocate and copy the cells
    cudaMalloc((void **)&layer_d, layer_size*sizeof(float));
    cudaMemcpy(layer_d, layer, layer_size*sizeof(float), cudaMemcpyHostToDevice);

    /* 4. Storms simulation */
    for(int i=0; i<num_storms; i++) {

      // Allocate and copy the posval array onto the device
      cudaMalloc((void **)&posval_d        , 2 * storms[i].size * sizeof(int));
      cudaMemcpy(posval_d, storms[i].posval, 2 * storms[i].size * sizeof(int), cudaMemcpyHostToDevice);

      /* 4.1. Add impacts energies to layer cells */
      bombardment<<<gridDim, blockDim>>>(storms[i].size, layer_size, layer_d, posval_d);

      /* 4.2 */
      relaxation<<<gridDim, blockDim>>>(layer_size, layer_d);

      // Bring the layer array back to the host
      cudaMemcpy(layer, layer_d, layer_size * sizeof(float), cudaMemcpyDeviceToHost);

      /* 4.3. Locate the maximum value in the layer, and its position */
      for( k=1; k<layer_size-1; k++ ) {
            /* Check it only if it is a local maximum */
            if ( layer[k] > layer[k-1] && layer[k] > layer[k+1] ) {
                if ( layer[k] > maximum[i] ) {
                  maximum[i] = layer[k];
                  positions[i] = k;
                }
            }
        }

      cudaFree(posval_d);

    }

    cudaFree(layer_d);

    /* END: Do NOT optimize/parallelize the code below this point */

    /* 5. End time measurement */
	CHECK_CUDA_CALL( cudaDeviceSynchronize() );
    ttotal = cp_Wtime() - ttotal;

    /* 6. DEBUG: Plot the result (only for layers up to 35 points) */
    #ifdef DEBUG
    debug_print( layer_size, layer, positions, maximum, num_storms );
    #endif

    /* 7. Results output, used by the Tablon online judge software */
    printf("\n");
    /* 7.1. Total computation time */
    printf("Time: %lf\n", ttotal );
    /* 7.2. Print the maximum levels */
    printf("Result:");
    for (i=0; i<num_storms; i++)
        printf(" %d %f", positions[i], maximum[i] );
    printf("\n");

    /* 8. Free resources */    
    for( i=0; i<argc-2; i++ )
        free( storms[i].posval );

    /* 9. Program ended successfully */
    return 0;
}

