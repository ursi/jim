'use strict';

const
	{promises: fsp} = require(`fs`),
	jim = require(`@ursi/jim`),
	{Elm} = require(`./elm`);

jim.regFunction(`log`, console.log);
jim.regTask(`writeFile`, fsp.writeFile);
jim.regTask(`readFile`, async filePath => {
	try {
		const text = await fsp.readFile(filePath, `utf-8`);
		return text;
	} catch {}
});

Elm.Main.init({flags: process.argv.slice(2).join(` `)});
