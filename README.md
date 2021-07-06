This gem will attempt to generate code of a class of an object representing the contents of a Serialised-Object-Notation (SON) string (or file). E.g. it will generate code of a object's class from some JSON.

The intention with this gem is to provide assistance with creating code that can translate JSON (or other SON) into a proper Object.

If the SON looks to have a nested object structure (e.g. a Contact object looks to hold a PhoneNumber object) then multiple classes will be generated.

Limitations :

SON : will only process JSON
Code : will only generate Ruby or Java (to generate Java using Lombok, use the :java_lombok symbol)

Usage : require the gem, then invoke

```
require 'class_from_son'

ClassFromSON.generate_from_file :ruby, "a_file.json"

or

ClassFromSON.generate :ruby, my_json_string, :json
```

or from the command line :

```
ruby -e "require 'class_from_son'; ClassFromSON.generate_from_file :ruby, 'a_file.json'"

or

ruby -e "require 'class_from_son'; ClassFromSON.generate :ruby, my_json_string, :json"
```

Advanced use :

```
ruby -e "require 'class_from_son'; ClassFromSON.generate :ruby, my_json_string, :json, true, false, true, '../write/files/somewhere/else'"
```

Method parameter explanations :

```
# Will generate classes from a SON file
# Regardless of whether or not files are written, this will return an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
#
# dest_lang is symbol
# file is filename & path
# source_lang is symbol or nil (if nil, source language will be determined from the file extension)
# make_file flag defaults to true; set to false if you do not want files to be created by this method
# force_file flag is false; set to true if you wish to overwrite matching destination files (use with caution!)
# lenient_mode flag is true; if the SON contains different objects with the same name (e.g. "data") then these will be treated
#    as different objects with a _1, _2, etc. suffix. If this flag is false and these different objects are present, then errors will occur
# custom_file_path is nil; set to an absoulte or relative path to have the new files be written to that location
def ClassFromSON.generate_from_file(dest_lang, file, source_lang = nil, make_file = true, force_file = false, lenient_mode = true, custom_file_path = nil)
```

```
# Will generate classes from a SON string
# Regardless of whether or not files are written, this will return an array of hashes; each hash represents a file, with two keys : :name for filename (without extension), and :contents for file contents
#
# dest_lang is symbol
# file is filename & path
# source_lang is symbol
# make_file flag defaults to true; set to false if you do not want files to be created by this method
# force_file flag is false; set to true if you wish to overwrite matching destination files (use with caution!)
# lenient_mode flag is true; if the SON contains different objects with the same name (e.g. "data") then these will be treated
#    as different objects with a _1, _2, etc. suffix. If this flag is false and these different objects are present, then errors will occur
# custom_file_path is nil; set to an absoulte or relative path to have the new files be written to that location
def ClassFromSON.generate(dest_lang, source, source_lang, make_file = true, force_file = false, lenient_mode = true, custom_file_path = nil)
```
