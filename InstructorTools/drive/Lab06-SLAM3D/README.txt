Lab 06 - SLAM 3D: dane do zajęć (Autonomiczne Roboty Mobilne)

Zawartość:
  bags/hdl_400/       - bag hdl_400 (MCAP)
  bags/kitti/         - 200 skanów z sekwencji 00 KITTI
  bags/kitti_gt.tum   - ground truth KITTI w formacie TUM
  bags/SHA256SUMS     - sumy kontrolne
  arm_06_load_datasets.sh - skrypt dodający dane do obrazu arm/lab06

Jak skorzystać (zamiast pobierania danych podczas budowania obrazu):

1. Zbudować obraz bez danych (instrukcja: https://github.com/kamilmlodzikowski/LabARM/blob/main/Lab06-SLAM3D/README.md):
     wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/Dockerfile_no_datasets -O Dockerfile_no_datasets
     wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab06-SLAM3D/arm_06_build_no_datasets.sh
     bash ./arm_06_build_no_datasets.sh 4

2. Podłączyć dysk i uruchomić skrypt bezpośrednio z dysku (podając ścieżkę, pod którą dysk jest zamontowany):
     bash /media/<użytkownik>/<dysk>/Lab06-SLAM3D/arm_06_load_datasets.sh
   Skrypt sprawdza sumy kontrolne i dodaje dane do obrazu arm/lab06 (~3 GB). Po zakończeniu dysk można odłączyć.

3. Utworzyć kontener jak zwykle: bash ./arm_06_run_cpu.sh (lub arm_06_run_gpu_nvidia.sh).
   Dane będą w katalogu /arm_ws/bags.
