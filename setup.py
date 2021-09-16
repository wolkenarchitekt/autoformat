from setuptools import find_packages, setup

setup(
    name="autoformat",
    description="",
    packages=find_packages(exclude=("tests",)),
    version="0.0.3",
    install_requires=[
        "autoflake",
        "black",
        "isort",
        "sqlparse",
        "typer",
    ],
    entry_points={"console_scripts": ["autoformat = autoformat:main"]},
)
