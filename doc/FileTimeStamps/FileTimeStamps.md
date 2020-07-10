#### Access to data( fileRead )

|   |atime|mtime| ctime  | birthtime  |
|:---:|:---:|:---:|:---:|:---:|
| win  | -  | -  | -  | - |
| linux| +  | -  | -  | -  |
|  mac | +  |  - |  - |  - |

<!-- Linux - no delay or 1s - same atime, but updated, needs additional check -->
<!-- Mac - updates atime only in case with 1s delay, needs additional check  -->

<!-- <p></p>
<details><summary>Test results Windows</summary>
<p>

```
```

</p>
</details> -->

-----


#### Modification of data, rewriting( fileWrite )

|   |atime|mtime| ctime  | birthtime  |
|:---:|:---:|:---:|:---:|:---:|
| win  | -  | + |  + | - |
| linux| -  | +  | +  | +  |
|  mac | -  |  + |  + |  - |

<!-- Linux - no delay - no changes, needs additional check -->
<!-- Linux - 10ms delay - updates mtime,ctime,birthtime -->
<!-- Mac - creating the file with 10ms delay - first file has same timestamps as second, needs check -->

-----

#### Modification of data( fileCopy )

Src:

|   |atime|mtime| ctime  | birthtime  |
|:---:|:---:|:---:|:---:|:---:|
| win  | -  | -  | -  |  - |
| linux| +  | -  | -  |  - |
|  mac | -  |  - | -  |  - |

<!-- Win - no delay - no changes for src -->

Dst:

|   |atime|mtime| ctime  | birthtime  |
|:---:|:---:|:---:|:---:|:---:|
| win  | -  |  +  | + |  - |
| linux|  - |  + |  + | +  |
|  mac |  - |  + |  + |  - |

<!-- Mac - no delay - no changes for src/dst, needs check -->

-----

#### Modification of atime,mtime timestamps ( timeWrite )

|   |atime|mtime| ctime  | birthtime  |
|:---:|:---:|:---:|:---:|:---:|
| win  |  + |  + | +  | - |
| linux| +  |  + |  +|  + |
|  mac |  + |  + |  - |  - |

<!-- Linux - small diff between passed value and value from stats -->
<!-- Linux - updates ctime/birthtime in case with 1sec delay -->
<!-- Mac - small delays do nothing, changes are applied in case of 1sec delay -->

-----

> \+ - timestamp was updated
> \- - timestamp not changed