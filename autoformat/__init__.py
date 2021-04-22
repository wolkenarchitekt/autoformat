import os
import pickle
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

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
        ["isort", "-q"],
        ["black", "-q"],
    ],
    ".js": [["prettier", "--loglevel", "warn", "--write"]],
    ".json": [["/usr/bin/jq", "."]],
    ".sql": [
        ["sqlformat", "--reindent", "--keywords", "upper", "--identifiers", "lower"]
    ],
}


def get_venv_bin_dir():
    # Try to find virtualenv dir
    activate_script = list(Path(os.getcwd()).glob("**/bin/activate"))
    if activate_script:
        return str(activate_script[0].parent)


def get_node_bin_dir():
    path = Path(os.path.join(os.getcwd(), "node_modules/.bin"))
    if path.exists():
        return path


def git_diff(file: Path, tmp_file: Path):
    result = subprocess.run(
        ["git", "--no-pager", "diff", "--color", str(file), str(tmp_file)],
        shell=False,
        capture_output=True,
    )
    if result.stderr:
        raise Exception(f"Error calling git diff: {result.stderr}")
    return result.stdout.decode()


def autoformat(file: Path, venv_bin_dir=None, node_bin_dir=None):
    with tempfile.NamedTemporaryFile(delete=False, suffix=file.suffix) as tmp_file:
        shutil.copyfile(file, tmp_file.name)

        # Non-inline formatters - redirect output to tempfile
        if file.suffix in [".json", ".sql"]:
            for script in FORMATTERS[file.suffix]:
                if file.suffix == ".sql" and venv_bin_dir:
                    script[0] = os.path.join(venv_bin_dir, script[0])

                if not os.path.exists(script[0]):
                    raise SystemExit(f"Could not find formatter: {script[0]}")

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
                if file.suffix == ".py" and venv_bin_dir:
                    script[0] = os.path.join(venv_bin_dir, script[0])

                if file.suffix == ".js" and node_bin_dir:
                    script[0] = os.path.join(node_bin_dir, script[0])

                if not os.path.exists(script[0]):
                    raise SystemExit(f"Could not find formatter: {script[0]}")

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
        path = Path(os.path.join(os.getcwd(), arg))
        if path.is_file():
            if path.name.endswith(tuple(FORMATTERS.keys())):
                files.append(path)
        else:
            for root, _, filenames in os.walk(path):
                for file in filenames:
                    if file.endswith(tuple(FORMATTERS.keys())):
                        files.append(Path(os.path.join(root, file)))
    return files


def autoformat_files(files, db, venv_bin_dir, node_bin_dir):
    for file in files:
        if file not in db["files"] or db["files"][file] < os.path.getmtime(file):
            autoformat(file, venv_bin_dir, node_bin_dir)
            db["files"][file] = os.path.getmtime(file)


def main():
    if len(sys.argv) == 1 or sys.argv[1] in ["-h", "--help"]:
        sys.exit("Syntax: autoformat [FILE]")

    if os.path.exists(AUTOFORMAT_DB):
        with open(AUTOFORMAT_DB, "rb") as f:
            db = pickle.load(f)
    else:
        db = {"venv_bin_dir": None, "node_bin_dir": None, "files": {}}

    venv_bin_dir = get_venv_bin_dir()
    node_bin_dir = get_node_bin_dir()

    if venv_bin_dir:
        print(f"Using virtualenv: {venv_bin_dir}")

    if node_bin_dir:
        print(f"Using node dir: {node_bin_dir}")

    files = collect_files(file_list=sys.argv[1:])

    autoformat_files(
        files=files, db=db, venv_bin_dir=venv_bin_dir, node_bin_dir=node_bin_dir
    )

    with open(AUTOFORMAT_DB, "wb") as f:
        pickle.dump(db, f)


if __name__ == "__main__":
    main()
