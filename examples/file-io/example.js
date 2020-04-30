'use strict';

const
	path = require(`path`),
	fs = require(`fs`),
	fsp = fs.promises,
	jim = require(`@ursi/jim`),
	{Elm} = require(`./elm`);

jim.regFunction(`console.log`, console.log);
jim.regFunction(`path.join`, args => path.join(...args));

jim.regTask(`fsp.writeFile`, fsp.writeFile);
jim.regTask(`fsp.readFile`, filePath => {
	return fsp.readFile(filePath, `utf-8`);
});

jim.regTask(`fsp.readdir`, fsp.readdir);
jim.regTask(`fs.existsSync`, fs.existsSync);
jim.regTask(`fsp.mkdir`, fsp.mkdir);
jim.regTask(`fsp.unlink`, fsp.unlink);

Elm.Main.init({
	flags: {
		args: process.argv.slice(2),
		dirname: __dirname,
	},
});
