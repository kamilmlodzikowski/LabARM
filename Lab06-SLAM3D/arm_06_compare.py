#!/opt/pipx/venvs/evo/bin/python
"""Compares trajectories from Lab 06 experiments and writes a table and plots.

Each RESULT can be:
  - a ROS 2 bag recorded with `ros2 bag record` (e.g. /kiss/odometry from KISS-ICP),
  - a GLIM result directory (dump_path), traj_lidar.txt is used (odom_lidar.txt with --glim-odom),
  - a trajectory file in the TUM format.

With a reference (--gt or --ref), each result is aligned to it (Umeyama, SE(3)) and evaluated with:
  - APE: absolute position error (RMSE and max),
  - distance error: median relative error of the length of all segments of --delta meters,
  - rotation error: median rotation error over all segments of --delta meters.

Examples:
  arm_06_compare --gt /arm_ws/bags/kitti_gt.tum results/kiss_vox05 results/kiss_kitti results/glim_kitti
  arm_06_compare --ref results/glim_hdl400 results/glim_hdl400 results/glim_hdl400_k10
"""
import argparse
import csv
import os
import sys

import matplotlib
import numpy as np

from evo.core import metrics, sync
from evo.core.units import Unit
from evo.tools import file_interface
from rosbags.rosbag2 import Reader


def load(path, glim_odom):
    """Returns (name, method, trajectory) for a result path."""
    path = os.path.normpath(path)
    name = os.path.splitext(os.path.basename(path))[0]
    if os.path.isfile(os.path.join(path, "metadata.yaml")):
        with Reader(path) as reader:
            topics = [c.topic for c in reader.connections if c.msgtype == "nav_msgs/msg/Odometry"]
            if not topics:
                sys.exit(f"ERROR: no nav_msgs/Odometry topic in the bag {path}")
            topic = "/kiss/odometry" if "/kiss/odometry" in topics else topics[0]
            traj = file_interface.read_bag_trajectory(reader, topic)
        return name, "KISS-ICP" if topic.startswith("/kiss") else f"bag {topic}", traj
    for file in (["odom_lidar.txt"] if glim_odom else []) + ["traj_lidar.txt"]:
        if os.path.isfile(os.path.join(path, file)):
            traj = file_interface.read_tum_trajectory_file(os.path.join(path, file))
            return name, "GLIM odometry" if file == "odom_lidar.txt" else "GLIM", traj
    if os.path.isfile(path):
        return name, "TUM file", file_interface.read_tum_trajectory_file(path)
    sys.exit(f"ERROR: {path} is not a ROS 2 bag, a GLIM result directory or a TUM file")


def evaluate(ref, est, delta):
    """APE like `evo_ape tum ref est -a` and RPE like `evo_rpe tum ref est -a --delta <delta> --delta_unit m
    --all_pairs -r point_distance_error_ratio` (and `-r angle_deg`). The translation part of RPE is not used:
    it depends on the orientation of the reference frames, which for the KITTI ground truth differ from the
    lidar by ~1.5 deg and add ~0.3 m per 10 m to every result."""
    ref, est = sync.associate_trajectories(ref, est)
    est.align(ref, correct_scale=False)
    ape = metrics.APE(metrics.PoseRelation.translation_part)
    ape.process_data((ref, est))
    row = {"APE RMSE [m]": ape.get_statistic(metrics.StatisticsType.rmse),
           "APE max [m]": ape.get_statistic(metrics.StatisticsType.max)}
    for relation, key in ((metrics.PoseRelation.point_distance_error_ratio, f"distance error/{delta:g} m [%]"),
                          (metrics.PoseRelation.rotation_angle_deg, f"rotation error/{delta:g} m [deg]")):
        rpe = metrics.RPE(relation, delta=delta, delta_unit=Unit.meters, all_pairs=True)
        try:
            rpe.process_data((ref, est))
            row[key] = rpe.get_statistic(metrics.StatisticsType.median)
        except Exception:  # trajectory shorter than delta
            row[key] = float("nan")
    # APE along the distance travelled on the reference, for the plot
    distance = np.concatenate(([0.0], np.cumsum(np.linalg.norm(np.diff(ref.positions_xyz, axis=0), axis=1))))
    return row, est, distance, ape.error


def fmt(value):
    if isinstance(value, float):
        return "n/a" if np.isnan(value) else f"{value:.3f}"
    return str(value)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("results", nargs="+", help="ROS 2 bags, GLIM result directories or TUM files")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--gt", help="ground truth trajectory (TUM), e.g. /arm_ws/bags/kitti_gt.tum")
    group.add_argument("--ref", help="result used as the reference when there is no ground truth")
    parser.add_argument("--delta", type=float, default=10.0, help="RPE distance in meters (default: 10)")
    parser.add_argument("--glim-odom", action="store_true", help="use GLIM odometry (odom_lidar.txt) instead of traj_lidar.txt")
    parser.add_argument("--out", default="comparison", help="output directory (default: ./comparison)")
    parser.add_argument("--show", action="store_true", help="also show the plots")
    args = parser.parse_args()

    matplotlib.use("TkAgg" if args.show else "Agg")
    import matplotlib.pyplot as plt

    results = [load(path, args.glim_odom) for path in args.results]
    ref_name, ref_traj = None, None
    if args.gt:
        ref_name, _, ref_traj = load(args.gt, False)
    elif args.ref:
        ref_name, _, ref_traj = load(args.ref, args.glim_odom)
        ref_path = os.path.normpath(args.ref)
        results = [r for r, path in zip(results, args.results) if os.path.normpath(path) != ref_path]

    rows, curves = [], []
    for name, method, traj in results:
        row = {"result": name, "method": method, "poses": traj.num_poses,
               "path length [m]": traj.path_length}
        if ref_traj is not None:
            metrics_row, traj, distance, error = evaluate(ref_traj, traj, args.delta)
            row.update(metrics_row)
            curves.append((name, distance, error))
        else:
            row["end-start [m]"] = float(np.linalg.norm(traj.positions_xyz[-1] - traj.positions_xyz[0]))
        rows.append((row, traj))

    # TABLE
    columns = list(rows[0][0].keys())
    table = [columns] + [[fmt(row[c]) for c in columns] for row, _ in rows]
    widths = [max(len(line[i]) for line in table) for i in range(len(columns))]
    reference = f"ground truth {args.gt}" if args.gt else f"reference {args.ref} (not ground truth)" if args.ref else "none"
    print(f"Reference: {reference}")
    for i, line in enumerate(table):
        print("  ".join(cell.ljust(w) if j < 2 else cell.rjust(w) for j, (cell, w) in enumerate(zip(line, widths))))
        if i == 0:
            print("  ".join("-" * w for w in widths))
    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, "table.csv"), "w", newline="") as f:
        csv.writer(f).writerows(table)
    with open(os.path.join(args.out, "table.md"), "w") as f:
        f.write(f"Reference: {reference}\n\n")
        f.write("| " + " | ".join(columns) + " |\n|" + "|".join("---" for _ in columns) + "|\n")
        for line in table[1:]:
            f.write("| " + " | ".join(line) + " |\n")

    # PLOTS
    fig, ax = plt.subplots(figsize=(8, 8))
    if ref_traj is not None:
        ax.plot(ref_traj.positions_xyz[:, 0], ref_traj.positions_xyz[:, 1], "k--", label=f"{ref_name} (reference)")
    for row, traj in rows:
        ax.plot(traj.positions_xyz[:, 0], traj.positions_xyz[:, 1], label=row["result"])
    ax.set_xlabel("x [m]")
    ax.set_ylabel("y [m]")
    ax.set_title("Trajectories" + (" (aligned to the reference)" if ref_traj is not None else ""))
    ax.axis("equal")
    ax.grid(True)
    ax.legend()
    fig.savefig(os.path.join(args.out, "trajectories.png"), dpi=120, bbox_inches="tight")
    if curves:
        fig, ax = plt.subplots(figsize=(9, 4))
        for name, distance, error in curves:
            ax.plot(distance, error, label=name)
        ax.set_xlabel("distance travelled [m]")
        ax.set_ylabel("APE [m]")
        ax.set_title("Absolute position error")
        ax.grid(True)
        ax.legend()
        fig.savefig(os.path.join(args.out, "ape.png"), dpi=120, bbox_inches="tight")
    print(f"\nSaved table.md, table.csv, trajectories.png{', ape.png' if curves else ''} in {os.path.abspath(args.out)}")
    if args.show:
        plt.show()


if __name__ == "__main__":
    main()
