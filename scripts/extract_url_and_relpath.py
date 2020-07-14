import argparse
import os
import sys


def extract_url_and_relpath(wget_cmd, dataset_path): 
    cmd_split = [split for split in wget_cmd.split(' ') if split]
    dataset_path = dataset_path.rstrip('/')
    filepath = ""
    url = None
    
    i = 0
    while i < len(cmd_split):
        item = cmd_split[i]
        if item == "wget":
            pass
        # -P dir_path
        elif item == "-P":
            filepath = cmd_split[i+1]
            i += 1
        else:
            url = cmd_split[i]
        i += 1
    
    filepath = os.path.join(filepath, os.path.basename(url))
    filepath = os.path.relpath(filepath, dataset_path)
    
    print(url, filepath)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("wget_cmd", nargs='?', default=sys.stdin)
    parser.add_argument("--dataset_path")
    args = parser.parse_args()

    wget_cmd = args.wget_cmd
    if wget_cmd is sys.stdin:
        wget_cmd = wget_cmd.read()
    
    extract_url_and_relpath(wget_cmd, args.dataset_path)
