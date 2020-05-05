# What is Jim?

Think of Jim as its own language that is a superset of [Elm](https://elm-lang.org/). Jim adds more JavaScript interop capabilities on top of Elm. Right now the project is in its infancy, but hopefully some day it will have it's own compiler and package manager, and it may even differ from Elm in other ways.

# Installation

- **Elm:** [elm-git-install](https://github.com/Skinney/elm-git-install)
- **[JavaScript](https://github.com/ursi/jim-js):** `npm install @ursi/jim-js`


# Documentation

- [Jim](https://elm-doc-preview.netlify.app/Jim?repo=ursi%2Fjim&version=master)
- [JavaScript](https://github.com/ursi/jim-js)

# Example

## JavaScript (Node.js)

```javascript
const
	{promises: fsp} = require(`fs`),
	jim = require(`@ursi/jim`),
	{Elm} = require(`elm.js`);

jim.regTask(`write file`, fsp.writeFile);

Elm.Main.init();
```

## Jim

```elm
import Jim
import Json.Decode as D
import Json.Encode as E

writeFile : String -> String -> Task D.Error ()
writeFile path contents =
	task "write file"
	Jim.a2 (E.string path) (E.string contents)
	(D.succeed ())
```
