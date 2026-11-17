# Instructor tools
Scripts for preparing the labs. Students do not need them.

## Dataset drive
Labs 06 and 07 can be built without downloading the datasets (`arm_06_build_no_datasets.sh`, `arm_07_build.sh --no-datasets`); the students then add them to the image from a drive passed around the lab with `arm_NN_load_datasets.sh`. The drive has one directory per lab:
```
Lab06-SLAM3D/
    README.txt                 instructions for the students (Polish), from drive/Lab06-SLAM3D/README.txt
    arm_06_load_datasets.sh    the load script, from Lab06-SLAM3D/
    bags/                      the datasets, as in /arm_ws/bags of the image
    bags/SHA256SUMS            checksums, checked by the load script
Lab07-ORB-SLAM/
    ...
```

### Making the drive
```shell
git clone https://github.com/kamilmlodzikowski/LabARM.git
cd LabARM/InstructorTools
bash make_dataset_drive.sh /media/<user>/<drive>
```
For each lab the script takes the datasets from the `arm/labNN` image: if the image already has them it is used as it is, otherwise it is built from the lab's `Dockerfile` (with the datasets, so it takes as long as a normal build, ~17 min for Lab 07). This way the drive has exactly what the Dockerfile downloads and converts, and the load script copies it back to the same place. Lab directories that already exist on the drive are not overwritten (the script stops), so remove the old ones first.

Options (`bash make_dataset_drive.sh --help`):
- lab numbers after the target directory make only some labs, e.g. `bash make_dataset_drive.sh /media/<user>/<drive> 07`,
- `-j N` sets the number of parallel compilers when an image is built (default: half of the CPUs, at most available memory / 2.5 GB),
- `--rebuild` builds the images from the current Dockerfiles even if images with the datasets exist (use it after changing the Dockerfiles; the docker cache keeps the downloaded datasets),
- `--no-cache` also downloads everything again (e.g. when a dataset changed under the same URL).

Space needed: ~8.5 GB on the drive (Lab 06 ~3 GB, Lab 07 ~5.2 GB; the largest file has ~2.9 GB, so FAT32 still works, but ext4 or exFAT is safer) and, when the images are built, ~10 GB (Lab 06) and ~24 GB (Lab 07) for the images.

### Several drives
Make the directories once on the local disk, then copy them to each drive and check the copy after reconnecting the drive (right after copying, the files would be read back from memory):
```shell
bash make_dataset_drive.sh ~/arm_drive
rsync -a ~/arm_drive/ /media/<user>/<drive>/
cd /media/<user>/<drive>/Lab07-ORB-SLAM/bags && sha256sum -c SHA256SUMS
```

### Adding a lab
1. Download the datasets to `/arm_ws/bags` in the lab's `Dockerfile` (by default) and make a variant of the build without them (like `ARG datasets` in `Lab07-ORB-SLAM/Dockerfile`).
2. Write `arm_NN_load_datasets.sh` in the lab directory (copy `Lab07-ORB-SLAM/arm_07_load_datasets.sh` and change the image, the file list and the `COPY` lines).
3. Add the lab to `LAB_DIR` and `LAB_CHECK` at the top of `make_dataset_drive.sh` and its README.txt for the students to `drive/<lab directory>/`.
