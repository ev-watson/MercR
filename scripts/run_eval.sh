#!/bin/bash
#SBATCH --job-name=eval
#SBATCH --account=csd969
#SBATCH --partition=gpu-debug
#SBATCH --constraint="lustre"
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=93G
#SBATCH --gpus=2
#SBATCH --time=00:30:00
#SBATCH --output=script_logs/%x.o%j.txt
#SBATCH --error=script_logs/%x.e%j.txt
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE,TIME_LIMIT_90
#SBATCH --mail-user=etwatson@ucsd.edu

module purge
module load slurm
module load gpu
module load gcc/10.2.0
module load cuda/11.2.2
module load cudnn/8.1.1.33-11.2

echo "Activating virtual environment..."
source .venv/bin/activate || { echo "Failed to activate virtual environment"; exit 1; }

EVAL_NTRIALS=${EVAL_NTRIALS:-921600}
EVAL_CKPT=${EVAL_CKPT:-tlogs/checkpoints/mpnn_final.ckpt}
EVAL_BATCH_SIZES=${EVAL_BATCH_SIZES:-"16 32 64 128 256 512"}

for batch_size in ${EVAL_BATCH_SIZES}; do
    echo "Evaluating ${EVAL_CKPT} with batch size ${batch_size} on ${EVAL_NTRIALS} trials"
    srun --unbuffered python eval.py -n "${EVAL_NTRIALS}" -b "${batch_size}" -c "${EVAL_CKPT}" -s data || {
        echo "Python eval failed for batch size ${batch_size}"
        exit 1
    }
done

echo "Job completed."
