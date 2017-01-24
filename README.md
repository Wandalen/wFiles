# wFiles

Files manipulation library of middle level. Module offers several implementations  of single interface, called "FileProvider's" to perform file operations on different type of resources.

##### Avaible operations:
* File read/write operations.
* Creating read/write steams.
* Operations with file [stats](https://nodejs.org/api/fs.html#fs_class_fs_stats) object.
* File create,delete,rename,copy operations.
* Making [soft](https://en.wikipedia.org/wiki/Symbolic_link)/[hard](https://en.wikipedia.org/wiki/Hard_link) links.

## FileProvider.HardDrive
Allows files manipulations on local drive.

###### Declaration
```javascript
var _ = wTools;
var provider = _.FileProvider.HardDrive();
```
<details>
<summary><b>Usage examples</b>( clickable ): </summary>
###### Example #1
```javascript
/*Read file synchronously*/
var data = provider.fileReadAct( { pathFile : 'my_file', sync : 1 } );
console.log( data );

/*Read file asynchronously*/
provider.fileReadAct( { pathFile : 'my_file' } )
.got( function( err, data )
{
  if( err )
  throw err;
  console.log( data );  
});
```
###### Example #2
```javascript
/*Write to file synchronously*/
provider.fileWriteAct( { pathFile : 'my_file', data : 'some data' } )

/*Write to file asynchronously*/
provider.fileWriteAct( { pathFile : 'my_file', data : 'some data', sync : 0 } )
.got( function( err )
{
  if( err )
  throw err;
  console.log( 'Success' );  
});
```
</details>

## FileProvider.SimpleStructure
Allows file manipulations on "filesTree" - object based on some folders/files tree, where folders are nested objects with same depth level as in real folder and contains some files that are properties with corresponding names and file content as a values.

```javascript
Simple filesTree:

{
 "some_dir" :
 {
   'some_file.txt' : "content",
   'empty_dir' : {}
 }
}
```
<!-- ###### FileProvider.Url desc here -->



---
<!-- # Methods -> later
If sync option is avaible - method supports sync/async modes. Use `true` for synchronous and `false` for async. In asynchronous mode [wConsequence]( https://github.com/Wandalen/wConsequence ) object is returned.
* ##### fileReadAct - returns file content in specified `encoding`.
>  - sync  { Boolean } - sync/async mode switch, default = false;
>  - pathFile { String } - path to target file;
>  - encoding { String } - sets encoding, default = 'utf8'.
* ##### createReadStreamAct - creates readable stream for file specified by `pathFile`.
>  - sync  { Boolean } - sync/async mode switch, default = false;
>  - pathFile { String } - path to target file; -->
