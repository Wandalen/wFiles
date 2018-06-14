#### Reading( fileRead )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  | -  |   |   |   |
| linux| -  |   |   |   |
|  mac | *  |   |   |   |

<p></p>
<details><summary>Test results Windows</summary>
<p>

```
--> Reading:

----> Stats of the file before read:

stats.atime:  2018-06-14T08:53:09.455Z
stats.atime:  1528966389455

stats.mtime:  2018-06-14T08:53:09.456Z
stats.mtime:  1528966389456

stats.ctime:  2018-06-14T08:53:09.456Z
stats.ctime:  1528966389456

stats.birthtime:  2018-06-14T08:53:09.455Z
stats.birthtime:  1528966389455

----> After read with no delay :

stats.atime:  2018-06-14T08:53:09.455Z
stats.atime:  1528966389455

stats.mtime:  2018-06-14T08:53:09.456Z
stats.mtime:  1528966389456

stats.ctime:  2018-06-14T08:53:09.456Z
stats.ctime:  1528966389456

stats.birthtime:  2018-06-14T08:53:09.455Z
stats.birthtime:  1528966389455

----> After read with 10ms delay :

stats.atime:  2018-06-14T08:53:09.455Z
stats.atime:  1528966389455

stats.mtime:  2018-06-14T08:53:09.456Z
stats.mtime:  1528966389456

stats.ctime:  2018-06-14T08:53:09.456Z
stats.ctime:  1528966389456

stats.birthtime:  2018-06-14T08:53:09.455Z
stats.birthtime:  1528966389455

----> After read with 1000ms delay :

stats.atime:  2018-06-14T08:53:09.455Z
stats.atime:  1528966389455

stats.mtime:  2018-06-14T08:53:09.456Z
stats.mtime:  1528966389456

stats.ctime:  2018-06-14T08:53:09.456Z
stats.ctime:  1528966389456

stats.birthtime:  2018-06-14T08:53:09.455Z
stats.birthtime:  1528966389455
```

</p>
</details>

-----


#### Rewriting the file( fileWrite )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  |   |   |   |   |
| linux|   |   |   |   |
|  mac |   |   |   |   |

-----

#### Chaning content of the dst( fileCopy )

Src:

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  | -  |   |   |   |
| linux| *  |   |   |   |
|  mac | -  |   |   |   |

Dst:

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  |   |  **  | **  |   |
| linux|   |   |   |   |
|  mac |   |   |   |   |

-----

#### Changing atime/mtime properties( fileTimeSet )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  |   |   |   |   |
| linux|   |   |   |   |
|  mac |   |   |   |   |

-----

> \* - time was updated

> \** - time was taken from src

> \- - not changed