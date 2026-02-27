# Claude Agent SDK - TypeScript

Development environment for building Claude agents with TypeScript/Node.js.

## Features

- Node.js 20 LTS with npm, yarn, and pnpm
- TypeScript compiler and language server
- Development tools (prettier, eslint)
- Modern async/await patterns for agent development

## Usage

### With Nix directly

```bash
cd /path/to/your/claude-agent-project
nix develop ~/.config/nix/shells/claude-sdk-typescript
```

**Note**: Replace `/path/to/your/claude-agent-project` with your actual project directory.

### With direnv

Create `.envrc` in your project:

```bash
use flake ~/.config/nix/shells/claude-sdk-typescript
```

Then run `direnv allow` to auto-load the environment.

## Quick Start

1. **Activate the shell**:

   ```bash
   nix develop ~/.config/nix/shells/claude-sdk-typescript
   ```

2. **Initialize your project**:

   ```bash
   npm init -y
   npm install @anthropic-ai/sdk typescript @types/node
   ```

3. **Set your API key**:

   ```bash
   export ANTHROPIC_API_KEY=sk-ant-...
   ```

4. **Create a simple agent** (`agent.ts`):

   ```typescript
   import Anthropic from '@anthropic-ai/sdk';

   const client = new Anthropic({
     apiKey: process.env.ANTHROPIC_API_KEY,
   });

   async function main() {
     const message = await client.messages.create({
       model: 'claude-3-5-sonnet-20241022',
       max_tokens: 1024,
       messages: [
         { role: 'user', content: 'Hello, Claude!' }
       ],
     });
     console.log(message.content);
   }

   main();
   ```

5. **Run your agent**:

   ```bash
   npx ts-node agent.ts
   ```

## Resources

- **SDK Repository**: <https://github.com/anthropics/claude-agent-sdk-typescript>
- **API Documentation**: <https://docs.anthropic.com/>
- **SDK Demos**: <https://github.com/anthropics/claude-agent-sdk-demos>
- **Cookbook Examples**: <https://github.com/anthropics/claude-cookbooks>

## Development Tools

- `prettier`: Format code with `npx prettier --write .`
- `eslint`: Lint with `npx eslint .`
- `tsc`: Type check with `npx tsc --noEmit`
- `ts-node`: Execute TypeScript directly with `npx ts-node file.ts`

## TypeScript Configuration

Create a `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

## Testing

Install vitest for testing:

```bash
npm install --save-dev vitest
```

Run tests:

```bash
npx vitest
```
