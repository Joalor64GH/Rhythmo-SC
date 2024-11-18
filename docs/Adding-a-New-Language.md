## Creating the JSON File
First, you need to create a file in `assets/languages/` called `[language-code].json`. <br>
The name doesn't really matter, so you can call it whatever you want.

For its data, copy [this](https://raw.githubusercontent.com/Joalor64GH/Rhythmo-SC/main/assets/languages/en.json), and edit it with your translations.

## Loading your Language
Now, you need to edit these two main text files:
* `assets/languages/languagesList.txt` - Your list of languages. (e.g., `de`, `en`, `es`, `fr`)
* `assets/languages/languagesData.txt` - This is so that your language can be pushed into `LanguagesState.hx`.

To add your language into `languagesData.txt`, use this format:
```
Name (Country):code
```

So, for example, if you wanted to add German, it would look like:
```
Deutsch (Deutschland):de
```

## Localization Functions
Like most functions, these can be accessed through [scripting](https://github.com/Joalor64GH/Rhythmo-SC/wiki/Scripting).

### Switching to Another Language
```hx
Localization.switchLanguage('language-code');
```

If that language is already selected, the change will not happen.

## Retrieving a Key
```hx
Localization.get('key', 'language-code');
```

If the second parameter is empty, defaults to currnt language.

For further documentation, check out [`SimpleLocalization`](https://github.com/Joalor64GH/SimpleLocalization).