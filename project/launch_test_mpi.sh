#!/bin/bash -l
#SBATCH -A snic2022-3-25
#SBATCH -J MPI_2
#SBATCH -t 00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=2
#SBATCH -p main
#SBATCH --output "mpi_final.out"
#SBATCH --error "mpi_final.err"
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-type=fail         # send email if job fails
#SBATCH --mail-user=polsm@kth.se

ml PrgEnv-gnu
make energy_storms_mpi

echo "MODULES LOADED! and energy_storms_mpi.c _mpiILED! \n"


echo "****** START ******* srun -n 4 ****************** \n"
srun -n 2 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 2 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 2 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 2 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1


echo "****** START ******* srun -n 8 ****************** \n"
srun -n 4 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 4 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 4 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 4 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1

echo "****** START ******* srun -n 16 ****************** \n"
srun -n 8 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 8 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 8 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 8 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1

echo "****** START ******* srun -n 32 ****************** \n"
srun -n 16 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 16 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 16 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 16 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1

echo "****** START ******* srun -n 64 ****************** \n"
srun -n 32 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 32 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 32 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 32 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1

echo "****** START ******* srun -n 128 ****************** \n"
srun -n 64 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 64 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 64 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 64 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1

echo "****** START ******* srun -n 256 ****************** \n"
srun -n 128 ./energy_storms_mpi 35 test_files/test_01_a35_p5_w3
srun -n 128 ./energy_storms_mpi 30000 test_files/test_02_a30k_p20k_w1
srun -n 128 ./energy_storms_mpi 1000000 test_files/test_07_a1M_p5k_w1
srun -n 128 ./energy_storms_mpi 100000000 test_files/test_08_a100M_p1_w1