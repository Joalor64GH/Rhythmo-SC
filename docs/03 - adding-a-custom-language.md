# How to Add a Custom Language
This is another simple tutorial on how to add a custom language.

## Adding your Language
Firstly, you need to edit these two main text files:
* `assets/languages/languagesList.txt` - Your list of languages. (de, en, es, fr, and so on...)
* `assets/languages/languagesData.txt` - This is so that your language can be pushed into LanguagesSubState.

To add your language into `languagesData.txt`, use this format:
```
Name (Country):code
```

So, for example, if you wanted to add German, it would look like:
```
Deutsch (Deutschland):de
```

Now, you need your `.json` file, which should be located in `assets/languages/[language code].json`.
Of course, this contains the data for your language. <br>
To add your data, just copy [this](/assets/languages/en.json), and edit it with your translations.