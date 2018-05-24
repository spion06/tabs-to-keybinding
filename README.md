# tabs-to-keybinding
simple little script to convert tabs into keypresses

## usage

```
ruby parse_tab_sheet.rb <path to tabs> [path to mapping yaml]
```

## tabs format
tabs must have the first column be the tuning of the string. this can be an integer offset or the actual note. if an actual note is used then a mapping file should be passed as an argument so the offsets can be matched. Offsets can be negative. 

tabs with note tuning
```
e|------------------------------------------------------------------|
B|------------------------------------------------------------------|
G|-----------------------------------2-2-2-2-2-0-2------------------|
D|--0-2-2-2-2-2-0-2---0-2-2-2-2-0-2------------------0-2-2-2-2-2-0-2|
A|-2----------------2------------------------------2----------------|
E|------------------------------------------------------------------|
```

tabs with integer offset
```
40|------------------------------------------------------------------|
35|------------------------------------------------------------------|
31|-----------------------------------2-2-2-2-2-0-2------------------|
26|--0-2-2-2-2-2-0-2---0-2-2-2-2-0-2------------------0-2-2-2-2-2-0-2|
21|-2----------------2------------------------------2----------------|
13|------------------------------------------------------------------|
```

## mapping yaml
the mapping yaml takes the tunings denoted on the left of the tab and uses them later on to map to offsets


mapping yaml
```
---
e: 40
B: 35
G: 31
D: 26
A: 21
E: 13
```
