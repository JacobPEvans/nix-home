# Claude Agent SDK - Python

Development environment for building Claude agents with Python.

## Features

- Python 3.11+ with modern package management
- Anthropic Python SDK pre-installed
- Development tools (pytest, black, mypy, ruff)
- Interactive IPython shell with rich formatting

## Usage

### With Nix directly

```bash
cd /path/to/your/claude-agent-project
nix develop ~/.config/nix/shells/claude-sdk-python
```

### With direnv

Create `.envrc` in your project:

```bash
use flake ~/.config/nix/shells/claude-sdk-python
```

Then run `direnv allow` to auto-load the environment.

## Quick Start

1. **Activate the shell**:

   ```bash
   nix develop ~/.config/nix/shells/claude-sdk-python
   ```

2. **Set your API key**:

   ```bash
   export ANTHROPIC_API_KEY=sk-ant-...
   ```

3. **Create a simple agent**:

   ```python
   from anthropic import Anthropic

   client = Anthropic()
   message = client.messages.create(
       model="claude-3-5-sonnet-20241022",
       max_tokens=1024,
       messages=[
           {"role": "user", "content": "Hello, Claude!"}
       ]
   )
   print(message.content)
   ```

## Resources

- **SDK Repository**: <https://github.com/anthropics/claude-agent-sdk-python>
- **API Documentation**: <https://docs.anthropic.com/>
- **SDK Demos**: <https://github.com/anthropics/claude-agent-sdk-demos>
- **Cookbook Examples**: <https://github.com/anthropics/claude-cookbooks>

## Development Tools

- `pytest`: Run tests with `pytest tests/`
- `black`: Format code with `black .`
- `mypy`: Type check with `mypy src/`
- `ruff`: Lint with `ruff check .`

## Virtual Environment

The shell automatically creates a `.venv` directory. Activate it with:

```bash
source .venv/bin/activate
```

Core dependencies (`anthropic`, `pytest-asyncio`, etc.) are already included via Nix.
Install additional project-specific packages as needed:

```bash
pip install <your-project-dependencies>
```
