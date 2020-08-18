# module::Files [![status](https://img.shields.io/circleci/build/github/Wandalen/wFiles?label=Test&logo=Test)](https://circleci.com/gh/Wandalen/wFiles) [![status](https://github.com/Wandalen/wFiles/workflows/publish/badge.svg)](https://github.com/Wandalen/wFiles/actions?query=workflow%3Apublish) [![stable](https://img.shields.io/badge/stability-stable-green.svg)](https://github.com/emersion/stability-badges#stable)

Collection of classes to abstract files systems. Many interfaces provide files, but not called as file systems and treated differently. For example server-side gives access to local files and browser-side HTTP/HTTPS protocol gives access to files as well, but in the very different way, it does the first. This problem forces a developer to break fundamental programming principle DRY and make code written to solve a problem not applicable to the same problem, on another platform/technology.

Files treats any file-system-like interface as files system. Files combines all files available to the application into the single namespace where each file has unique Path/URI, so that operating with several files on different files systems is not what user of the module should worry about. If Files does not have an adapter for your files system you may design it providing a short list of stupid methods fulfilling completely or partly good defined API and get access to all sophisticated general algorithms on files for free. Is concept of file applicable to external entities of an application? Files makes possible to treat internals of a program as files system(s). Use the module to keep DRY.

Files manipulation library of middle level. Module offers several implementations  of single interface, called ( FileProvider ) to perform file operations in the same manner with different sources/destinations.

### Installation
```terminal
npm install wFiles
```

### FileProvider.HardDrive
Allows files manipulations on local drive.

###### Declaration
```javascript
let _ = wTools;
var provider = _.FileProvider.HardDrive();
```

### FileProvider.Extract
Allows file manipulations on `filesTree` - object based on some folders/files tree, where folders are nested objects with same depth level as in real folder and contains some files that are properties with corresponding names and file content as a values.

###### Structure example:
```javascript
var tree =
{
 "some_dir" :
 {
   'some_file.txt' : "content",
   'empty_dir' : {}
 }
}
```
###### Declaration
```javascript
let _ = wTools;
var provider = _.FileProvider.Extract({ filesTree : tree });
```
<!-- ###### FileProvider.Url desc here -->
### Usage:

###### Example #1
```javascript
/*Read file synchronously*/
var data = provider.fileRead( '/path/to/terminal' );
console.log( data );

/*Read file asynchronously*/
provider.fileRead({ filePath : '/path/to/terminal', sync : 0 })
.finally( function( err, data )
{
  if( err )
  throw err;
  console.log( data );
  return null;
});
```
###### Example #2
```javascript
/*Write to file synchronously*/
provider.fileWrite
({
  filePath : '/path/to/terminal',
  data : 'some data'
})

/*Write to file asynchronously*/
provider.fileWrite
({
  filePath : '/path/to/terminal',
  data : 'some data',
  sync : 0
})
.finally( function( err, got )
{
  if( err )
  throw err;
  console.log( 'Success' );
  return null;
});
```
###### Example #3
```javascript
/*Create dir synchronously*/
provider.dirMake( '/path/to/dir' );

/*Create dir asynchronously*/
provider.dirMake
({
   filePath : '/path/to/dir',
   sync : 0
 })
.finally( function( err, got )
{
  if( err )
  throw err;
  /*some code after dir creation*/
  return null;
});
```
###### Example #4
```javascript
/*Getting file stats object sync*/
/*error throwing is disabled by default, use throwing : 1 to turn on*/
var stats = provider.statRead( '/path/to/file' );
if( stats )
console.log( stats );

/*async*/
provider.fileStat
({
   filePath : '/path/to/file',
   throwing : 1,
   sync : 0
})
.finally( function( err, stats )
{
  if( err )
  throw err;
  console.log( stats );
  return null;
});
```
###### Example #5
```javascript
/*Copy file sync*/
provider.fileCopy
({
  dstPath : '/path/to/dst',
  srcPath : '/path/to/src'
});

```


<!-- # Methods -> later
If sync option is avaible - method supports sync/async modes. Use `true` for synchronous and `false` for async. In asynchronous mode [wConsequence]( https://github.com/Wandalen/wConsequence ) object is returned.
* ##### fileReadAct - returns file content in specified `encoding`.
>  - sync  { Boolean } - sync/async mode switch, default = false;
>  - filePath { String } - path to target file;
>  - encoding { String } - sets encoding, default = 'utf8'.
* ##### createReadStreamAct - creates readable stream for file specified by `filePath`.
>  - sync  { Boolean } - sync/async mode switch, default = false;
>  - filePath { String } - path to target file; -->
