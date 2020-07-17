'use strict';

const
	path = require(`path`),
	fs = require(`fs`),
	fsp = fs.promises,
	jim = require(`@ursi/jim`),
	{Elm} = require(`./elm`);

jim.task(`console.log`, console.log);
jim.function(`path.join`, args => path.join(...args));

jim.task(`fsp.writeFile`, fsp.writeFile);
jim.task(`fsp.readFile`, filePath => {
	return fsp.readFile(filePath, `utf-8`);
});

jim.task(`fsp.readdir`, fsp.readdir);
jim.task(`fs.existsSync`, fs.existsSync);
jim.task(`fsp.mkdir`, fsp.mkdir);
jim.task(`fsp.unlink`, fsp.unlink);

Elm.Main.init({
	flags: {
		args: process.argv.slice(2),
		dirname: __dirname,
	},
});
