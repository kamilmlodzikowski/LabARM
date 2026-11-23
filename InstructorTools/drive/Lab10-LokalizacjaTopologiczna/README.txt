Lab 10 - Lokalizacja topologiczna: dane do zajęć (Autonomiczne Roboty Mobilne)

Zawartość:
  bags/fr3_long_office_household/ - sekwencja freiburg3_long_office_household ze zbioru TUM RGB-D (MCAP), CC BY 4.0
  bags/SHA256SUMS     - sumy kontrolne
  arm_10_load_datasets.sh - skrypt dodający dane do obrazu arm/lab10

Jak skorzystać (zamiast pobierania danych podczas budowania obrazu):

1. Zbudować obraz bez danych (instrukcja: https://github.com/kamilmlodzikowski/LabARM/blob/main/Lab10-LokalizacjaTopologiczna/README.md):
     wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/Dockerfile -O Dockerfile
     wget https://raw.githubusercontent.com/kamilmlodzikowski/LabARM/main/Lab10-LokalizacjaTopologiczna/arm_10_build.sh -O arm_10_build.sh
     bash ./arm_10_build.sh --no-datasets

2. Podłączyć dysk i uruchomić skrypt bezpośrednio z dysku (podając ścieżkę, pod którą dysk jest zamontowany):
     bash /media/<użytkownik>/<dysk>/Lab10-LokalizacjaTopologiczna/arm_10_load_datasets.sh
   Skrypt sprawdza sumy kontrolne i dodaje dane do obrazu arm/lab10 (~2 GB). Po zakończeniu dysk można odłączyć.

3. Utworzyć kontener jak zwykle: bash ./arm_10_run_cpu.sh (lub arm_10_run_gpu_nvidia.sh).
   Dane będą w katalogu /arm_ws/bags.
