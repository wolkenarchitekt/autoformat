import logging
import os
import pickle
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

logger = logging.getLogger(__name__)

AUTOFORMAT_DB = f"{os.getcwd()}/.autoformat_db"

"""
dependencies:
pip install autoflake isort black sqlparse
npm install prettier
apt-get install jq
"""
FORMATTERS = {
    ".py": [
        ["autoflake", "--in-place", "--remove-all-unused-imports"],
        ["black", "-q"],
        ["isort", "-q"],
    ],
    ".js": [["prettier", "--loglevel", "warn", "--write"]],
    ".json": [["/usr/bin/jq", "."]],
    ".sql": [
        ["sqlformat", "--reindent", "--keywords", "upper", "--identifiers", "lower"]
    ],
}


def git_diff(file: Path, tmp_file: Path):
    result = subprocess.run(
        ["git", "--no-pager", "diff", "--color", str(file), str(tmp_file)],
        shell=False,
        capture_output=True,
    )
    if result.stderr:
        raise Exception(f"Error calling git diff: {result.stderr}")
    return result.stdout.decode()


def autoformat(file: Path):
    with tempfile.NamedTemporaryFile(delete=False, suffix=file.suffix) as tmp_file:
        shutil.copyfile(file, tmp_file.name)

        # Non-inline formatters - redirect output to tempfile
        if file.suffix in [".json", ".sql"]:
            for script in FORMATTERS[file.suffix]:
                result = subprocess.run(
                    [
                        *script,
                        f"{tmp_file.name}",
                    ],
                    check=True,
                    shell=False,
                    capture_output=True,
                )
                if result.stdout:
                    with open(tmp_file.name, "w") as f:
                        f.write(result.stdout.decode())

        else:
            # Inline formatters
            for script in FORMATTERS[file.suffix]:
                if script[0] == "isort":
                    isort_cfg = Path(Path(sys.argv[0]).parent.parent.parent / ".isort.cfg")
                    if not isort_cfg.exists():
                        raise SystemExit(f"isort config not found at {isort_cfg}")
                    logger.debug(f"Using isort config: {isort_cfg}")
                    script.extend(['--sp', str(isort_cfg)])

                logger.debug(f"Running: {script} {tmp_file.name}")
                subprocess.run(
                    [
                        *script,
                        f"{tmp_file.name}",
                    ],
                    check=True,
                    shell=False,
                )
        diff = git_diff(file, Path(tmp_file.name))
        if diff:
            print(diff)
        shutil.copyfile(tmp_file.name, file)


def collect_files(file_list):
    files = []
    for arg in file_list:
        path = Path(arg)
        if not path.exists():
            raise SystemExit(f"Path not found: {path}")
        if path.is_file():
            if path.name.endswith(tuple(FORMATTERS.keys())):
                files.append(path)
        else:
            for root, _, filenames in os.walk(path):
                for file in filenames:
                    if file.endswith(tuple(FORMATTERS.keys())):
                        files.append(Path(root) / Path(file))
    return files


def autoformat_files(files, db, use_cache=False):
    logger.debug(f"Formatting files: {','.join(str(file) for file in files)}")
    for file in files:
        if use_cache:
            if file not in db["files"] or db["files"][file] < os.path.getmtime(file):
                autoformat(file)
                db["files"][file] = os.path.getmtime(file)
        else:
            autoformat(file)


def main():
    logging.basicConfig(level=logging.WARNING)
    if len(sys.argv) == 1 or sys.argv[1] in ["-h", "--help"]:
        sys.exit("Syntax: autoformat [FILE]")

    if os.path.exists(AUTOFORMAT_DB):
        with open(AUTOFORMAT_DB, "rb") as f:
            db = pickle.load(f)
    else:
        db = {"venv_bin_dir": None, "node_bin_dir": None, "files": {}}

    files = collect_files(file_list=sys.argv[1:])

    autoformat_files(
        files=files, db=db
    )

    with open(AUTOFORMAT_DB, "wb") as f:
        pickle.dump(db, f)


if __name__ == "__main__":
    main()
