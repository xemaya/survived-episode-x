// (Placeholder — inkjs ships its own JS compiler, so the .NET inklecate binary is no longer
// needed for build. This script remains for users who want to fall back to the official
// inklecate binary, e.g. for advanced compiler options not exposed by inkjs.)

console.log('\nNote: inkjs ships its own JavaScript compiler.');
console.log('The default `pnpm ink:build` does NOT need a separate inklecate binary.\n');
console.log('Only run this setup if you have a specific reason to use the official .NET');
console.log('inklecate (e.g. compatibility testing). See:');
console.log('  https://github.com/inkle/ink/releases/latest');
console.log('');
console.log('If you do install it, point the build script at it via:');
console.log('  export INKLECATE_PATH=/path/to/your/inklecate');
console.log('(Note: the current build script uses inkjs/compiler directly and does not');
console.log(' read INKLECATE_PATH; you would need to extend ink-build.mjs to add a');
console.log(' subprocess fallback.)');
console.log('');
