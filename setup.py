from setuptools import find_packages, setup

setup(
    name="autoformat",
    description="",
    packages=find_packages(exclude=("tests",)),
    version="0.0.1",
    install_requires=[
        "typer",
    ],
    entry_points={"console_scripts": ["autoformat = autoformat:main"]},
)
