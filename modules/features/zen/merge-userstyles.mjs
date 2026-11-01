#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";

const [
  stylesDir,
  stdPath,
  lesscPath,
  outPath,
  lightFlavor = "mocha",
  darkFlavor = "mocha",
  accentColor = "mauve",
] = process.argv.slice(2);

if (!stylesDir || !stdPath || !lesscPath || !outPath) {
  console.error(
    "usage: merge-userstyles.mjs <styles-dir> <std.less> <lessc> <out> [lightFlavor] [darkFlavor] [accentColor]",
  );
  process.exit(2);
}

const META_RE = /\/\*\s*==UserStyle==[\s\S]*?==\/UserStyle==\s*\*\//;
const VAR_RE = /^\s*@var\s+(\S+)\s+(\S+)\s+"([^"]*)"\s+(.*)$/;
const STD_IMPORT = '@import "https://userstyles.catppuccin.com/lib/std/v1.less";';
const LEGACY_LIB_IMPORT = '@import "https://userstyles.catppuccin.com/lib/lib.less";';

function fail(message) {
  throw new Error(message);
}

function parseVar(line) {
  const match = line.match(VAR_RE);
  if (!match) return null;

  const [, type, name, , restRaw] = match;
  const rest = restRaw.trim();
  let value;

  switch (type) {
    case "select": {
      const options = [...rest.matchAll(/"([^"]+):([^"]*)"/g)];
      const defaultOption = options.find(([, , label]) => label.trim().endsWith("*"));
      if (!defaultOption) fail(`no starred default for select variable @${name}`);
      value = defaultOption[1];
      break;
    }
    case "range": {
      const defaultMatch = rest.match(/^\[\s*([^,\]]+)/);
      if (!defaultMatch) fail(`invalid range default for @${name}`);
      value = defaultMatch[1].trim();
      break;
    }
    case "checkbox":
      value = rest;
      break;
    case "text":
      if (/^".*"$/.test(rest)) {
        try {
          value = JSON.parse(rest);
        } catch {
          value = rest.slice(1, -1).replace(/\\\\/g, "\\");
        }
      } else {
        value = rest;
      }
      break;
    default:
      fail(`unsupported usercss variable type "${type}" for @${name}`);
  }

  return [name, value];
}

function parseVariables(source, styleName) {
  const metadata = source.match(META_RE);
  if (!metadata) fail(`${styleName}: missing usercss metadata`);

  const vars = new Map();
  for (const line of metadata[0].split("\n")) {
    const parsed = parseVar(line);
    if (!parsed) continue;
    const [name, value] = parsed;
    if (vars.has(name)) fail(`${styleName}: duplicate @var ${name}`);
    vars.set(name, value);
  }

  for (const [name, value] of Object.entries({
    lightFlavor,
    darkFlavor,
    accentColor,
  })) {
    if (!vars.has(name)) fail(`${styleName}: missing @var ${name}`);
    vars.set(name, value);
  }

  return vars;
}

function inlineStd(source, stdText, styleName) {
  const imports = [STD_IMPORT, LEGACY_LIB_IMPORT].flatMap((statement) =>
    Array(source.split(statement).length - 1).fill(statement),
  );
  if (imports.length === 0) {
    fail(`${styleName}: missing standard Catppuccin import`);
  }
  if (imports.length > 1) {
    fail(`${styleName}: duplicate Catppuccin library import`);
  }

  // The legacy lib.less endpoint is a shim for std/v1.less.
  return source.replace(imports[0], stdText);
}

function skipComment(css, i) {
  const end = css.indexOf("*/", i + 2);
  if (end === -1) fail("unterminated CSS comment");
  return end + 2;
}

function skipString(css, i) {
  const quote = css[i];
  i++;
  while (i < css.length) {
    if (css[i] === "\\") {
      i += 2;
      continue;
    }
    if (css[i] === quote) return i + 1;
    i++;
  }
  fail("unterminated CSS string");
}

function skipWhitespaceAndComments(css, i) {
  for (;;) {
    while (i < css.length && /\s/.test(css[i])) i++;
    if (css.startsWith("/*", i)) {
      i = skipComment(css, i);
      continue;
    }
    return i;
  }
}

function skipToBlockStart(css, i) {
  let parens = 0;
  while (i < css.length) {
    const char = css[i];
    if (char === "/" && css[i + 1] === "*") {
      i = skipComment(css, i);
      continue;
    }
    if (char === '"' || char === "'") {
      i = skipString(css, i);
      continue;
    }
    if (char === "(") parens++;
    if (char === ")") parens--;
    if (parens < 0) fail("unbalanced CSS parentheses");
    if (char === "{") {
      if (parens !== 0) fail("unexpected CSS block inside at-rule prelude");
      return i;
    }
    if (char === ";" || char === "}") {
      fail("at-rule is missing a block");
    }
    i++;
  }
  fail("unterminated CSS at-rule");
}

function skipBlock(css, i) {
  let depth = 1;
  i++;
  while (i < css.length) {
    const char = css[i];
    if (char === "/" && css[i + 1] === "*") {
      i = skipComment(css, i);
      continue;
    }
    if (char === '"' || char === "'") {
      i = skipString(css, i);
      continue;
    }
    if (char === "{") depth++;
    if (char === "}") {
      depth--;
      if (depth === 0) return i + 1;
    }
    i++;
  }
  fail("unterminated CSS block");
}

function skipStatement(css, i) {
  while (i < css.length) {
    const char = css[i];
    if (char === "/" && css[i + 1] === "*") {
      i = skipComment(css, i);
      continue;
    }
    if (char === '"' || char === "'") {
      i = skipString(css, i);
      continue;
    }
    if (char === ";") return i + 1;
    if (char === "{" || char === "}") fail("unexpected CSS block in top-level statement");
    i++;
  }
  fail("unterminated top-level CSS statement");
}

function validateTopLevel(css, styleName) {
  let i = 0;
  let sections = 0;

  for (;;) {
    i = skipWhitespaceAndComments(css, i);
    if (i >= css.length) break;

    const rest = css.slice(i);
    const lower = rest.toLowerCase();
    if (
      lower.startsWith("@-moz-document") &&
      !/[\w-]/.test(rest.slice("@-moz-document".length, "@-moz-document".length + 1))
    ) {
      const blockStart = skipToBlockStart(css, i + "@-moz-document".length);
      i = skipBlock(css, blockStart);
      sections++;
      continue;
    }

    if (/^@charset\b/i.test(rest) || /^@namespace\b/i.test(rest)) {
      i = skipStatement(css, i);
      continue;
    }

    fail(
      `${styleName}: unhandled top-level CSS (would apply globally): ${rest
        .slice(0, 120)
        .replace(/\s+/g, " ")}`,
    );
  }

  if (sections === 0) fail(`${styleName}: compiled CSS has no @-moz-document sections`);
  return sections;
}

function compileStyle(styleName, sourcePath, stdText, tmpDir) {
  const source = fs.readFileSync(sourcePath, "utf8");
  const vars = parseVariables(source, styleName);
  const body = inlineStd(source.replace(META_RE, ""), stdText, styleName);
  const bakedVars = [...vars]
    .map(([name, value]) => `@${name}: ${value};`)
    .join("\n");
  const inputPath = path.join(
    tmpDir,
    `${styleName.replace(/[^\w.-]/g, "_")}.less`,
  );
  fs.writeFileSync(inputPath, `${bakedVars}\n${body}`);

  const result = spawnSync(lesscPath, ["--math=parens-division", inputPath], {
    encoding: "utf8",
    maxBuffer: 128 * 1024 * 1024,
  });

  if (result.error) {
    fail(`${styleName}: failed to run lessc: ${result.error.message}`);
  }
  if (result.status !== 0) {
    fail(
      `${styleName}: lessc failed:\n${(result.stderr || result.stdout || "").trim()}`,
    );
  }

  const css = result.stdout.replace(/^\s*@charset\s+[^;]+;\s*/i, "");
  const sections = validateTopLevel(css, styleName);
  return { css: css.trim(), sections };
}

function main() {
  const stdText = fs.readFileSync(stdPath, "utf8");
  const styleEntries = fs
    .readdirSync(stylesDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort();

  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "catppuccin-userstyles-"));
  const parts = [];
  let totalSections = 0;

  try {
    for (const styleName of styleEntries) {
      const sourcePath = path.join(stylesDir, styleName, "catppuccin.user.less");
      if (!fs.existsSync(sourcePath)) continue;

      const { css, sections } = compileStyle(
        styleName,
        sourcePath,
        stdText,
        tmpDir,
      );
      parts.push(`/* ${styleName} */\n${css}`);
      totalSections += sections;
      console.error(`[catppuccin] ${styleName}: ${sections} section(s)`);
    }

    if (parts.length === 0) fail(`no styles found under ${stylesDir}`);

    const header = `/* ==UserStyle==
@name         Catppuccin Userstyles
@namespace    github.com/catppuccin/userstyles
@version      1.0.0
@description  Soothing pastel theme for the web (Mocha/Mauve)
@author       Catppuccin
@license      MIT
@preprocessor default
==/UserStyle== */`;

    const output = `${header}\n\n${parts.join("\n\n")}\n`;
    fs.writeFileSync(outPath, output);
    console.error(
      `[catppuccin] merged ${parts.length} styles, ${totalSections} sections, ${Buffer.byteLength(output)} bytes`,
    );
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
}

try {
  main();
} catch (error) {
  console.error(`merge-userstyles: ${error.message}`);
  process.exit(1);
}
