import fs from 'node:fs';
import path from 'node:path';

const root = process.argv[2];
const outFile = process.argv[3];

const visitedFiles = new Set();
const visitedPkgs = new Set();

function stripJsonComments(text) {
  return text
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\/\/.*$/gm, '')
    .replace(/^.*"\$schema".*$\n?/gm, '');
}

function loadJsonc(file) {
  return JSON.parse(
    stripJsonComments(
      fs.readFileSync(file, 'utf8')
    )
  );
}

function normalize(p) {
  return path.normalize(p);
}

function pkgFromFile(file) {
  const m = normalize(file).match(
    /work\/(@cspell\/dict-[^/]+)/
  );

  return m?.[1] ?? null;
}

function resolveImport(fromFile, imp) {
  // relative file import
  if (
    imp.startsWith('./') ||
    imp.startsWith('../')
  ) {
    return normalize(
      path.join(
        path.dirname(fromFile),
        imp
      )
    );
  }

  // package import
  let pkg = imp.replace(
    /\/cspell-ext\.json$/,
    ''
  );

  if (!pkg.startsWith('@cspell/')) {
    pkg = '@cspell/dict-' + pkg;
  }

  return normalize(
    path.join(
      'work',
      pkg,
      'cspell-ext.json'
    )
  );
}


function visit(file) {
  file = normalize(file);

  if (visitedFiles.has(file)) return;
  visitedFiles.add(file);

  if (!fs.existsSync(file)) {
    throw new Error(
      `missing import target: ${file}`
    );
  }

  const pkg = pkgFromFile(file);

  if (pkg) {
    visitedPkgs.add(pkg);
  }

  const json = loadJsonc(file);

  for (const imp of json.import ?? []) {
    visit(
      resolveImport(file, imp)
    );
  }
}

visit(
  path.join(
    'work',
    '@cspell/dict-' + root,
    'cspell-ext.json'
  )
);

fs.writeFileSync(
  outFile,
  JSON.stringify(
    [...visitedPkgs].sort(),
    null,
    2
  )
);
