Lab 07/08 - ORB-SLAM3: dane do zajęć (Autonomiczne Roboty Mobilne)

Zawartość:
  bags/room4/         - sekwencja room4 ze zbioru TUM-VI (MCAP), CC BY 4.0
  bags/put_car/       - przejazd samochodu wokół kampusu Piotrowo (MCAP)
  bags/SHA256SUMS     - sumy kontrolne
  arm_07_load_datasets.sh - skrypt dodający dane do obrazu arm/lab07

Jak skorzystać (zamiast pobierania danych podczas budowania obrazu):

1. Zbudować obraz bez danych (instrukcja: https://github.com/kamilmlodzikowski/LabARM/blob/main/Lab07-ORB-SLAM/README.md):
     wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/Dockerfile -O Dockerfile
     wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab07-ORB-SLAM/arm_07_build.sh -O arm_07_build.sh
     bash ./arm_07_build.sh --no-datasets

2. Podłączyć dysk i uruchomić skrypt bezpośrednio z dysku (podając ścieżkę, pod którą dysk jest zamontowany):
     bash /media/<użytkownik>/<dysk>/Lab07-ORB-SLAM/arm_07_load_datasets.sh
   Skrypt sprawdza sumy kontrolne i dodaje dane do obrazu arm/lab07 (~5 GB). Po zakończeniu dysk można odłączyć.

3. Utworzyć kontener jak zwykle: bash ./arm_07_run_cpu.sh (lub arm_07_run_gpu_nvidia.sh).
   Dane będą w katalogu /arm_ws/bags.
