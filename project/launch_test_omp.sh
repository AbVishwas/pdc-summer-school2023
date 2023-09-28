#!/bin/bash -l
#SBATCH -A snic2022-3-25
#SBATCH -J OMP_2
#SBATCH -t 00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=2
#SBATCH -p main
#SBATCH --output "omp_final.out"
#SBATCH --error "omp_final.err"
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-type=fail         # send email if job fails
#SBATCH --mail-user=polsm@kth.se

ml PrgEnv-gnu
make energy_storms_omp

echo "MODULES LOADED! and energy_storms_omp.c COMPILED! \n"


echo "******START ******* OMP_NUM_THREADS=4 ****************** \n"
export OMP_NUM_THREADS=4
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1

echo "******START ******* OMP_NUM_THREADS=8 ****************** \n"
export OMP_NUM_THREADS=8
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1

echo "******START ******* OMP_NUM_THREADS=16 ****************** \n"
export OMP_NUM_THREADS=16
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1


echo "******START ******* OMP_NUM_THREADS=32 ****************** \n"
export OMP_NUM_THREADS=32
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1

echo "******START ******* OMP_NUM_THREADS=64 ****************** \n"
export OMP_NUM_THREADS=64
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1


echo "******START ******* OMP_NUM_THREADS=128 ****************** \n"
export OMP_NUM_THREADS=128
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1


echo "******START ******* OMP_NUM_THREADS=256 ****************** \n"
export OMP_NUM_THREADS=256
./energy_storms_omp 35 test_files/test_01_a35_p5_w3
./energy_storms_omp 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_omp 1000000 test_files/test_07_a1M_p5k_w1
./energy_storms_omp 100000000 test_files/test_08_a100M_p1_w1





