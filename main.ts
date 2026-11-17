// Brainrot Bay: the entrypoint.
// Copies the place, the sources, the screenshots and the play link into
// the output directory, then writes the dossier the gate compares byte
// for byte. Node standard library only; nothing is installed.
import { copyFileSync, mkdirSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { buildDossier } from "./vendor/makefun-roblox.ts";

const SOURCE_DIR = import.meta.dirname;
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR || "/output";

const DOSSIER_CAPS = {
	text_max_bytes: 65536,
	screenshots: { max: 4, max_bytes: 262144 },
	max_instances: 500000,
	scripts_max_source_bytes: 8388608,
	scripts_max_path_chars: 1048576,
};

// Copy a directory tree, skipping every name that starts with a dot:
// a dot-name anywhere under /output fails the entry outright.
function copyTree(source: string, dest: string): void {
	mkdirSync(dest, { recursive: true });
	for (const name of readdirSync(source)) {
		if (name.startsWith(".")) {
			continue;
		}
		const from = join(source, name);
		const to = join(dest, name);
		if (statSync(from).isDirectory()) {
			copyTree(from, to);
		} else {
			copyFileSync(from, to);
		}
	}
}

// The output starts empty so a second run writes exactly the same
// bytes as the first: no stale files, no timestamps anywhere.
function main(): void {
	rmSync(OUTPUT_DIR, { recursive: true, force: true });
	mkdirSync(OUTPUT_DIR, { recursive: true });
	copyFileSync(join(SOURCE_DIR, "game.rbxl"), join(OUTPUT_DIR, "game.rbxl"));
	copyFileSync(join(SOURCE_DIR, "PLAY.json"), join(OUTPUT_DIR, "PLAY.json"));
	copyTree(join(SOURCE_DIR, "src"), join(OUTPUT_DIR, "src"));
	copyTree(join(SOURCE_DIR, "screenshots"), join(OUTPUT_DIR, "screenshots"));
	writeFileSync(join(OUTPUT_DIR, "dossier.json"), buildDossier(OUTPUT_DIR, DOSSIER_CAPS));
}

main();
