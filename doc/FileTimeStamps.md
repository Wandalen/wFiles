#### Reading( fileRead )

|   |atime|mtime| ctime  | birthtime  |
|---|---|---|---|---|
| win  | -  |   |   |   |
| linux| -  |   |   |   |
|  mac | *  |   |   |   |

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