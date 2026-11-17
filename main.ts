// Brainrot Bay: the entrypoint.
// Hands the game in: copies game.rbxl, src/, screenshots/ and
// PLAY.json from this repository into /output, leaving out every
// name that starts with a dot, and writes /output/dossier.json
// with buildDossier from the kit's library, unchanged.
// Node 22, standard library only. Run it as the grader does:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { buildDossier } from "./vendor/makefun-roblox.ts";
import {
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { join } from "node:path";

const SOURCE_DIR = process.cwd();
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR || "/output";

// Copy one entry of the repository, skipping dot-names. Directories
// are copied whole; a dot-name anywhere under them fails an entry,
// so none is ever carried over.
function copyEntry(name: string): void {
  const from = join(SOURCE_DIR, name);
  const to = join(OUTPUT_DIR, name);
  if (!existsSync(from)) {
    throw new Error("missing entry in repository: " + name);
  }
  if (statSync(from).isDirectory()) {
    mkdirSync(to, { recursive: true });
    for (const child of readdirSync(from)) {
      if (child.startsWith(".")) {
        continue;
      }
      cpSync(join(from, child), join(to, child), { recursive: true });
    }
  } else {
    cpSync(from, to);
  }
}

// The four entries the gate reads. Nothing else is handed in.
const ENTRIES = ["game.rbxl", "src", "screenshots", "PLAY.json"];

// The gate's caps, so this program fails where the scorer would.
const CAPS = {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8 * 1024 * 1024,
  scripts_max_path_chars: 1024 * 1024,
};

function main(): void {
  rmSync(OUTPUT_DIR, { recursive: true, force: true });
  mkdirSync(OUTPUT_DIR, { recursive: true });
  for (const name of ENTRIES) {
    copyEntry(name);
  }
  const dossier = buildDossier(OUTPUT_DIR, CAPS);
  writeFileSync(join(OUTPUT_DIR, "dossier.json"), dossier);
}

main();
