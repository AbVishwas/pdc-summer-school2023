#!/usr/bin/env bash  
#SBATCH -A NAISS2023-5-102 -p alvis # project name, cluster name
#SBATCH -N 1 --gpus-per-node=V100:2      #A40:4 #A100fat:4    #V100:2  A100fat:4  A100:4  # number of nodes, gpu name   
#SBATCH -t 0-01:00:00 # time


module load AlphaFold/2.2.2-foss-2021a-CUDA-11.3.1
module load cuDNN/8.2.1.32-CUDA-11.3.1


# nvcc  -O3 energy_storms_cuda_test1.cu -lm -o energy_storms_cuda_test1

echo "******START ******* sequential    ****************** \n"
./energy_storms_seq 35 test_files/test_01_a35_p5_w3
./energy_storms_seq 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_seq 1000000 test_files/test_07_a1M_p5k_w1                #test_08_a100M_p1_w2

echo "******START ******* cuda TPB 4 ****************** \n"
./energy_storms_cuda_test2_4 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_4 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_4 1000000 test_files/test_07_a1M_p5k_w1

echo "******START ******* cuda TPB 8  ****************** \n"
./energy_storms_cuda_test2_8 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_8 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_8 1000000 test_files/test_07_a1M_p5k_w1

echo "******START ******* cuda TPB 16 ****************** \n"
./energy_storms_cuda_test2_16 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_16 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_16 1000000 test_files/test_07_a1M_p5k_w1



echo "******START ******* cuda TPB 32 ****************** \n"
./energy_storms_cuda_test2_32 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_32 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_32 1000000 test_files/test_07_a1M_p5k_w1


echo "******START ******* cuda TPB 64 ****************** \n"
./energy_storms_cuda_test2_64 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_64 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_64 1000000 test_files/test_07_a1M_p5k_w1


echo "******START ******* cuda TPB 64 ****************** \n"
./energy_storms_cuda_test2_64 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_64 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_64 1000000 test_files/test_07_a1M_p5k_w1

echo "******START ******* cuda TPB 128 ****************** \n"
./energy_storms_cuda_test2_128 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_128 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_128 1000000 test_files/test_07_a1M_p5k_w1


echo "******START ******* cuda TPB 256 ****************** \n"
./energy_storms_cuda_test2_256 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_256 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_256 1000000 test_files/test_07_a1M_p5k_w1

echo "******START ******* cuda TPB 512 ****************** \n"
./energy_storms_cuda_test2_512 35 test_files/test_01_a35_p5_w3
./energy_storms_cuda_test2_512 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_cuda_test2_512 1000000 test_files/test_07_a1M_p5k_w1