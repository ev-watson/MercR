#!/bin/bash
#SBATCH --job-name=build_graph
#SBATCH --account=csd969
#SBATCH --partition=compute
#SBATCH --constraint="lustre"
#SBATCH --array=0,1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=06:00:00
#SBATCH --output=script_logs/%x.o%j_%a.txt
#SBATCH --error=script_logs/%x.e%j_%a.txt
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=etwatson@ucsd.edu

module purge
module load slurm
module load cpu
module load gcc/10.2.0

echo "Activating virtual environment..."
source .venv/bin/activate || { echo "Failed to activate virtual environment"; exit 1; }

echo "Starting Python script..."
srun --unbuffered python -c "from utils import build_graph_snapshots; build_graph_snapshots('horizons.csv')" || { echo "Python script failed"; exit 1; }

echo "Job completed."
