install:
	sudo apt-get install -y shfmt
	go install github.com/google/yamlfmt/cmd/yamlfmt@latest
	npm install prettier
	cargo install taplo-cli
	uv venv
	uv pip install -e .
	uv pip install .[dev]

	uv tool install -e . --force
