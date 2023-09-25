#!/bin/bash -l
#SBATCH -A snic2022-3-25
#SBATCH -J SEQ_1
#SBATCH -t 00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=2
#SBATCH -p main
#SBATCH --output "seq_1.out"
#SBATCH --error "seq_1.err"
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-type=fail         # send email if job fails
#SBATCH --mail-user=polsm@kth.se

ml PrgEnv-gnu
make energy_storms_seq

echo "MODULES LOADED! and energy_storms_seq.c COMPILED! \n"


echo "******START ******* srun -n 4 ****************** \n"
./energy_storms_seq 35 test_files/test_01_a35_p5_w3
./energy_storms_seq 30000 test_files/test_02_a30k_p20k_w1
./energy_storms_seq 100000000 test_files/test_08_a100M_p1_w1
