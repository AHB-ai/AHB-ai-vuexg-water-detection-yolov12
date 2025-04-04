#!/bin/bash
#SBATCH --job-name='vuexg-water-leak-detection-yolov12'
#SBATCH --chdir=/maahr/home/proddev/0_products/vuexg/water-leak-detection-yolov12/streamlit
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --nodelist=g03
#SBATCH --gpus-per-node=3
#SBATCH --cpus-per-task=10
#SBATCH --time=1-00:00
#SBATCH --ntasks-per-node=1
#SBATCH --mem=200GB
#SBATCH --output=/maahr/home/proddev/0_products/vuexg/water-leak-detection-yolov12/streamlit/%J.out
#SBATCH --error=/maahr/home/proddev/0_products/vuexg/water-leak-detection-yolov12/streamlit/%J.err

source ~/.bashrc
conda activate yolov12

# pip install -r requirements.txt
cd /maahr/home/proddev/0_products/vuexg/water-leak-detection-yolov12/streamlit

streamlit run app.py



