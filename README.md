# What is Jim?

Jim (**J**avaScript **i**n El**m**) is a tool for adding more FFI options to [Elm](https://elm-lang.org/). Jim allows you to use JavaScript to write your own tasks and functions.
# Installation

- **Elm:** [elm-git-install](https://github.com/Skinney/elm-git-install)
- **[JavaScript](https://github.com/ursi/jim-js):** `npm install @ursi/jim`


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

jim.task(`write file`, fsp.writeFile);

Elm.Main.init();
```

## Jim

```elm
import Jim
import Json.Decode as D
import Json.Encode as E

writeFile : String -> String -> Task D.Error ()
writeFile path contents =
    Jim.task "write file"
    [ E.string path, E.string contents ]
    (D.succeed ())
```
