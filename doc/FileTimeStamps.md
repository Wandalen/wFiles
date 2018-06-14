#### Access to data( fileRead )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  | -  |   |   |   |
| linux| -  |   |   |   |
|  mac | *  |   |   |   |

<!-- <p></p>
<details><summary>Test results Windows</summary>
<p>

```
```

</p>
</details> -->

-----


#### Modification of data( fileWrite )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  |   |   |   |   |
| linux|   |   |   |   |
|  mac |   |   |   |   |

-----

#### Modification of data( fileCopy )

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

#### Modification of atime,mtime timestamps ( fileTimeSet )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  |   |   |   |   |
| linux|   |   |   |   |
|  mac |   |   |   |   |

-----

> \* - time was updated

> \** - time was taken from src

> \- - not changed