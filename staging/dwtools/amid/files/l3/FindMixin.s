( function _FindMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );

}

let _global = _global_;
let _ = _global_.wTools;
let FileRecord = _.FileRecord;

//

function onMixin( mixinDescriptor, dstClass )
{

  let dstPrototype = dstClass.prototype;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.routineIs( dstClass ) );

  _.mixinApply( this, dstPrototype );

}

// --
// etc
// --

function recordsOrder( records,orderingExclusion )
{

  _.assert( _.arrayIs( records ) );
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( !orderingExclusion.length )
  return records;

  orderingExclusion = _.RegexpObject.order( orderingExclusion || [] );

  let removed = [];
  let result = [];
  let e = 0;
  for( ; e < orderingExclusion.length ; e++ )
  result[ e ] = [];

  for( let r = 0 ; r < records.length ; r++ )
  {
    let record = records[ r ];
    for( let e = 0 ; e < orderingExclusion.length ; e++ )
    {
      let mask = orderingExclusion[ e ];
      let match = mask.test( record.relative );
      if( match )
      {
        result[ e ].push( record );
        break;
      }
    }
    if( e === orderingExclusion.length )
    removed.push( record );
  }

  return _.arrayAppendArrays( [],result );
}

//

function _filesFilterMasksSupplement( dst,src )
{
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  _.mapSupplement( dst,src );

  dst.maskDirectory = _.RegexpObject.shrink( null, dst.maskDirectory || Object.create( null ), src.maskDirectory || Object.create( null ) );
  dst.maskTerminal = _.RegexpObject.shrink( null, dst.maskTerminal || Object.create( null ), src.maskTerminal || Object.create( null ) );
  dst.maskAll = _.RegexpObject.shrink( null, dst.maskAll || Object.create( null ), src.maskAll || Object.create( null ) );

  return dst;
}

// --
// files find
// --

function _filesFindOptions( args, safe )
{
  let o;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  // _.assert( 1 <= args.length && args.length <= 3 );
  _.assert( 1 === args.length );

  if( args.length === 1 && _.routineIs( args[ 0 ] ) )
  {

    o = o || Object.create( null );
    o.onUp = args[ 0 ];

  }
  else
  {

    if( _.objectIs( args[ 0 ] ) )
    {
      o = args[ 0 ];
    }
    else
    {
      o = { filePath : args[ 0 ] };
    }

    // if( args[ 1 ] !== undefined && o.maskTerminal === undefined )
    // o.maskTerminal = args[ 1 ];

  }

  if( safe )
  {
    o.filter = o.filter || Object.create( null );
    if( o.filter.maskAll === undefined && o.filter.maskTerminal === undefined && o.filter.maskDirectory === undefined )
    o.filter.maskAll = _.files.regexpMakeSafe();
  }

  return o;
}

//
//
// function _filesFindGlobAdjust( o )
// {
//   let self = this;
//
//   if( o.filePath )
//   o.filePath = self.path.normalize( o.filePath );
//
//   if( o.basePath )
//   o.basePath = self.path.normalize( o.basePath );
//
//   if( !o.glob )
//   return;
//
//   _.assert( arguments.length === 1, 'expects single argument' );
//   _.assert( _.objectIs( o ) );
//   _.assert( _.strIs( o.glob ) || _.arrayLike( o.glob ) );
//   _.assert( o.relative === undefined );
//   _.assert( !o.globOut );
//   _.assert( o.filePath === null || self.path.isAbsolute( o.filePath ) );
//   _.assert( o.basePath === undefined );
//
//   o.glob = self.path.s.normalize( o.glob );
//
//   if( !o.filePath )
//   {
//     if( _.arrayLike( o.glob ) )
//     o.filePath = _.entityFilter( o.glob, ( glob ) => fromGlob( glob ) );
//     else
//     o.filePath = fromGlob( o.glob );
//   }
//
//   if( !o.basePath )
//   {
//     if( _.arrayLike( o.filePath ) )
//     o.basePath = self.path.common.apply( self.path, o.filePath );
//     else
//     o.basePath = o.filePath;
//   }
//
//   _.assert( _.strIs( o.filePath ) || _.strsAre( o.filePath ) );
//
//   if( _.arrayIs( o.glob ) )
//   o.globOut = _.entityFilter( o.glob, ( glob ) => globAdjust( glob ) );
//   else
//   o.globOut = globAdjust( o.glob );
//
//   o.glob = null;
//
//   /* */
//
//   function fromGlob( glob )
//   {
//     let result;
//     _.assert( _.strIs( glob ) );
//     let i = glob.search( /[^\\\/]*?(\*\*|\?|\*|\[.*\]|\{.*\}+(?![^[]*\]))[^\\\/]*/ );
//     if( i === -1 )
//     result = glob;
//     else
//     result = self.path.normalize( glob.substr( 0,i ) );
//     if( !result )
//     result = self.path.realMainDir();
//     return result;
//   }
//
//   /* */
//
//   function globAdjust( glob )
//   {
//
//     let basePath = _.strAppendOnce( o.basePath,'/' );
//     if( !_.strBegins( glob,basePath ) )
//     basePath = o.basePath;
//
//     if( _.strBegins( glob,basePath ) )
//     {
//       glob = glob.substr( basePath.length, glob.length );
//     }
//
//     return glob;
//   }
//
// }
//
//
//
// function _filesFindMasksAdjust( o )
// {
//   let self = this;
//   let path = self.path;
//
//   if( o.filePath )
//   o.filePath = path.normalize( o.filePath );
//
//   // if( o.basePath )
//   // o.basePath = path.normalize( o.basePath );
//
//   if( Config.debug )
//   {
//
//     _.assert( arguments.length === 1, 'expects single argument' );
//     _.assert( _.mapIs( o ) );
//     _.assert( o.basePath === undefined );
//
//     let isAbsolute1 = ( path.is( o.filePath ) && path.isAbsolute( o.filePath ) );
//     let isAbsolute2 = ( path.are( o.filePath ) && _.all( path.s.areAbsolute( o.filePath ) ) );
//     _.assert( o.filePath === null || isAbsolute1 || isAbsolute2 );
//
//   }
//
//   o.maskAll = _.regexpMakeObject( o.maskAll || Object.create( null ),'includeAny' );
//   o.maskTerminal = _.regexpMakeObject( o.maskTerminal || Object.create( null ),'includeAny' );
//   o.maskDirectory = _.regexpMakeObject( o.maskDirectory || Object.create( null ),'includeAny' );
//
//   if( o.hasExtension )
//   {
//     _.assert( _.strIs( o.hasExtension ) || _.strsAre( o.hasExtension ) );
//
//     o.hasExtension = _.arrayAs( o.hasExtension );
//     o.hasExtension = new RegExp( '^\\.\\/.+\\.(' + _.regexpsEscape( o.hasExtension ).join( '|' ) + ')$', 'i' );
//
//     _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.hasExtension } );
//     o.hasExtension = null;
//   }
//
//   if( o.begins )
//   {
//     _.assert( _.strIs( o.begins ) || _.strsAre( o.begins ) );
//
//     o.begins = _.arrayAs( o.begins );
//     o.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( o.begins ).join( '|' ) + ')' );
//
//     o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.begins } );
//     o.begins = null;
//   }
//
//   if( o.ends )
//   {
//     _.assert( _.strIs( o.ends ) || _.strsAre( o.ends ) );
//
//     o.ends = _.arrayAs( o.ends );
//     o.ends = new RegExp( '(' + _.regexpsEscape( o.ends ).join( '|' ) + ')$' );
//
//     o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.ends } );
//     o.ends = null;
//   }
//
//   /* */
//
//   if( o.globOut )
//   {
//     // let globRegexp = self.path.globRegexpsForTerminalSimple( o.globOut );
//     let globRegexp = self.path.globRegexpsForTerminal( o.globOut );
//     o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : globRegexp } );
//   }
//   o.globOut = null;
//   delete o.globOut;
//
//   /* */
//
//   if( o.notOlder )
//   _.assert( _.numberIs( o.notOlder ) );
//
//   if( o.notNewer )
//   _.assert( _.numberIs( o.notNewer ) );
//
//   return o;
// }
//
// _filesFindMasksAdjust.defaults =
// {
//
//   hasExtension : null,
//   begins : null,
//   ends : null,
//
//   // glob : null,
//
//   maskAll : null,
//   maskTerminal : null,
//   maskDirectory : null,
//
//   notOlder : null,
//   notNewer : null,
//   notOlderAge : null,
//   notNewerAge : null,
//
//   // xxx
//
// }

//

function _filesFilterForm( o )
{
  let self = this;

  _.assert( !o.filter || !o.filter.formed, 'Filter is already formed, but should not be!' )

  // if( o.filter && o.filter.formed )
  // {
  //   // debugger;
  //   // _.assertMapHasNone( o,_filesFilterForm.defaults );
  //   // debugger;
  //   _.assert( _.entityIdentical( o.filePath, o.filter.branchPath ) );
  //   return o;
  // }

  // let fo = _.mapOnly( o, _filesFilterForm.defaults );
  // _.mapDelete( o, _filesFilterForm.defaults );

  /* */

  o.filter = o.filter || Object.create( null );
  if( o.filter )
  o.filter = self.fileRecordFilter( o.filter );
  // if( o.filter )
  // o.filter.and( fo );
  // else
  // o.filter = self.fileRecordFilter( fo );

  /* */

  // _.assert( o.filter.fileProvider === null || o.filter.fileProvider === self );

  o.filter.fileProvider = self;

  o.filter.fromOptions( o );

  o.filter.form();

  o.filter.toOptions( o );

  _.assert( arguments.length === 1, 'expects single argument' );

  return o;
}

_.assert( _.objectIs( _.FileRecordFilter.prototype.Composes ) );
_filesFilterForm.defaults = Object.create( _.FileRecordFilter.prototype.Composes );

//

function __filesFind_pre( routine, args, safe )
{
  let self = this;
  let path = self.path;
  let o = self._filesFindOptions( args, safe );

  _.routineOptions( routine,o );

  if( o.filePath )
  o.filePath = path.s.normalize( o.filePath );

  // if( o.basePath )
  // o.basePath = path.s.normalize( o.basePath );
  // if( o.prefixPath )
  // o.prefixPath = path.s.normalize( o.prefixPath );
  // if( o.postfixPath )
  // o.postfixPath = path.s.normalize( o.postfixPath );

  if( Config.debug )
  {

    _.assert( arguments.length === 3 );
    _.assert( 1 <= args.length && args.length <= 3 );
    _.assert( o.basePath === undefined );
    _.assert( o.prefixPath === undefined );
    _.assert( o.postfixPath === undefined );

    // let isAbsolute1 = ( path.is( o.prefixPath ) && path.isAbsolute( o.prefixPath ) );
    // let isAbsolute2 = ( path.are( o.prefixPath ) && _.all( path.s.areAbsolute( o.prefixPath ) ) );
    //
    // _.assert( o.prefixPath === null || isAbsolute1 || isAbsolute2 );

  }

  // if( o.prefixPath === null )
  // o.prefixPath = o.basePath;
  // else if( o.basePath === null )
  // o.basePath = o.prefixPath;

  self._filesFilterForm( o );

  // if( o.prefixPath === null )
  // o.prefixPath = o.basePath;
  // else if( o.basePath === null )
  // o.basePath = o.prefixPath;

  return o;
}

//

function _filesFind_pre( routine, args )
{
  let self = this;
  let path = self.path;
  return self.__filesFind_pre( routine, args, 1 )
}

//

/*
o1 =
"{
  glob : [ '/dir1/dir2a/app/proto/**', '/dir1/dir2b/app/**' ],
  maskAll :
  wRegexpObject(  )
{
    includeAny : [],
    includeAll : [],
    excludeAny :
    [
      /(\W|^)node_modules(\W|$)/,
      /\.unique$/,
      /\.git$/,
      /\.svn$/,
      /\.hg$/,
      /\.tmp($|\/)/,
      /(^|\/)\.(?!$|\/)/,
      /\.\/file($|\/)/,
      /node_modules/,
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/
    ],
    excludeAll : []
  },
  onUp : [ routine onFile ],
  includingTerminals : 1,
  includingTransients : 1,
  recursive : 1
}"

op2
{
  onUp :
  [
    [ routine onFile ]
  ],
  includingTerminals : 1,
  includingTransients : 1,
  recursive : 1,
  orderingExclusion : [],
  sortingWithArray : null,
  verbosity : 0,
  filePath : [ '/dir1/dir2a/app/proto', '/dir1/dir2b/app' ],
  basePath : '/dir1',
  ignoringNonexistent : 0,
  includingBase : 1,
  resolvingSoftLink : 1,
  resolvingTextLink : 0,
  outputFormat : 'record',
  onDown : [],
  fileProviderEffective : null,
  filter :
  wFileRecordFilter(  )
{
    glob : null,
    hasExtension : null,
    begins : null,
    ends : null,
    maskAll :
    wRegexpObject(  )
{
      includeAny : [],
      includeAll : [],
      excludeAny :
      [
        /(\W|^)node_modules(\W|$)/,
        /\.unique$/,
        /\.git$/,
        /\.svn$/,
        /\.hg$/,
        /\.tmp($|\/)/,
        /(^|\/)\.(?!$|\/)/,
        /\.\/file($|\/)/,
        /node_modules/,
        /(^|\/)\.(?!$|\/|\.)/,
        /(^|\/)-/
      ],
      excludeAll : []
    },
    maskTerminal :
    wRegexpObject(  )
{
      includeAny : [],
      includeAll :
      [
        /^\.\/(dir2a\/app\/proto\/.*)|(dir2b\/app\/.*)$/m
      ],
      excludeAny : [],
      excludeAll : []
    },
    maskDirectory :
    wRegexpObject(  )
{
      includeAny : [],
      includeAll : [],
      excludeAny : [],
      excludeAll : []
    },
    notOlder : null,
    notNewer : null,
    notOlderAge : null,
    notNewerAge : null,
    filePath : [ '/dir1/dir2a/app/proto', '/dir1/dir2b/app' ],
    basePath : '/dir1',
    test : [ routine _testMasks ]
  }
}"

absolute : /dir/dir2b/app/builder/include/dwtools/atop/tester/_zTest.ss
real : /dir/dir2a/app/builder/include/dwtools/atop/tester/_zTest.ss
real relative : ./dir2a/app/builder/include/dwtools/atop/tester/_zTest.ss
`
filter : includeAll : /^\.\/(dir2a\/app\/proto\/.*)|(dir2ab\/app\/.*)$/m

*/

function _filesFindFast( o )
{
  let self = this;
  let path = self.path;

  if( !o.fileProviderEffective )
  if( _.uri.isGlobal( o.filePath ) )
  {
    o.fileProviderEffective = self.providerForPath( o.filePath );
    _.assert( _.objectIs( o.fileProviderEffective ) );
    o.filePath = o.fileProviderEffective.localFromUri( o.filePath );
  }
  else
  {
    o.fileProviderEffective = self.providerForPath( o.filePath );
  }

  // if( o.basePath === undefined || o.basePath === null )
  // o.basePath = o.filePath;

  _.assert( _.objectIs( o.fileProviderEffective ) );

  o.fileProviderEffective._providerOptions( o ); /* xxx */

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( _filesFindFast, o );
  _.assert( _.routineIs( o.onUp ) || _.arrayIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) || _.arrayIs( o.onDown ) );
  _.assert( path.isNormalized( o.filePath ) );
  _.assert( path.isAbsolute( o.filePath ), 'expects absolute path {-o.filePath-}' );
  // _.assert( path.isAbsolute( o.basePath ), 'expects absolute path {-o.basePath-}' );
  _.assert( _.mapIs( o.filter.basePath ), 'expects absolute path {-o.filter.basePath-}' );
  _.assert( !!o.filter.formed );

  /* handler */

  if( _.arrayIs( o.onUp ) )
  if( o.onUp.length === 0 )
  o.onUp = function( record ){ return record };
  else
  o.onUp = _.routinesComposeEveryReturningLast( o.onUp );

  if( _.arrayIs( o.onDown ) )
  o.onDown = _.routinesCompose( o.onDown );

  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );

  /* */

  let result = o.result = o.result || [];

  Object.freeze( o );

  _.assert( !_.uri.isGlobal( o.filePath ) );

  if( o.ignoringNonexistent )
  if( !o.fileProviderEffective.fileStat( o.filePath ) )
  return result;

  let resultAdd = resultAdd_functor( o );

  forPath( o.filePath, o, true );

  return result;

  /* */

  function handleUp( record, op )
  {
    _.assert( arguments.length === 2 );

    record = op.onUp.call( self, record, op );

    return record;
  }

  /* */

  function handleDown( record, op )
  {
    _.assert( arguments.length === 2 );

    record = op.onDown.call( self, record, op );

    return record;
  }

  /* add result */

  function resultAdd_functor( o )
  {
    let resultAdd;

    if( o.outputFormat === 'absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record.absolute );
    }
    else if( o.outputFormat === 'relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record.relative );
    }
    else if( o.outputFormat === 'record' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    resultAdd = function( record )
    {
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return resultAdd;
  }

  /* */

  function forPath( filePath, o )
  {
    // if( o.filter.basePath === 'tmp:///' )
    // debugger;

    let dir = filePath;
    // let o2 = { fileProvider : self, branchPath : path.join( o.basePath, filePath ) }; /* xxx */
    let o2 = { fileProvider : self, branchPath : filePath, basePath : o.filter.basePath[ filePath ] }; /* xxx */

    _.assert( _.strIsNotEmpty( o2.basePath ), 'No base path for', filePath );

    let recordContext = _.FileRecordContext.TollerantMake( o, o2 ).form();
    let record = o.fileProviderEffective.fileRecord( filePath, recordContext ); /* xxx : remove routine fileRecord */

    // if( !record.isBranch )
    // debugger;

    // _.assert( _.strIs( o.basePath ) );
    _.assert( recordContext.dirPath === null );
    _.assert( record.isBranch === true );

    forFile( record, o );
  }

  /* */

  function forFile( record, o )
  {
    if( record.isDir )
    forDirectory( record, o )
    else
    forTerminal( record, o )
  }

  /* */

  function forDirectory( r, o )
  {

    if( !r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    let or = r;
    let isTransient = r.isTransient;
    let includingTransients = ( o.includingTransients && r.isTransient && o.includingDirectories );
    let includingActuals = ( o.includingActual && r.isActual && o.includingDirectories );
    let including = true;
    including = including && ( includingTransients || includingActuals );
    including = including && ( o.includingBase || !r.isBranch );

    /* up */

    if( including )
    {
      r = handleUp( r, o );

      _.assert( r === false || _.objectIs( r ) );

      if( r === false )
      return false;

      resultAdd( r );
    }

    /* read */

    if( isTransient )
    if( o.recursive || or.isBranch )
    {

      let files = o.fileProviderEffective.directoryRead({ filePath : or.absolute, outputFormat : 'absolute' });

      if( o.ignoringNonexistent )
      if( files === null )
      files = [];

      files = self.fileRecords( files, or.context );

      /* terminals */

      if( o.includingTerminals )
      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forTerminal( file, o );
      }

      /* dirs */

      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forDirectory( file, o );
      }

    }

    /* down */

    if( including )
    handleDown( r, o );

  }

  /* */

  function forTerminal( r, o )
  {

    if( r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    let or = r;
    let includingTransients = ( o.includingTransients && r.isTransient && o.includingTerminals );
    let includingActuals = ( o.includingActual && r.isActual && o.includingTerminals );
    let including = true;
    including = including && ( includingTransients || includingActuals );
    including = including && ( o.includingBase || !or.isBranch );

    if( !including )
    return;

    r = handleUp( r, o );

    _.assert( r === false || _.objectIs( r ) );

    if( r === false )
    return false;

    resultAdd( r );

    handleDown( r, o );
  }

}

_filesFindFast.defaults =
{

  filePath : null,

  // basePath : null,
  // prefixPath : null,
  // postfixPath : null,

  ignoringNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 0,
  includingActual : 1,
  includingTransients : 0,
  includingBase : 1,

  recursive : 0,
  resolvingSoftLink : 1,
  resolvingTextLink : 0,

  outputFormat : 'record',
  result : [],

  onUp : [],
  onDown : [],

  fileProviderEffective : null,
  filter : null,

}

_filesFindFast.paths =
{
  filePath : null,
  // basePath : null,
  // prefixPath : null,
  // postfixPath : null,
}

var having = _filesFindFast.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

//

function _filesFind_body( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  // if( !o.filePath )
  // _.assert( o.glob, 'filesFind expects {-o.filePath-} or {-o.glob-}' );

  _.assert( !!o.filePath, 'filesFind expects {-o.filePath-} or {-o.glob-}' );

  if( !_.arrayIs( o.onUp ) )
  o.onUp = o.onUp ? [ o.onUp ] : [];
  if( !_.arrayIs( o.onDown ) )
  o.onDown = o.onDown ? [ o.onDown ] : [];

  _.assert( !!o.filePath,'filesFind :','expects "filePath"' );

  let time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  if( o.verbosity >= 3 )
  logger.log( 'filesFind',_.toStr( o,{ levels : 2 } ) );

  o.filePath = _.arrayAs( o.filePath );

  o.result = o.result || [];

  /* find */

  _.assert( !o.orderingExclusion.length || o.orderingExclusion.length === 0 || o.outputFormat === 'record' );

  forPaths( o.filePath,_.mapExtend( null,o ) );

  /* order */

  o.result = self.recordsOrder( o.result, o.orderingExclusion );

  // let orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );
  // if( !orderingExclusion.length )
  // {
  //   forPaths( o.filePath,_.mapExtend( null,o ) );
  // }
  // else
  // {
  //   let maskTerminal = o.maskTerminal;
  //   for( let e = 0 ; e < orderingExclusion.length ; e++ )
  //   {
  //     o.maskTerminal = _.RegexpObject.shrink( Object.create( null ),maskTerminal,orderingExclusion[ e ] );
  //     forPaths( o.filePath,_.mapExtend( null,o ) );
  //   }
  // }

  /* sort */

  if( o.sortingWithArray )
  {

    _.assert( _.arrayIs( o.sortingWithArray ) );

    if( o.outputFormat === 'record' )
    o.result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortingWithArray,a.relative ) - _.regexpArrayIndex( o.sortingWithArray,b.relative );
    })
    else
    o.result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortingWithArray,a ) - _.regexpArrayIndex( o.sortingWithArray,b );
    });

  }

  /* mandatory */

  if( o.mandatory )
  if( !o.result.length )
  {
    debugger;
    throw _.err( 'No file found at ' + ( o.filter.glob || o.filePath ) );
  }

  /* timing */

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesFind ' + o.result.length + ' files at ' + o.filePath + ' in',time ) );

  return o.result;

  /* find for several paths */

  function forPaths( paths,o )
  {

    if( _.strIs( paths ) )
    paths = [ paths ];
    paths = _.arrayUnique( paths );

    _.assert( _.arrayIs( paths ), 'expects path or array of paths' );

    for( let p = 0 ; p < paths.length ; p++ )
    {
      let filePath = paths[ p ];
      let options = Object.assign( Object.create( null ), o );

      delete options.prefixPath;
      delete options.postfixPath;
      delete options.mandatory;
      delete options.orderingExclusion;
      delete options.sortingWithArray;
      delete options.verbosity;
      options.filePath = filePath;

      self._filesFindFast( options );
    }

  }

}

_.routineExtend( _filesFind_body, _filesFindFast );

var defaults = _filesFind_body.defaults;

// defaults.prefixPath = null;
// defaults.postfixPath = null;

defaults.orderingExclusion = [];
defaults.sortingWithArray = null;
defaults.verbosity = null;
defaults.mandatory = 0;

// _.mapExtend( defaults, _filesFilterForm.defaults );
// _.assert( defaults.maskAll !== undefined );
_.assert( defaults.maskAll === undefined );
_.assert( defaults.glob === undefined );

let filesFind = _.routineForPreAndBody( _filesFind_pre, _filesFind_body );

filesFind.having.aspect = 'entry';

//

function filesFindRecursive( o )
{
  let self = this;

  o = self.filesFindRecursive.pre.call( self, self.filesFindRecursive, arguments );

  if( o.filePath === null )
  {
    debugger;
    _.assert( 0, 'not tested' );
    o.filePath = '/';
  }

  return self.filesFind.body.call( self, o );
}

_.routineExtend( filesFindRecursive, filesFind );

var defaults = filesFindRecursive.defaults;

defaults.filePath = null;
defaults.recursive = 1;
defaults.includingTransients = 0;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;

//

function filesGlob( o )
{
  let self = this;

  if( _.strIs( o ) )
  o = { filePath : o }

  if( o.recursive === undefined )
  o.recursive = 1;

  o.filter = o.filter || Object.create( null );

  // if( !o.filter.filePath )
  if( o.filePath )
  {
    // o.filter.filePath = o.filePath;
    // o.filePath = null;
  }
  else
  {
    o.filePath = o.recursive ? '**' : '*';
  }

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.objectIs( o ) );
  // _.assert( _.strIs( o.filter.filePath ) || _.arrayIs( o.filter.filePath ) || _.mapIs( o.filter.filePath ) );

  let result = self.filesFind( o );

  return result;
}

_.routineExtend( filesGlob, filesFind );

var defaults = filesGlob.defaults;

defaults.outputFormat = 'absolute';
defaults.recursive = 1;
defaults.includingTerminals = 1;
defaults.includingDirectories = 1;
defaults.includingTransients = 0;

//

function filesFinder()
{
  let self = this;
  let op0 = self._filesFindOptions( arguments, 1 );

  _.assertMapHasOnly( op0, filesFinder.defaults );
  // _.assert( !!op0.prefixPath );

  // op0.prefixPath = op0.prefixPath || '';
  // op0.prefixPath = op0.prefixPath || null;
  op0.filter = op0.filter || Object.create( null );
  op0.filter.fileProvider = self;

  return er;

  function er( op1, op2 )
  {

    if( !_.objectIs( op1 ) )
    if( op2 !== undefined )
    op1 = { filter : { prefixPath : op1 } }
    else
    op1 = { filePath : op1 }

    if( !_.objectIs( op2 ) )
    op2 = { filePath : op2 }

    op2 = op2 || Object.create( null );

    op1.filter = op1.filter || Object.create( null );
    op2.filter = op2.filter || Object.create( null );

    _.assert( arguments.length === 1 || arguments.length === 2 );

    let o = _.mapExtend( null, op0, op1, op2 );

    debugger;
    o.filter = _.FileRecordFilter.And( null, op0.filter, op1.filter, op2.filter );
    o.filter.pathsJoin( op0.filter, op1.filter, op2.filter );
    o.filePath = self.path.s.joinIfDefined( op0.filePath, op1.filePath, op2.filePath );
    // o.filter.prefixPath = self.path.s.joinIfDefined( null, op0.filter.prefixPath, op1.filter.prefixPath, op2.filter.prefixPath );
    // o.filter.postfixPath = self.path.s.joinIfDefined( null, op0.filter.postfixPath, op1.filter.postfixPath, op2.filter.postfixPath );
    debugger;

    return self.filesFind( o );
  }

}

_.routineExtend( filesFinder, filesFind );

//

function filesGlober()
{
  let self = this;
  let op0 = self._filesFindOptions( arguments, 1 );

  _.assertMapHasOnly( op0, filesFinder.defaults );
  // _.assert( !!op0.prefixPath );

  // op0.prefixPath = op0.prefixPath || '';
  // op0.prefixPath = op0.prefixPath || null;
  op0.filter = op0.filter || Object.create( null );
  op0.filter.fileProvider = self;

  return er;

  function er( op1, op2 )
  {

    if( !_.objectIs( op1 ) )
    if( op2 !== undefined )
    op1 = { filter : { prefixPath : op1 } }
    else
    op1 = { filePath : op1 }

    if( !_.objectIs( op2 ) )
    op2 = { filePath : op2 }

    op2 = op2 || Object.create( null );

    op1.filter = op1.filter || Object.create( null );
    op2.filter = op2.filter || Object.create( null );

    _.assert( arguments.length === 1 || arguments.length === 2 );

    let o = _.mapExtend( null, op0, op1, op2 );

    debugger;
    o.filter = _.FileRecordFilter.And( null, op0.filter, op1.filter, op2.filter );
    o.filter.pathsJoin( op0.filter, op1.filter, op2.filter );
    o.filePath = self.path.s.joinIfDefined( op0.filePath, op1.filePath, op2.filePath );
    // o.filter.prefixPath = self.path.s.joinIfDefined( null, op0.filter.prefixPath, op1.filter.prefixPath, op2.filter.prefixPath );
    // o.filter.postfixPath = self.path.s.joinIfDefined( null, op0.filter.postfixPath, op1.filter.postfixPath, op2.filter.postfixPath );
    debugger;

    return self.filesGlob( o );
  }

}

_.routineExtend( filesFinder, filesFind );

// --
// difference
// --
//
// function filesFindDifference( dst,src,o )
// {
//   let self = this;
//   // let providerIsHub = _.FileProvider.Hub && self instanceof _.FileProvider.Hub;
//
//   /* options */
//
//   if( _.objectIs( dst ) )
//   {
//     o = dst;
//     dst = o.dst;
//     src = o.src;
//   }
//
//   o = ( o || Object.create( null ) );
//   o.dst = dst;
//   o.src = src;
//
//   _.assert( arguments.length === 1 || arguments.length === 3 );
//   _.routineOptions( filesFindDifference,o );
//   self._providerOptions( o );
//   self._filesFindGlobAdjust( o );
//   self._filesFindMasksAdjust( o );
//
//   _.strIs( o.dst );
//   _.strIs( o.src );
//
//   let ext = o.ext;
//   let result = o.result = o.result || [];
//
//   if( o.read !== undefined || o.hash !== undefined || o.latters !== undefined )
//   throw _.err( 'such options are deprecated',_.toStr( o ) );
//
//   /* */
//
//   function resultAdd_functor( o )
//   {
//     let resultAdd;
//
//     if( o.outputFormat === 'absolute' )
//     resultAdd = function( record )
//     {
//       o.result.push([ record.src.absolute,record.dst.absolute ]);
//     }
//     else if( o.outputFormat === 'relative' )
//     resultAdd = function( record )
//     {
//       o.result.push([ record.src.relative,record.dst.relative ]);
//     }
//     else if( o.outputFormat === 'record' )
//     resultAdd = function( record )
//     {
//       o.result.push( record );
//     }
//     else if( o.outputFormat === 'nothing' )
//     resultAdd = function( record )
//     {
//     }
//     else throw _.err( 'unexpected output format :',o.outputFormat );
//
//     return resultAdd;
//   }
//
//   let resultAdd = resultAdd_functor( o );
//
//   /* safety */
//
//   o.dst = self.path.normalize( o.dst );
//   o.src = self.path.normalize( o.src );
//
//   if( o.src !== o.dst && _.strBegins( o.src,o.dst ) )
//   {
//     debugger;
//     throw _.err( 'Overwrite of itself','\nsrc :',o.src,'\ndst :',o.dst )
//   }
//
//   if( o.src !== o.dst && _.strBegins( o.dst,o.src ) )
//   {
//     let exclude = '^' + o.dst.substr( o.src.length+1 ) + '($|\/)';
//     _.RegexpObject.shrink( o.maskAll,{ excludeAny : new RegExp( exclude ) } );
//   }
//
//   /* dst */
//
//   let dstOptions =
//   {
//     dirPath : dst,
//     basePath : dst,
//     fileProvider : self,
//     strict : 0,
//   }
//
//   if( dstOptions.fileProvider.providerForPath )
//   {
//     dstOptions.fileProvider = dstOptions.fileProvider.providerForPath( dst );
//     dstOptions.dir = dstOptions.fileProvider.localFromUri( dstOptions.dir );
//     dstOptions.basePath = dstOptions.fileProvider.localFromUri( dstOptions.basePath );
//   }
//
//   dstOptions = _.FileRecordContext.TollerantMake( o,dstOptions );
//
//   /* src */
//
//   let srcOptions =
//   {
//     dirPath : src,
//     basePath : src,
//     fileProvider : self,
//     strict : 0,
//   }
//
//   if( srcOptions.fileProvider.providerForPath )
//   {
//     srcOptions.fileProvider = srcOptions.fileProvider.providerForPath( src );
//     srcOptions.dir = srcOptions.fileProvider.localFromUri( srcOptions.dir );
//     srcOptions.basePath = srcOptions.fileProvider.localFromUri( srcOptions.basePath );
//   }
//
//   srcOptions = _.FileRecordContext.TollerantMake( o,srcOptions );
//
//   /* src file */
//
//   function srcFile( dstOptions,srcOptions,file )
//   {
//
//     let srcRecord = new FileRecord( file,_.FileRecordContext( srcOptions ) );
//     srcRecord.side = 'src';
//
//     if( srcRecord.isDir )
//     return;
//     if( !srcRecord.isActual )
//     return;
//
//     let dstRecord = new FileRecord( file,_.FileRecordContext( dstOptions ) );
//     dstRecord.side = 'dst';
//     if( _.strIs( ext ) && !dstRecord.isDir )
//     {
//       dstRecord.absolute = self.path.changeExt( dstRecord.absolute,ext );
//       dstRecord.relative = self.path.changeExt( dstRecord.relative,ext );
//     }
//
//     let record =
//     {
//       relative : srcRecord.relative,
//       dst : dstRecord,
//       src : srcRecord,
//       newer : srcRecord,
//       older : null,
//     }
//
//     _.assert( !!srcRecord.stat, 'cant get stat of', srcRecord.absolute );
//
//     if( dstRecord.stat )
//     {
//
//       if( srcRecord.hash === undefined )
//       if( srcRecord.stat.size > o.maxSize )
//       srcRecord.hash = NaN;
//
//       if( dstRecord.hash === undefined )
//       if( dstRecord.stat.size > o.maxSize )
//       dstRecord.hash = NaN;
//
//       if( !dstRecord.isDir )
//       {
//         record.same = self.filesAreSame( dstRecord, srcRecord );
//         record.link = self.filesAreHardLinked( dstRecord.absolute, srcRecord.absolute );
//       }
//       else
//       {
//         record.same = false;
//         record.link = false;
//       }
//
//       record.newer = _.files.filesNewer( dstRecord, srcRecord );
//       record.older = _.files.filesOlder( dstRecord, srcRecord );
//
//     }
//
//     _.routinesCallEvery( o,o.onUp,[ record ] );
//     resultAdd( record );
//     _.routinesCall( self,o.onDown,[ record ] );
//
//   }
//
//   /* src directory */
//
//   function srcDir( dstOptions,srcOptions,file,recursive )
//   {
//
//     let srcRecord = new FileRecord( file,srcOptions );
//     srcRecord.side = 'src';
//
//     if( !srcRecord.isDir )
//     return;
//     if( !srcRecord.isActual )
//     return;
//
//     let dstRecord = new FileRecord( file,dstOptions );
//     dstRecord.side = 'dst';
//
//     /**/
//
//     let record;
//
//     if( o.includingDirectories )
//     {
//
//       record =
//       {
//         relative : srcRecord.relative,
//         dst : dstRecord,
//         src : srcRecord,
//         newer : srcRecord,
//         older : null,
//       }
//
//       if( dstRecord.stat )
//       {
//         record.newer = _.files.filesNewer( dstRecord, srcRecord );
//         record.older = _.files.filesOlder( dstRecord, srcRecord );
//         if( !dstRecord.isDir )
//         record.same = false;
//       }
//
//       _.routinesCallEvery( o,o.onUp,[ record ] );
//       resultAdd( record );
//
//     }
//
//     if( o.recursive && recursive )
//     {
//
//       _.assert( dstOptions instanceof _.FileRecordContext );
//       _.assert( srcOptions instanceof _.FileRecordContext );
//
//       let dstOptionsSub = _.FileRecordContext.TollerantMake( dstOptions, { dirPath : dstRecord.absolute } ).form();
//       let srcOptionsSub = _.FileRecordContext.TollerantMake( srcOptions, { dirPath : srcRecord.absolute } ).form();
//
//       filesFindDifferenceAct( dstOptionsSub,srcOptionsSub );
//     }
//
//     if( o.includingDirectories )
//     _.routinesCall( self,o.onDown,[ record ] );
//
//   }
//
//   /* dst file */
//
//   function dstFile( dstOptions,srcOptions,file )
//   {
//     let srcRecord = new FileRecord( file,srcOptions );
//     srcRecord.side = 'src';
//     let dstRecord = new FileRecord( file,dstOptions );
//     dstRecord.side = 'dst';
//     if( ext !== undefined && ext !== null && !dstRecord.isDir )
//     {
//       dstRecord.absolute = self.path.changeExt( dstRecord.absolute,ext );
//       dstRecord.relative = self.path.changeExt( dstRecord.relative,ext );
//     }
//
//     if( dstRecord.isDir )
//     return;
//
//     let check = false;
//     check = check || !srcRecord.isActual;
//     check = check || !srcRecord.stat;
//
//     if( !check )
//     return;
//
//     let record =
//     {
//       relative : srcRecord.relative,
//       dst : dstRecord,
//       src : srcRecord,
//       del : true,
//       newer : dstRecord,
//       older : null,
//     };
//
//     if( srcRecord.stat )
//     {
//       record.newer = _.files.filesNewer( dstRecord, srcRecord );
//       record.older = _.files.filesOlder( dstRecord, srcRecord );
//     }
//
//     delete srcRecord.stat;
//
//     _.routinesCallEvery( o,o.onUp,[ record ] );
//     resultAdd( record );
//     _.routinesCall( self,o.onDown,[ record ] );
//
//   }
//
//   /* dst directory */
//
//   function dstDir( dstOptions,srcOptions,file,recursive )
//   {
//
//     let srcRecord = new FileRecord( file,srcOptions );
//     srcRecord.side = 'src';
//     let dstRecord = new FileRecord( file,dstOptions );
//     dstRecord.side = 'dst';
//
//     if( !dstRecord.isDir )
//     return;
//
//     let check = false;
//     check = check || !srcRecord.isActual;
//     check = check || !srcRecord.stat;
//     check = check || !srcRecord.isDir;
//
//     if( !check )
//     return;
//
//     let record;
//
//     if( o.includingDirectories && ( !srcRecord.isActual || !srcRecord.stat ) )
//     {
//
//       record =
//       {
//         relative : srcRecord.relative,
//         dst : dstRecord,
//         src : srcRecord,
//         del : true,
//         newer : dstRecord,
//         older : null,
//       };
//
//       if( srcRecord.stat )
//       {
//         record.newer = _.files.filesNewer( dstRecord, srcRecord );
//         record.older = _.files.filesOlder( dstRecord, srcRecord );
//       }
//
//
//       _.routinesCallEvery( o,o.onUp,[ record ] );
//       resultAdd( record );
//
//     }
//
//     if( o.recursive && recursive )
//     {
//
//       let found = self.filesFind
//       ({
//         includingDirectories : o.includingDirectories,
//         includingTerminals : o.includingTerminals,
//         filePath : dstRecord.absolute,
//         outputFormat : 'record',
//         recursive : 1,
//       })
//
//       _.assert( srcOptions instanceof _.FileRecordContext );
//       let srcOptionsSub = _.FileRecordContext.TollerantMake( srcOptions, { dirPath : null } ).form();
//
//       if( found.length && found[ 0 ].absolute === dstRecord.absolute )
//       found.splice( 0, 1 );
//
//       for( let fo = 0 ; fo < found.length ; fo++ )
//       {
//         let dstRecord = new FileRecord( found[ fo ].absolute,dstOptions );
//         dstRecord.side = 'dst';
//         let srcRecord = new FileRecord( dstRecord.relative,srcOptionsSub );
//         srcRecord.side = 'src';
//         let rec =
//         {
//           relative : srcRecord.relative,
//           dst : dstRecord,
//           src : srcRecord,
//           del : true,
//           newer : dstRecord,
//           older : null,
//         }
//
//         if( srcRecord.stat )
//         {
//           rec.newer = _.files.filesNewer( dstRecord, srcRecord );
//           rec.older = _.files.filesOlder( dstRecord, srcRecord );
//         }
//
//         found[ fo ] = rec;
//         _.routinesCallEvery( o,o.onUp,[ rec ] );
//         resultAdd( rec );
//       }
//
//       if( o.onDown.length )
//       for( let fo = found.length-1 ; fo >= 0 ; fo-- )
//       {
//         _.routinesCall( self,o.onDown,[ found[ fo ] ] );
//       }
//
//     }
//
//     if( record )
//     _.routinesCall( self,o.onDown,[ record ] );
//
//   }
//
//   /* act */
//
//   function filesFindDifferenceAct( dstOptions,srcOptions )
//   {
//
//     /* dst */
//
//     let dstRecord = new FileRecord( dstOptions.dir,dstOptions );
//     if( o.investigateDestination )
//     if( dstRecord.stat && dstRecord.stat.isDirectory() )
//     {
//
//       let files = self.directoryRead( dstRecord.absoluteEffective );
//       if( !files )
//       debugger;
//
//       if( o.includingTerminals )
//       for( let f = 0 ; f < files.length ; f++ )
//       dstFile( dstOptions,srcOptions,files[ f ] );
//
//       for( let f = 0 ; f < files.length ; f++ )
//       dstDir( dstOptions,srcOptions,files[ f ],1 );
//
//     }
//
//     /* src */
//
//     let srcRecord = new FileRecord( srcOptions.dir,srcOptions );
//     if( srcRecord.stat && srcRecord.stat.isDirectory() )
//     {
//
//       let files = self.directoryRead( srcRecord.absoluteEffective );
//       if( !files )
//       debugger;
//
//       if( o.includingTerminals )
//       for( let f = 0 ; f < files.length ; f++ )
//       srcFile( dstOptions,srcOptions,files[ f ] );
//
//       for( let f = 0 ; f < files.length ; f++ )
//       srcDir( dstOptions,srcOptions,files[ f ],1 );
//
//     }
//
//   }
//
//   /* launch */
//
//   dstFile( dstOptions,srcOptions,'.' );
//   dstDir( dstOptions,srcOptions,'.',1 );
//
//   srcFile( dstOptions,srcOptions,'.' );
//   srcDir( dstOptions,srcOptions,'.',1 );
//
//   return result;
// }
//
// filesFindDifference.defaults =
// {
//   outputFormat : 'record',
//   ext : null,
//   investigateDestination : 1,
//
//   maxSize : 1 << 21,
//   usingTime : 1,
//   recursive : 0,
//
//   includingTerminals : 1,
//   includingDirectories : 1,
//
//   resolvingSoftLink : 0,
//   resolvingTextLink : 0,
//
//   filter : null,
//   result : null,
//   src : null,
//   dst : null,
//
//   onUp : [],
//   onDown : [],
// }
//
// filesFindDifference.defaults.__proto__ = _filesFindMasksAdjust.defaults
//
// var paths = filesFindDifference.paths = Object.create( null );
//
// paths.src = null;
// paths.dst = null;
//
// var having = filesFindDifference.having = Object.create( null );
//
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;
//
// //
//
// /*
//
// * level : 0, 1, 2
// (
//   presence : missing, present
//   +
//   if present
//   (
//     * kind of file : directory, terminal
//     * linkage of file : ordinary, soft
//   )
// )
//
// ^ where file : src, dst
//
// 3 * ( 1 + 2 * 2  ) ^ 2 = 3 * 9 ^ 2 = 81
//
// */
//
// function filesCopyOld( o )
// {
//   let self = this;
//   let providerIsHub = _.FileProvider.Hub && self instanceof _.FileProvider.Hub;
//
//   if( arguments.length === 2 )
//   o = { dst : arguments[ 0 ] , src : arguments[ 1 ] }
//
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//
//   if( !o.allowDelete && o.investigateDestination === undefined )
//   o.investigateDestination = 0;
//
//   if( o.allowRewrite === undefined )
//   o.allowRewrite = filesCopyOld.defaults.allowRewrite;
//
//   if( o.allowRewrite && o.allowWrite === undefined )
//   o.allowWrite = 1;
//
//   if( o.allowRewrite && o.allowRewriteFileByDir === undefined  )
//   o.allowRewriteFileByDir = true;
//
//   _.routineOptions( filesCopyOld,o );
//   self._providerOptions( o );
//   // debugger;
//   // o = self._filesFind_pre( filesCopyOld,[ o ] );
//   // debugger;
//
//   let includingDirectories = o.includingDirectories !== undefined ? o.includingDirectories : 1;
//   let onUp = _.arrayAs( o.onUp );
//   let onDown = _.arrayAs( o.onDown );
//   let directories = Object.create( null );
//
//   /* safe */
//
//   if( self.safe )
//   if( o.removingSource && ( !o.allowWrite || !o.allowRewrite ) )
//   throw _.err( 'not safe removingSource:1 with allowWrite:0 or allowRewrite:0' );
//
//   /* make dir */
//
//   let dirname = self.path.dir( o.dst );
//
//   if( self.safe )
//   if( !self.path.isSafe( dirname ) )
//   throw _.err( dirname,'Unsafe to use :',dirname );
//
//   o.filter = _.FileRecordFilter.TollerantMake( o,{ fileProvider : self } ).form();
//   let recordDir = self.fileRecord( dirname,{ filter : o.filter } );
//   let rewriteDir = recordDir.stat && !recordDir.stat.isDirectory();
//   if( rewriteDir )
//   if( o.allowRewrite )
//   {
//
//     debugger;
//     throw _.err( 'not tested' );
//     if( o.verbosity )
//     logger.log( '- rewritten file by directory :',dirname );
//     self.fileDelete({ filePath : filePath });
//     self.directoryMake({ filePath : dirname, force : 1 });
//
//   }
//   else
//   {
//     throw _.err( 'cant rewrite',dirname );
//   }
//
//   /* on up */
//
//   function handleUp( record )
//   {
//
//     /* same */
//
//     if( o.tryingPreserve )
//     if( record.same && record.link == o.linking )
//     {
//       record.action = 'same';
//       record.allowed = true;
//     }
//
//     /* delete redundant */
//
//     if( record.del )
//     {
//
//       if( record.dst && record.dst.stat )
//       {
//         if( o.allowDelete )
//         {
//           record.action = 'deleted';
//           record.allowed = true;
//
//         }
//         else
//         {
//           record.action = 'deleted';
//           record.allowed = false;
//
//         }
//       }
//       else
//       {
//         record.action = 'ignored';
//         record.allowed = false;
//       }
//
//       return;
//     }
//
//     /* preserve directory */
//
//     if( !record.action )
//     {
//
//       /*if( o.tryingPreserve )*/
//       if( record.src.stat && record.dst.stat )
//       if( record.src.stat.isDirectory() && record.dst.stat.isDirectory() )
//       {
//         directories[ record.dst.absolute ] = true;
//         record.action = 'directory preserved';
//         record.allowed = true;
//         if( o.preservingTime )
//         self.fileTimeSet( record.dst.absoluteEffective, record.src.stat );
//       }
//
//     }
//
//     /* rewrite */
//
//     let rewriteFile;
//
//     if( !record.action )
//     {
//       rewriteFile = !!record.dst.stat;
//
//       if( rewriteFile )
//       {
//
//         if( !o.allowRewriteFileByDir && record.src.stat && record.src.stat.isDirectory() )
//         rewriteFile = false;
//
//         if( rewriteFile && o.allowRewrite && o.allowWrite )
//         {
//           rewriteFile = record.dst.real + '.' + _.idWithDate() + '.back' ;
//           self.fileRename
//           ({
//             dstPath : rewriteFile,
//             srcPath : record.dst.real,
//             verbosity : 0,
//           });
//           delete record.dst.stat;
//         }
//         else
//         {
//           rewriteFile = false;
//           record.action = 'cant rewrite';
//           record.allowed = false;
//           if( o.verbosity )
//           logger.log( '? cant rewrite :',record.dst.absolute );
//         }
//
//       }
//
//     }
//
//     /* new directory */
//
//     if( !record.action && record.src.stat && record.src.stat.isDirectory() )
//     {
//
//       directories[ record.dst.absolute ] = true;
//       record.action = 'directory new';
//       record.allowed = false;
//       if( o.allowWrite )
//       {
//         self.directoryMake({ filePath : record.dst.absoluteEffective, force : 1 });
//         if( o.preservingTime )
//         self.fileTimeSet( record.dst.absoluteEffective, record.src.stat );
//         record.allowed = true;
//       }
//
//     }
//
//     /* directory for dst */
//
//     if( !record.action && record.src.stat && record.src.stat.isFile() )
//     {
//       directories[ record.dst.dir ] = true;
//
//       if( !record.dst.stat && !self.fileStat( record.dst.dir ) )
//       {
//         if( o.allowWrite )
//         {
//           if( providerIsHub )
//           self.directoryMake( record.dst.fileProvider.urlFromLocal( record.dst.dir ) );
//           else
//           self.directoryMake( record.dst.dir );
//
//           if( o.preservingTime )
//           {
//             if( providerIsHub )
//             self.fileTimeSet( record.dst.fileProvider.urlFromLocal( record.dst.dir ), record.src.stat );
//             else
//             self.fileTimeSet( record.dst.dir, record.src.stat );
//           }
//
//           record.allowed = true;
//         }
//         else
//         directories[ record.dst.dir ] = false;
//       }
//     }
//
//     /* unknown */
//
//     if( !record.action && record.src.stat && !record.src.stat.isFile() )
//     {
//       throw _.err( 'unknown kind of source : it is unsafe to proceed :\n' + _.files.fileReport( record.src ) + '\n' );
//     }
//
//     /* is write possible */
//
//     if( !record.action )
//     {
//
//       if( !directories[ record.dst.dir ] )
//       {
//         record.action = 'cant rewrite';
//         record.allowed = false;
//         return;
//       }
//
//     }
//
//     /* write */
//
//     if( !record.action )
//     {
//
//       if( o.linking )
//       {
//
//         record.action = 'linked';
//         record.allowed = false;
//
//         if( o.allowWrite )
//         {
//           record.allowed = true;
//           self.linkHard({ dstPath : record.dst.absolute, srcPath : record.src.real, sync : 1, verbosity : o.verbosity });
//         }
//
//       }
//       else
//       {
//
//         record.action = 'copied';
//         record.allowed = false;
//
//         if( o.allowWrite )
//         {
//           record.allowed = true;
//           if( o.resolvingTextLink )
//           record.dst.real = self.path.resolveTextLink( record.dst.real, true );
//
//           if( o.verbosity )
//           debugger;
//           if( o.verbosity )
//           logger.log( '+ ' + record.action + ' :',record.dst.real );
//
//           self.fileCopy( record.dst.absoluteEffective,record.src.absoluteEffective );
//
//           if( o.preservingTime )
//           {
//             self.fileTimeSet( record.dst.absoluteEffective, record.src.stat );
//           }
//         }
//
//       }
//
//     }
//
//     /* rewrite */
//
//     if( rewriteFile && o.allowRewrite )
//     {
//       self.filesDelete
//       ({
//         filePath : rewriteFile,
//         throwing : 1,
//       });
//     }
//
//     /* callback */
//
//     if( !includingDirectories && record.src.stat && record.src.stat.isDirectory() )
//     return;
//
//     _.routinesCallEvery( o,onUp,[ record ] );
//
//   }
//
//   /* on down */
//
//   function handleDown( record )
//   {
//
//     _.assert( record.action !== 'linked' || !record.del );
//
//     /* delete redundant */
//
//     if( record.action === 'deleted' )
//     {
//       if( record.allowed )
//       {
//         if( o.verbosity )
//         logger.log( '- deleted :',record.dst.real );
//         self.filesDelete({ filePath : record.dst.real, throwing : 0 });
//         delete record.dst.stat;
//       }
//       else
//       {
//         if( o.verbosity && !o.silentPreserve )
//         logger.log( '? not deleted :',record.dst.absolute );
//       }
//     }
//
//     /* remove source */
//
//     let removingSource = false;
//     removingSource = removingSource || o.removingSource;
//     removingSource = removingSource || ( o.removingSourceTerminals && !record.src.isDir );
//
//     if( removingSource && record.src.stat && record.src.isActual )
//     {
//       if( o.verbosity )
//       logger.log( '- removed-source :',record.src.real );
//       self.fileDelete( record.src.real );
//       delete record.src.stat;
//     }
//
//     /* callback */
//
//     if( !includingDirectories && record.src.isDir )
//     return;
//
//     _.routinesCall( self,onDown,[ record ] );
//
//   }
//
//   /* launch */
//
//   let records;
//
//   try
//   {
//
//     let findOptions = _.mapOnly( o, filesFindDifference.defaults );
//     findOptions.onUp = handleUp;
//     findOptions.onDown = handleDown;
//     findOptions.includingDirectories = true;
//
//     records = self.filesFindDifference( o.dst,o.src,findOptions );
//
//     if( o.verbosity )
//     if( !records.length && o.outputFormat !== 'nothing' )
//     logger.log( '? copy :', 'nothing was copied :',o.dst,'<-',o.src );
//
//     if( !includingDirectories )
//     {
//       records = records.filter( function( e )
//       {
//         if( e.src.stat && e.src.isDir )
//         return false;
//
//         if( e.src.stat && !e.src.isDir )
//         return true;
//
//         if( e.dst.stat && e.dst.isDir )
//         return false;
//
//         return true;
//       });
//     }
//
//   }
//   catch( err )
//   {
//     debugger;
//     throw _.err( 'filesCopyOld( ',_.toStr( o ),' )','\n',err );
//   }
//
//   return records;
// }
//
// _.routineExtend( filesCopyOld, filesFindDifference );
//
// var defaults = filesCopyOld.defaults;
//
// defaults.verbosity = 1;
// defaults.linking = 0;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;
//
// defaults.removingSource = 0;
// defaults.removingSourceTerminals = 0;
//
// defaults.recursive = 1;
// defaults.allowDelete = 0;
// defaults.allowWrite = 0;
// defaults.allowRewrite = 1;
// defaults.allowRewriteFileByDir = 0;
//
// defaults.tryingPreserve = 1;
// defaults.silentPreserve = 1;
// defaults.preservingTime = 1;

//

function filesCopyWithAdapter( o )
{
  let self = this;

  if( arguments.length === 2 )
  o = { dst : arguments[ 0 ] , src : arguments[ 1 ] }

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( !o.allowDelete && o.investigateDestination === undefined )
  o.investigateDestination = 0;

  if( o.allowRewrite === undefined )
  o.allowRewrite = filesCopyWithAdapter.defaults.allowRewrite;

  if( o.allowRewrite && o.allowWrite === undefined )
  o.allowWrite = 1;

  if( o.allowRewrite && o.allowRewriteFileByDir === undefined  )
  o.allowRewriteFileByDir = true;

  _.routineOptions( filesCopyWithAdapter,o );
  self._providerOptions( o );

  /* safe */

  if( self.safe )
  if( o.removingSource && ( !o.allowWrite || !o.allowRewrite ) )
  throw _.err( 'not safe removingSource:1 with allowWrite:0 or allowRewrite:0' );

  let options = Object.create( null );
  _.mapExtend( options, _.mapOnly( o, filesReflect.defaults ) );

  /*
    'investigateDestination',
    'verbosity',
    'silentPreserve?',
    'resolvingSoftLink',
    'resolvingTextLink',
    'allowDelete',
    'allowWrite',
    'allowRewrite',
    'allowRewriteFileByDir',
    'removingSourceTerminals',
    'removingSource',
    'tryingPreserve',
    'ext?',
    'maxSize?',
    'usingTime?',
  */

  options.linking = options.linking ? 'hardlink' : 'fileCopy';
  options.srcDeleting = o.removingSource || o.removingSourceTerminals; // check it
  options.dstDeleting = o.allowDelete;
  options.writing = o.allowWrite;
  options.dstRewriting = o.allowRewrite;
  options.dstRewritingByDistinct = o.allowRewriteFileByDir; // check it
  options.preservingTime = o.preservingTime;
  options.preservingSame = o.tryingPreserve; // check it
  options.includingDst = o.investigateDestination;

  options.resolvingSrcSoftLink = o.resolvingSoftLink;
  options.resolvingDstSoftLink = o.resolvingSoftLink;
  options.resolvingSrcTextLink = o.resolvingTextLink;
  options.resolvingDstTextLink = o.resolvingTextLink;

  options.reflectMap = Object.create( null );
  options.reflectMap[ o.src ] = o.dst;

  options.srcProvider = self;
  options.dstProvider = self;

  // let filter = _.FileRecordFilter.TollerantMake( o,{ fileProvider : self } );
  // options.srcFilter = filter;
  // options.dstFilter = filter;

  if( o.filter )
  options.srcFilter = options.dstFilter = o.filter;

  if( o.ext )
  {
    _.assert( _.strIs( o.ext ) );
    let ext = o.ext;
    options.onDstName = function( relative, dstRecordContext, op, o, srcRecord )
    {
      if( !srcRecord.isDir )
      return self.path.changeExt( relative,ext );
      return relative;
    }
  }

  let result = self.filesReflect( options );

  result.forEach( ( r ) =>
  {

    if( !r.relative )
    r.relative = r.effective.relative;

    if( r.action === 'directoryMake' )
    r.action = 'directory new'

    if( r.action === 'fileCopy' )
    r.action = 'copied'

    if( r.action === 'directoryPreserve' )
    r.action = 'directory preserved'

    if( r.action === 'terminalPreserve' )
    r.action = 'same';

  })

  return result;
}

filesCopyWithAdapter.defaults =
{
  outputFormat : 'record',
  ext : null,
  investigateDestination : 1,

  maxSize : 1 << 21,
  usingTime : 1,
  recursive : 0,

  includingTerminals : 1,
  includingDirectories : 1,

  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  filter : null,
  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

// filesCopyWithAdapter.defaults.__proto__ = _filesFindMasksAdjust.defaults

var paths = filesCopyWithAdapter.paths = Object.create( null );

paths.src = null;
paths.dst = null;

var having = filesCopyWithAdapter.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

// _.routineExtend( filesCopyWithAdapter, filesFindDifference );

var defaults = filesCopyWithAdapter.defaults;

defaults.verbosity = 1;
defaults.linking = 0;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

defaults.removingSource = 0;
defaults.removingSourceTerminals = 0;

defaults.recursive = 1;
defaults.allowDelete = 0;
defaults.allowWrite = 0;
defaults.allowRewrite = 1;
defaults.allowRewriteFileByDir = 0;

defaults.tryingPreserve = 1;
defaults.silentPreserve = 1;
defaults.preservingTime = 1;

//

function _filesCompareFast_pre( routine,args )
{
  let self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { dstPath : args[ 0 ] , srcPath : args[ 1 ] }

  _.routineOptions( routine,o );
  self._providerOptions( o );

  if( !_.arrayIs( o.onUp ) )
  o.onUp = o.onUp ? [ o.onUp ] : [];
  if( !_.arrayIs( o.onDown ) )
  o.onDown = o.onDown ? [ o.onDown ] : [];

  _.assert( o.onDstName === null || _.routineIs( o.onDstName ) );

  o.srcPath = self.path.s.normalize( o.srcPath );
  o.dstPath = self.path.s.normalize( o.dstPath );

  if( !o.srcProvider )
  o.srcProvider = self.providerForPath( o.srcPath );

  if( !o.dstProvider )
  o.dstProvider = self.providerForPath( o.dstPath );

  if( !o.srcProvider )
  throw _.err( 'No provider for',o.srcPath );

  if( !o.dstProvider )
  throw _.err( 'No provider for',o.dstPath );

  o.srcPath = o.srcProvider.localsFromUris( o.srcPath );
  o.dstPath = o.dstProvider.localsFromUris( o.dstPath );

  /* */

  if( o.filter )
  o.filter = self.fileRecordFilter( o.filter );
  if( o.srcFilter )
  {
    o.srcFilter.fileProvider = o.srcFilter.fileProvider || o.srcProvider || self;
    o.srcFilter = self.fileRecordFilter( o.srcFilter );
  }
  if( o.dstFilter )
  {
    o.dstFilter.fileProvider = o.dstFilter.fileProvider || o.dstProvider || self;
    o.dstFilter = self.fileRecordFilter( o.dstFilter );
  }

  if( !o.srcFilter )
  o.srcFilter = o.filter;
  else if( o.filter && o.filter !== o.srcFilter )
  o.srcFilter.and( o.filter );

  if( !o.dstFilter )
  o.dstFilter = o.filter;
  else if( o.filter && o.filter !== o.dstFilter )
  o.dstFilter.and( o.filter );

  if( o.srcFilter === null )
  o.srcFilter = self.fileRecordFilter({ fileProvider : o.srcProvider || self });
  if( o.dstFilter === null )
  o.dstFilter = self.fileRecordFilter({ fileProvider : o.dstProvider || self });

  o.srcProvider = o.srcProvider || o.srcFilter.fileProvider;
  o.dstProvider = o.dstProvider || o.dstFilter.fileProvider;

  _.assert( _.objectIs( o.srcFilter ) );
  _.assert( _.objectIs( o.dstFilter ) );
  _.assert( _.objectIs( o.srcFilter.fileProvider ) );
  _.assert( _.objectIs( o.dstFilter.fileProvider ) );
  _.assert( _.objectIs( o.srcProvider ) );
  _.assert( _.objectIs( o.dstProvider ) );
  _.assert( o.srcProvider === o.srcFilter.fileProvider );
  _.assert( o.dstProvider === o.dstFilter.fileProvider );

  /* */

  if( o.result === null )
  o.result = [];

  return o;
}

//

function _filesCompareFast_body( o )
{
  let self = this;
  let path = self.path;

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = 0;

  let resultAdd = resultAdd_functor( o );
  let dstRecordContext;
  let dstOptions;
  let srcRecordContextMap;
  let srcOptions;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( o.result ) );
  _.assert( path.s.allAreNormalized( o.srcPath ) );
  _.assert( path.isNormalized( o.dstPath ) );
  // _.assert( path.isNormalized( o.dstBasePath ) );
  _.assert( !o.srcFilter.formed );
  _.assert( !o.dstFilter.formed );
  _.assertRoutineOptions( _filesCompareFast_body, o );

  // op.dstPath = dstPath;
  // op.dstBasePath = op.dstPath;
  // op.srcPath = groupedGlobMap[ dstPath ];
  // op.srcBasePath = null;

  /* src */

  if( !o.srcFilter.formed )
  {
    // o.srcFilter.inFilePath = o.srcPath;
    // o.srcFilter.basePath = o.srcBasePath; /* ttt */

    o.srcFilter.fileProvider = o.srcFilter.fileProvider || o.srcProvider;
    o.srcProvider = o.srcProvider || o.srcFilter.fileProvider;

    // o.srcFilter.form();
    // o.srcPath = o.srcFilter.branchPath;
  }

  _.assert( o.srcProvider === o.srcFilter.fileProvider );
  _.assert( !!o.srcProvider );

  // o.srcPath = o.srcFilter.branchPath;
  // o.srcBasePath = o.srcFilter.basePath;

  // _.assert( _.strIs( o.srcPath ) || _.arrayIs( o.srcPath ) );
  // _.assert( _.objectIs( o.srcFilter.basePath ) );
  // _.assert( o.srcFilter.branchPath === o.srcPath );

  // debugger;
  // for( let branchPath in o.srcFilter.basePath )
  // {
  //   let basePath = o.srcFilter.basePath[ branchPath ];

    // let srcOp =
    // {
    //   fileProvider : self,
    //   fileProviderEffective : o.srcProvider,
    //   filter : o.srcFilter,
    //   basePath : basePath,
    //   branchPath : branchPath,
    // }
    //
    // debugger;
    // srcRecordContextMap[ branchPath ] = _.FileRecordContext.TollerantMake( o, srcOp ).form();
    // debugger;
    //
    // _.assert( srcRecordContextMap[ branchPath ].basePath === o.srcBasePath );

    srcOptions = _.mapOnly( o, self._filesFindFast.defaults );
    srcOptions.includingBase = 1;
    srcOptions.filter = o.srcFilter;
    srcOptions.filePath = o.srcPath;
    // srcOptions.basePath = o.srcBasePath;
    srcOptions.result = null;
    srcOptions.fileProviderEffective = o.srcProvider;
    _.mapSupplement( srcOptions, self._filesFindFast.defaults );

  // }

  /* dst */

  if( !o.dstFilter.formed )
  {
    o.dstFilter.inFilePath = o.dstPath;
    // o.dstFilter.basePath = o.dstBasePath;
    o.dstFilter.fileProvider = o.dstFilter.fileProvider || o.dstProvider;
    o.dstProvider = o.dstProvider || o.dstFilter.fileProvider;
    o.dstFilter.form();
  }

  o.dstPath = o.dstFilter.branchPath;
  // o.dstBasePath = o.dstFilter.basePath;

  _.assert( _.strIs( o.dstPath ) || _.arrayIs( o.dstPath ) );
  _.assert( _.objectIs( o.dstFilter.basePath ) );
  // _.assert( _.objectIs( o.dstBasePath ) );
  _.assert( o.dstFilter.branchPath === o.dstPath );
  _.assert( o.dstProvider === o.dstFilter.fileProvider );
  _.assert( !!o.dstProvider );

  let dstOp =
  {
    // basePath : o.dstBasePath[ o.dstPath ],
    basePath : o.dstFilter.basePath[ o.dstPath ],
    branchPath : o.dstPath,
    fileProvider : self,
    fileProviderEffective : o.dstProvider,
    filter : o.dstFilter,
  }

  // debugger;
  dstRecordContext = _.FileRecordContext.TollerantMake( o, dstOp ).form();
  // debugger;

  _.assert( _.strIs( dstOp.basePath ) );
  _.assert( dstRecordContext.basePath === o.dstFilter.basePath[ o.dstPath ] );

  dstOptions = _.mapExtend( null, srcOptions );
  dstOptions.filter = o.dstFilter;
  dstOptions.filePath = o.dstPath;
  // dstOptions.basePath = o.dstBasePath;
  dstOptions.includingBase = 1;
  dstOptions.recursive = 1;
  dstOptions.fileProviderEffective = o.dstProvider;

  /* common */

  srcOptions.onDown = [ handleSrcDown ];
  srcOptions.onUp = [ handleSrcUp ];
  dstOptions.onDown = [ handleDstDown ];

  /* */

  debugger;
  let found = self.filesFind( srcOptions );
  debugger;

  if( o.mandatory )
  if( !o.result.length )
  {
    debugger;
    throw _.err( 'No file moved', o.srcPath, '->', o.dstPath );
  }

  return o.result;

  /* add result */

  function resultAdd_functor( o )
  {
    let resultAdd;

    if( o.outputFormat === 'src.absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record.src.absolute );
    }
    else if( o.outputFormat === 'src.relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record.src.relative );
    }
    else if( o.outputFormat === 'dst.absolute' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record.dst.absolute );
    }
    else if( o.outputFormat === 'dst.relative' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record.dst.relative );
    }
    else if( o.outputFormat === 'record' )
    resultAdd = function( record )
    {
      _.assert( arguments.length === 1, 'expects single argument' );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    resultAdd = function( record )
    {
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return resultAdd;
  }

  /* */

  function recordMake( dstRecord, srcRecord, effectiveRecord )
  {
    let record = Object.create( null )
    record.dst = dstRecord;
    record.src = srcRecord;
    record.effective = effectiveRecord;
    record.upToDate = 0;
    record.srcAction = null;
    record.dstAction = null;
    record.action = null;
    return record;
  }

  /* */

  function handleUp( record, op, isDst )
  {

    if( !o.includingDst && isDst )
    return record;

    if( !o.includingDirectories && record.effective.isDir )
    return record;

    if( !o.includingTerminals && !record.effective.isDir )
    return record;

    _.assert( _.arrayIs( o.onUp ) );
    _.assert( arguments.length === 3, 'expects exactly three argument' );

    for( let i = 0 ; i < o.onUp.length ; i++ )
    {
      let routine = o.onUp[ i ];
      record = routine.call( self, record, o );
      _.assert( record !== undefined );
      if( record === false )
      return false;
    }

    return record;
  }

  /* */

  function handleDown( record,isDst )
  {
    _.assert( _.arrayIs( o.onDown ) );
    _.assert( !!record.dst && !!record.src );

    if( !o.includingDst && isDst )
    return record;

    if( !o.includingDirectories && record.effective.isDir )
    return record;

    if( !o.includingTerminals && !record.effective.isDir )
    return record;

    _.routinesCall( self,o.onDown,[ record,o ] );
  }

  /* */

  function handleDstUpDeleting( srcContext, dstRecord, op )
  {
    // debugger;
    _.assert( arguments.length === 3 );
    // console.log( 'handleDstUpDeleting', dstRecord.absolute ); xxx
    let srcRecord = self.fileRecord( dstRecord.relative, srcContext );
    let record = recordMake( dstRecord, srcRecord, dstRecord );
    record.dstAction = 'deleting';
    record = handleUp( record, op, 1 );
    // debugger;
    if( record === false )
    return false;
    resultAdd( record );
    return record;
  }

  /* */

  function handleDstUpRewriting( srcContext, dstRecord, op )
  {
    _.assert( arguments.length === 3 );
    // console.log( 'handleDstUpRewriting', dstRecord.absolute );
    let srcRecord = self.fileRecord( dstRecord.relative, srcContext );
    let record = recordMake( dstRecord, srcRecord, dstRecord );
    record.dstAction = 'rewriting';
    record = handleUp( record, op, 1 );
    if( record === false )
    return false;
    resultAdd( record );
    return record;
  }

  /* */

  function handleDstDown( record,op )
  {
    // console.log( 'handleDstDown', record.dst.absolute );
    handleDown( record, 1 );
  }

  /* */

  function handleSrcUp( srcRecord, op )
  {
    let relative = srcRecord.relative;
    if( o.onDstName )
    relative = o.onDstName.call( self, relative, dstRecordContext, op, o, srcRecord );

    let dstRecord = self.fileRecord( relative, dstRecordContext ); /* xxx */
    let record = recordMake( dstRecord, srcRecord, srcRecord );

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      {
        o.filesGraph.dstPath = o.dstPath;
        o.filesGraph.srcPath = o.srcPath;
        o.filesGraph.actionBegin( o.dstPath + ' <- ' + o.srcPath );
      }
      if( !record.src.isDir )
      {
        o.filesGraph.filesUpdate( record.dst );
        o.filesGraph.filesUpdate( record.src );
        if( o.filesGraph.fileIsUpToDate( record.dst ) )
        record.upToDate = 1;
      }
    }

    record = handleUp( record,op,0 );
    if( record === false )
    return false;
    resultAdd( record );

    if( o.includingDst )
    if( record.dst.isDir && !record.src.isDir )
    {
      // debugger;
      let dstOptions2 = _.mapExtend( null,dstOptions );
      dstOptions2.filePath = record.dst.absolute;
      dstOptions2.filter = dstOptions2.filter.clone();
      dstOptions2.filter.inFilePath = null;
      dstOptions2.filter.basePath = record.dst.context.basePath;
      dstOptions2.onUp = [ _.routineJoin( undefined, handleDstUpRewriting, [ srcRecord.context ] ) ];
      // debugger;
      let found = self.filesFind( dstOptions2 );
      // debugger;
    }

    return record;
  }

  /* */

  function handleSrcDown( record,t )
  {

    if( o.filesGraph && !record.src.isDir && !record.upToDate )
    {
      record.dst.restat();
      o.filesGraph.dependencyAdd( record.dst, record.src );
    }

    if( o.includingDst )
    if( record.dst.isDir && record.src.isDir )
    {
      // debugger;
      _.assert( _.strIs( record.dst.context.basePath ) );
      _.assert( _.strIs( record.src.context.basePath ) );
      let dstFiles = o.dstProvider.directoryRead({ filePath : record.dst.absolute, basePath : record.dst.context.basePath });
      let srcFiles = o.srcProvider.directoryRead({ filePath : record.src.absolute, basePath : record.src.context.basePath });
      _.arrayRemoveArrayOnce( dstFiles, srcFiles );
      for( let f = 0 ; f < dstFiles.length ; f++ )
      {
        // debugger;
        let dstOptions2 = _.mapExtend( null,dstOptions );
        dstOptions2.filePath = path.join( record.dst.context.basePath, dstFiles[ f ] );
        dstOptions2.filter = dstOptions2.filter.clone();
        dstOptions2.filter.inFilePath = null;
        dstOptions2.filter.basePath = record.dst.context.basePath;
        dstOptions2.onUp = [ _.routineJoin( null, handleDstUpDeleting, [ record.src.context ] ) ];
        // let dstOptions2 = _.mapExtend( null, dstOptions );
        // dstOptions2.filePath = path.join( dstOptions.basePath, dstFiles[ f ] );
        // dstOptions2.onUp = [ _.routineJoin( null, handleDstUpDeleting, [ record.src.context ] ) ];
        // debugger;
        let found = self.filesFind( dstOptions2 );
        // debugger;
      }
    }

    handleDown( record,0 );

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      o.filesGraph.actionEnd();
    }

  }

}

let filesCompareDefaults = Object.create( null );
var defaults = filesCompareDefaults;

defaults.srcProvider = null;
defaults.dstProvider = null;

defaults.filesGraph = null;
defaults.filter = null;
defaults.srcFilter = null;
defaults.dstFilter = null;

defaults.result = null;
defaults.outputFormat = 'record';
defaults.mandatory = 0;

defaults.ignoringNonexistent = 0;
defaults.includingTerminals = 1;
defaults.includingDirectories = 1;
// defaults.includingTransients = 1;
// defaults.includingBase = 1;
defaults.includingDst = null;

defaults.recursive = 1;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;

defaults.onUp = null;
defaults.onDown = null;
defaults.onDstName = null;

var defaults = _filesCompareFast_body.defaults = Object.create( filesCompareDefaults );

defaults.srcPath = null;
defaults.dstPath = null;
// defaults.srcBasePath = null;
// defaults.dstBasePath = null;

var paths = _filesCompareFast_body.paths = Object.create( null );

paths.srcPath = null;
paths.dstPath = null;

var having = _filesCompareFast_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesCompareFast = _.routineForPreAndBody( _filesCompareFast_pre, _filesCompareFast_body );

filesCompareFast.having.aspect = 'entry';

//

function _filesCompare_pre( routine, args )
{
  let self = this;

  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { reflectMap : { [ args[ 1 ] ] : args[ 0 ] } }

  debugger;

  _.routineOptions( routine,o );
  self._providerOptions( o );

  if( !_.arrayIs( o.onUp ) )
  o.onUp = o.onUp ? [ o.onUp ] : [];
  if( !_.arrayIs( o.onDown ) )
  o.onDown = o.onDown ? [ o.onDown ] : [];

  _.assert( o.onDstName === null || _.routineIs( o.onDstName ) );

  // o.srcPath = self.path.s.normalize( o.srcPath );
  // o.dstPath = self.path.s.normalize( o.dstPath );

  // if( !o.srcProvider )
  // o.srcProvider = self.providerForPath( o.srcPath );
  //
  // if( !o.dstProvider )
  // o.dstProvider = self.providerForPath( o.dstPath );
  //
  // if( !o.srcProvider )
  // throw _.err( 'No provider for',o.srcPath );
  //
  // if( !o.dstProvider )
  // throw _.err( 'No provider for',o.dstPath );
  //
  // o.srcPath = o.srcProvider.localsFromUris( o.srcPath );
  // o.dstPath = o.dstProvider.localsFromUris( o.dstPath );

  // if( o.filter )
  // o.filter = self.fileRecordFilter( o.filter );
  // if( o.srcFilter )
  // o.srcFilter = self.fileRecordFilter( o.srcFilter );
  // if( o.dstFilter )
  // o.dstFilter = self.fileRecordFilter( o.dstFilter );
  //
  // if( !o.srcFilter )
  // o.srcFilter = o.filter;
  // else if( o.filter && o.filter !== o.srcFilter )
  // o.srcFilter.and( o.filter );
  //
  // if( !o.dstFilter )
  // o.dstFilter = o.filter;
  // else if( o.filter && o.filter !== o.dstFilter )
  // o.dstFilter.and( o.filter );
  //
  // if( o.srcFilter === null )
  // o.srcFilter = self.fileRecordFilter();
  // if( o.dstFilter === null )
  // o.dstFilter = self.fileRecordFilter();
  //
  // _.assert( _.objectIs( o.srcFilter ) );
  // _.assert( _.objectIs( o.dstFilter ) );


  /* */

  if( o.filter )
  o.filter = self.fileRecordFilter( o.filter );
  if( o.srcFilter )
  {
    o.srcFilter.fileProvider = o.srcFilter.fileProvider || o.srcProvider || self;
    o.srcFilter = self.fileRecordFilter( o.srcFilter );
  }
  if( o.dstFilter )
  {
    o.dstFilter.fileProvider = o.dstFilter.fileProvider || o.dstProvider || self;
    o.dstFilter = self.fileRecordFilter( o.dstFilter );
  }

  if( !o.srcFilter )
  o.srcFilter = o.filter;
  else if( o.filter && o.filter !== o.srcFilter )
  o.srcFilter.and( o.filter );

  if( !o.dstFilter )
  o.dstFilter = o.filter;
  else if( o.filter && o.filter !== o.dstFilter )
  o.dstFilter.and( o.filter );

  if( o.srcFilter === null )
  o.srcFilter = self.fileRecordFilter({ fileProvider : o.srcProvider || self });
  if( o.dstFilter === null )
  o.dstFilter = self.fileRecordFilter({ fileProvider : o.dstProvider || self });

  o.srcProvider = o.srcProvider || o.srcFilter.fileProvider;
  o.dstProvider = o.dstProvider || o.dstFilter.fileProvider;

  _.assert( _.objectIs( o.srcFilter ) );
  _.assert( _.objectIs( o.dstFilter ) );
  _.assert( _.objectIs( o.srcFilter.fileProvider ) );
  _.assert( _.objectIs( o.dstFilter.fileProvider ) );
  _.assert( _.objectIs( o.srcProvider ) );
  _.assert( _.objectIs( o.dstProvider ) );
  _.assert( o.srcProvider === o.srcFilter.fileProvider );
  _.assert( o.dstProvider === o.dstFilter.fileProvider );

  /* */

  if( o.result === null )
  o.result = [];

  return o;
}

//

function _filesCompare_body( o )
{
  let self = this;
  let path = self.path;

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = 0;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( o.result ) );
  _.assert( !o.srcFilter.formed );
  _.assert( !o.dstFilter.formed );
  _.assertRoutineOptions( _filesCompare_body, o );

  o.reflectMap = path.globMapExtend( null, o.reflectMap );
  let groupedGlobMap = path.globMapGroupByDst( o.reflectMap );

  _.assert( _.all( o.reflectMap, ( e, k ) => k === false || path.is( k ) ) );

  debugger;
  for( let dstPath in groupedGlobMap )
  {

    let o2 = _.mapOnly( o, self.filesCompareFast.body.defaults );
    o2.dstPath = dstPath;
    o2.dstFilter.basePath = dstPath;
    o2.srcPath = groupedGlobMap[ dstPath ];
    o2.srcFilter = o2.srcFilter.clone();
    o2.dstFilter = o2.dstFilter.clone();
    _.assert( _.arrayIs( o2.result ) );
    debugger;
    self.filesCompareFast.body.call( self, o2 );
    _.assert( o2.result === o.result )

  }
  debugger;

  /* */

  if( o.mandatory )
  if( !o.result.length )
  {
    debugger;
    throw _.err( 'No file moved', o.srcPath, '->', o.dstPath );
  }

  return o.result;
}

var defaults = _filesCompare_body.defaults = Object.create( filesCompareDefaults );

defaults.reflectMap = null;

var paths = _filesCompare_body.paths = Object.create( null );

paths.srcPath = null;
paths.dstPath = null;

var having = _filesCompare_body.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesCompare = _.routineForPreAndBody( _filesCompareFast_pre, _filesCompare_body );

filesCompare.having.aspect = 'entry';

//

function _filesReflect_body( o )
{
  let self = this;
  let path = self.path;

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = o.dstDeleting;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !o.dstDeleting || o.includingDst );
  _.assert( _.arrayHas( [ 'fileCopy','hardlink','softlink','nop' ], o.linking ), 'unknown kind of linking', o.linking );
  _.assert( _.mapIs( o.reflectMap ) );
  _.assertRoutineOptions( _filesReflect_body, o );

  /* */

  o.onUp = _.arrayPrependElement( o.onUp || [], handleUp );
  o.onDown = _.arrayPrependElement( o.onDown || [], handleDown );

  // o.srcPath = _.arrayAs( o.srcPath );
  // o.dstPath = _.arrayAs( o.dstPath );

  _.assert( o.srcFilter.formed === 0 );
  _.assert( o.dstFilter.formed === 0 );

  let o2 = _.mapOnly( o, self.filesCompare.body.defaults );
  _.assert( _.arrayIs( o2.result ) );
  debugger;
  self.filesCompare.body.call( self, o2 );
  debugger;
  _.assert( o2.result === o.result )

  // // debugger;
  // for( let d = 0 ; d < o.dstPath.length ; d++ )
  // // for( let s = 0 ; s < o.srcPath.length ; s++ )
  // {
  //
  //   let op = _.mapOnly( o, self.filesCompareFast.body.defaults );
  //   // op.srcPath = o.srcPath[ s ];
  //   op.dstPath = o.dstPath[ d ];
  //   op.srcFilter = op.srcFilter.clone();
  //   op.dstFilter = op.dstFilter.clone();
  //   _.assert( _.arrayIs( op.result ) );
  //   self.filesCompareFast.body.call( self, op );
  //   _.assert( op.result === o.result )
  //   // debugger;
  //
  // }
  // // debugger;

  return o.result;

  /* */

  function terminalPreserve( record )
  {
    _.assert( !record.action );
    record.action = 'terminalPreserve';
    return record;
  }

  /* */

  function upToDate( record )
  {
    _.assert( !record.action );
    record.action = 'upToDate';
    return record;
  }

  /* */

  function notAllowed( record, _continue )
  {
    debugger;
    _.assert( !record.action );
    _.assert( arguments.length === 2, 'expects exactly two arguments' );
    record.action = 'notAllowed';
    if( _continue )
    return record;
    else
    return false;
  }

  /* */

  function canLink( record )
  {
    if( !o.preservingSame )
    return true;

    if( o.linking === 'fileCopy' )
    {
      if( self.filesAreSame( record.dst, record.src ) )
      {
        // record.action = 'terminalPreserve';
        return false;
      }
    }

    return true;
  }

  /* */

  function link( record )
  {
    _.assert( !record.action );
    _.assert( !record.upToDate );
    _.assert( o.writing );

    if( o.linking === 'hardlink' )
    {
      /* qqq : should not change time of file if it is already linked */
      self.linkHard
      ({
        dstPath : record.dst.absoluteEffective,
        srcPath : record.src.absoluteEffective,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( o.linking === 'softlink' )
    {
      /* qqq : should not change time of file if it is already linked */
      self.linkSoft
      ({
        dstPath : record.dst.absoluteEffective,
        srcPath : record.src.absoluteEffective,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
        allowMissing : 1,
      });
    }
    else if( o.linking === 'fileCopy' )
    {
      self.fileCopy
      ({
        dstPath : record.dst.absoluteEffective,
        srcPath : record.src.absoluteEffective,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( o.linking === 'nop' )
    {
    }
    else _.assert( 0 );

    record.action = o.linking;
  }

  /* */

  function handleUp( record, op )
  {

    // console.log( 'handleUp', record.src.absolute );

    if( !record.src.stat )
    {
      return record;
    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        if( !o.writing )
        return notAllowed( record,true );
        o.dstProvider.directoryMake( record.dst.absolute );
        record.action = 'directoryMake';
      }
      else if( record.dst.isDir )
      {
        record.action = 'directoryPreserve';
      }
      else
      {
        if( !o.dstRewritingByDistinct || !o.dstRewriting )
        return notAllowed( record,false );
        if( !o.writing )
        return notAllowed( record,true );

        o.dstProvider.fileDelete( record.dst.absolute );
        o.dstProvider.directoryMake( record.dst.absolute );
        record.action = 'directoryMake';
      }

    }
    else
    {

      if( !record.dst.stat )
      {
        if( !o.writing )
        return notAllowed( record,true );
        if( record.upToDate )
        return upToDate( record );
        if( !canLink( record ) )
        return terminalPreserve( record );
        link( record );
      }
      else if( record.dst.isDir )
      {
        if( !o.dstRewritingByDistinct || !o.dstRewriting )
        return notAllowed( record,false );
        if( !o.writing )
        return notAllowed( record,true );
        return record;
      }
      else
      {
        if( !o.dstRewriting )
        return notAllowed( record,false );
        if( !o.writing )
        return notAllowed( record,true );
        if( record.upToDate )
        return upToDate( record );
        if( !canLink( record ) )
        return terminalPreserve( record );
        debugger;
        o.dstProvider.fileDelete( record.dst.absolute );
        link( record );
      }

    }

    if( o.preservingTime )
    o.dstProvider.fileTimeSet( record.dst.absoluteEffective, record.src.stat );

    return record;
  }

  /* */

  function handleDown( record,op )
  {

    // console.log( 'handleDown', record.src.absolute );

    if( !record.src.stat )
    {
      _.assert( _.objectIs( record.dst.stat ) );

      if( !o.writing )
      return record;
      if( record.dstAction === 'deleting' && !o.dstDeleting )
      return record;
      if( record.dstAction === 'rewriting' && !o.dstRewriting )
      return record;

      record.dstAction = null;
      record.action = 'fileDelete';
      // debugger;
      o.dstProvider.fileDelete( record.dst.absolute );

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
      }
      else if( record.dst.isDir )
      {
      }
      else
      {
        if( record.dstAction === 'rewriting' && !o.dstRewriting )
        return record;
        record.dstAction = null;
        _.assert( _.strIs( record.action ) );
      }

    }
    else
    {

      if( !record.dst.stat )
      {
      }
      else if( record.dst.isDir )
      {

        if( !o.dstRewritingByDistinct || !o.dstRewriting )
        return false;

        if( !o.writing )
        return record;

        if( !canLink( record ) )
        return terminalPreserve( record );

        record.dstAction = null;

        if( o.includingDst )
        o.dstProvider.fileDelete( record.dst.absolute );
        else
        o.dstProvider.filesDelete( record.dst.absolute );

        link( record );

      }
      else
      {
      }

    }

    _.assert( !record.dstAction );
    _.assert( _.strIs( record.action ) );

    if( o.srcDeleting && o.writing )
    {

      if( !record.src.stat )
      {
      }
      else if( record.src.isDir )
      {
        if( !( record.action === 'directoryMake' || record.action === 'directoryPreserve' ) )
        {
          debugger; throw _.err( 'not tested' ); /* qqq : add test case */
        }
        if( record.action === 'directoryMake' || record.action === 'directoryPreserve' )
        if( !o.srcProvider.directoryRead( record.src.absolute ).length )
        {
          record.srcAction = 'fileDelete';
          o.srcProvider.fileDelete( record.src.absolute );
        }
      }
      else
      {
        if( record.action === 'linkHard' || record.action === 'fileCopy' )
        {
          o.srcProvider.fileDelete( record.src.absolute );
          record.srcAction = 'fileDelete';
        }
      }

    }

    return record;
  }

}

// _.routineExtend( _filesReflect_body, filesCompareFast.body );
_.routineExtend( _filesReflect_body, filesCompare.body );

var defaults = _filesReflect_body.defaults;

defaults.reflectMap = null;
defaults.linking = 'fileCopy';
defaults.srcDeleting = 0;
defaults.dstDeleting = 0;
defaults.writing = 1;
defaults.dstRewriting = 1;
defaults.dstRewritingByDistinct = 1;
defaults.preservingTime = 0;
defaults.preservingSame = 0;

defaults.breakingSrcHardLink = null;
defaults.resolvingSrcSoftLink = null;
defaults.resolvingSrcTextLink = null;
defaults.breakingDstHardLink = null;
defaults.resolvingDstSoftLink = null;
defaults.resolvingDstTextLink = null;

let filesReflect = _.routineForPreAndBody( _filesCompare_pre, _filesReflect_body );

//

function filesReflector()
{
  let self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  let op = arguments[ 0 ]
  if( arguments.length === 2 )
  op = { dstPath : arguments[ 0 ] , srcPath : arguments[ 1 ] }

  _.assertMapHasOnly( op,filesReflector.defaults );

  function move( path, op2 )
  {
    _.assert( arguments.length === 1 || arguments.length === 2 );
    _.assert( _.strIs( path ) );

    let o = _.mapExtend( null,op );
    o.srcPath = self.path.join( o.srcPath,path );
    o.dstPath = self.path.join( o.dstPath,path );

    if( op2 )
    {
      _.assert( _.mapIs( op2 ) );
      if( op2.filter && o.filter )
      {
        o.filter = _.FileRecordFilter.And( o.filter,op2.filter );
        delete op2.filter;
      }
      _.mapExtend( o,op2 )
    }

    return self.filesReflect( o );
  }

  return move;
}

_.routineExtend( filesReflector, filesReflect.body );

//

function _filesGrab_body( o )
{
  let self = this;

  if( o.recipe === null )
  {
    let o2 = _.mapOnly( o, self.filesReflect.defaults );
    return self.filesReflect( o2 );
  }

  _.assert( _.mapIs( o.recipe ) );
  _.assert( !o.fileProviderEffective );

  o.result = o.result || [];

  for( let glob in o.recipe )
  {
    let use = o.recipe[ glob ];
    _.assert( _.boolLike( use ) );
    if( use )
    {
      let o2 = _.mapOnly( o, self.filesReflect.defaults );
      o2.srcFilter = _.entityAssign( null, o2.srcFilter );
      o2.dstFilter = _.entityAssign( null, o2.dstFilter );
      o2.onDown = _.entityAssign( null, o2.onDown );
      o2.onUp = _.entityAssign( null, o2.onUp );
      o2.result = [];

      o2.srcPath = glob;
      // o2.srcBasePath = o.srcPath; /* xxx */

      self.filesReflect( o2 );
      if( o2.outputFormat === 'record' )
      _.arrayAppendArrayOnce( o.result, o2.result, ( r ) => r.dst.absolute );
      else
      _.arrayAppendArrayOnce( o.result, o2.result );
    }
    else
    {
      let o2 = _.mapOnly( o, self.filesDelete.defaults );
      o2.fileProviderEffective = o.dstProvider;
      o2.filter = o2.filter || Object.create( null );
      o2.result = [];
      o2.basePath = o.dstPath;
      o2.filePath = glob;
      o2.includingTransients = 0;
      debugger;
      o2.fileProviderEffective.filesDelete( o2 );
      debugger;
      if( o2.outputFormat === 'record' )
      _.arrayRemoveArrayOnce( o.result, o2.result, ( r1,r2 ) => r1.dst.absolute === r2.absolute );
      else
      _.arrayRemoveArrayOnce( o.result, o2.result );
      debugger;
    }
  }

  return o.result;
}

_.routineExtend( _filesGrab_body, filesReflect );

var defaults = _filesGrab_body.defaults;

defaults.srcPath = '/';
defaults.dstPath = '/';
defaults.recipe = null;
defaults.includingDst = false;

let filesGrab = _.routineForPreAndBody( _filesCompareFast_pre, _filesGrab_body );

// --
// same
// --

// function filesFindSameOld()
// {
//   let self = this;
//   let o = self._filesFind_pre( filesFindSameOld,arguments );
//
//   // _filesFindMasksAdjust( o );
//   //
//   // _.routineOptions( filesFindSameOld,o );
//   // self._providerOptions( o );
//
//   if( !o.filePath )
//   throw _.err( 'filesFindSameOld :','expects "o.filePath"' );
//
//   /* output format */
//
//   o.outputFormat = 'record';
//
//   /* result */
//
//   let result = o.result;
//   _.assert( _.objectIs( result ) );
//
//   if( !result.sameContent && o.usingContentComparing ) result.sameContent = [];
//   if( !result.sameName && o.usingSameNameCollecting ) result.sameName = [];
//   if( !result.linked && o.usingLinkedCollecting ) result.linked = []
//   if( !result.similar && o.similarity ) result.similar = [];
//
//   /* time */
//
//   let time;
//   if( o.usingTiming )
//   time = _.timeNow();
//
//   /* find */
//
//   let findOptions = _.mapOnly( o, filesFind.defaults );
//   findOptions.outputFormat = 'record';
//   findOptions.result = [];
//   findOptions.strict = 0;
//   result.unique = self.filesFind( findOptions );
//
//   /* adjust found */
//
//   for( let f1 = 0 ; f1 < result.unique.length ; f1++ )
//   {
//
//     let file1 = result.unique[ f1 ];
//
//     if( !file1.stat )
//     {
//       console.warn( 'WARN : cant read : ' + file1.absolute );
//       continue;
//     }
//
//     if( o.usingContentComparing )
//     if( file1.hash === undefined )
//     {
//       if( file1.stat.size > o.maxSize )
//       file1.hash = NaN;
//     }
//
//   }
//
//   /* link */
//
//   function checkLink()
//   {
//
//     if( self.filesAreHardLinked( file1.absolute,file2.absolute ) )
//     {
//       file2._linked = 1;
//       if( o.usingLinkedCollecting )
//       linkedRecord.push( file2 );
//       return true;
//     }
//
//     return false;
//   }
//
//   /* content */
//
//   function checkContent()
//   {
//
//     // if( file1.absolute.indexOf( 'NameTools.s' ) !== -1 && file2.absolute.indexOf( 'NameTools.s' ) !== -1 )
//     // debugger;
//
//     let same = false;
//     if( o.usingContentComparing )
//     same = self.filesAreSame( file1,file2/*,o.usingTiming*/ );
//     if( same )
//     {
//
//       if( o.usingTakingNameIntoAccountComparingContent && file1.file !== file2.file )
//       return false;
//
//       if( !file2._haveSameContent )
//       {
//         file2._haveSameContent = 1;
//         sameContentRecord.push( file2 );
//         return true;
//       }
//
//     }
//
//     return false;
//   }
//
//   /* similarity */
//
//   function checkSimilarity()
//   {
//
//     if( o.similarity )
//     if( file1.stat.size <= o.lattersFileSizeLimit && file1.stat.size <= o.lattersFileSizeLimit )
//     if( Math.min( file1.stat.size,file2.stat.size ) / Math.max( file1.stat.size,file2.stat.size ) >= o.similarity )
//     {
//       let similarity = _.files.filesSimilarity({ src1 : file1, src2 : file2 });
//       if( similarity >= o.similarity )
//       {
//         /*let similarity = _.files.filesSimilarity({ src1 : file1, src2 : file2 });*/
//         result.similar.push({ files : [ file1,file2 ], similarity : similarity });
//         return true;
//       }
//     }
//
//     return false;
//   }
//
//   /* name */
//
//   function checkName()
//   {
//
//     if( o.usingSameNameCollecting )
//     if( file1.file === file2.file && !file2._haveSameName )
//     {
//       file2._haveSameName = 1;
//       sameNameRecord.push( file2 );
//       return true;
//     }
//
//     return false;
//   }
//
//   /* compare */
//
//   let sameNameRecord, sameContentRecord, linkedRecord;
//   for( let f1 = 0 ; f1 < result.unique.length ; f1++ )
//   {
//
//     let file1 = result.unique[ f1 ];
//
//     if( !file1.stat )
//     continue;
//
//     sameNameRecord = [ file1 ];
//     sameContentRecord = [ file1 ];
//     linkedRecord = [ file1 ];
//
//     for( let f2 = f1 + 1 ; f2 < result.unique.length ; f2++ )
//     {
//
//       let file2 = result.unique[ f2 ];
//
//       if( !file2.stat )
//       continue;
//
//       checkName();
//
//       if( checkLink() )
//       {
//         result.unique.splice( f2,1 );
//         f2 -= 1;
//       }
//       else if( checkContent() )
//       {
//         result.unique.splice( f2,1 );
//         f2 -= 1;
//       }
//       else
//       {
//         checkSimilarity();
//       }
//
//     }
//
//     /* store */
//
//     if( linkedRecord && linkedRecord.length > 1 )
//     {
//       if( !o.usingFast )
//       _.assert( _.arrayCountUnique( linkedRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in linkedRecord' );
//       result.linked.push( linkedRecord );
//     }
//
//     if( sameContentRecord && sameContentRecord.length > 1  )
//     {
//       if( !o.usingFast )
//       _.assert( _.arrayCountUnique( sameContentRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameContentRecord' );
//       result.sameContent.push( sameContentRecord );
//     }
//
//     if( sameNameRecord && sameNameRecord.length > 1 )
//     {
//       if( !o.usingFast )
//       _.assert( _.arrayCountUnique( sameNameRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameNameRecord' );
//       result.sameName.push( sameNameRecord );
//     }
//
//   }
//
//   /* output format */
//
//   if( o.outputFormat !== 'record' )
//   throw _.err( 'not tested' );
//
//   if( o.outputFormat !== 'record' )
//   for( let r in result )
//   {
//     if( r === 'unique' )
//     result[ r ] = _.entitySelect( result[ r ],'*.' + o.outputFormat );
//     else
//     result[ r ] = _.entitySelect( result[ r ],'*.*.' + o.outputFormat );
//   }
//
//   /* validation */
//
//   _.accessorForbid( result,{ same : 'same' } );
//
//   /* timing */
//
//   if( o.usingTiming )
//   logger.log( _.timeSpent( 'Spent to find same at ' + o.filePath,time ) );
//
//   return result;
// }
//
// _.routineExtend( filesFindSameOld, filesFind );
//
// var defaults = filesFindSameOld.defaults;
//
// defaults.maxSize = 1 << 22;
// defaults.lattersFileSizeLimit = 1048576;
// defaults.similarity = 0;
//
// defaults.usingFast = 1;
// defaults.usingContentComparing = 1;
// defaults.usingTakingNameIntoAccountComparingContent = 1;
// defaults.usingLinkedCollecting = 0;
// defaults.usingSameNameCollecting = 0;
//
// defaults.usingTiming = 0;
//
// defaults.result = {};

//

function _filesFindSame_body( o )
{
  let self = this;
  let logger = self.logger;
  let r = o.result = o.result || Object.create( null );

  /* result */

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( r ) );
  _.assert( _.strIs( o.filePath ) );
  _.assert( o.outputFormat === 'record' );

  /* time */

  let time;
  if( o.usingTiming )
  time = _.timeNow();

  /* find */

  let findOptions = _.mapOnly( o, filesFind.defaults );
  findOptions.outputFormat = 'record';
  findOptions.result = [];
  r.unique = self.filesFind.body.call( self, findOptions );

  /* adjust found */

  for( let f1 = 0 ; f1 < r.unique.length ; f1++ )
  {
    let file1 = r.unique[ f1 ];

    if( !file1.stat )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

    if( file1.isDir )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

    if( !file1.stat.size > o.maxSize )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

  }

  /* compare */

  r.similarArray = [];
  r.similarMaps = Object.create( null );
  r.similarGroupsArray = [];
  r.similarGroupsMap = Object.create( null );
  r.similarFilesInTotal = 0;
  r.linkedFilesMap = Object.create( null );
  r.linkGroupsArray = [];

  /* */

  for( let f1 = 0 ; f1 < r.unique.length ; f1++ )
  {
    let file1 = r.unique[ f1 ]
    let path1 = o.relativePaths ? file1.relative : file1.absolute;

    for( let f2 = f1 + 1 ; f2 < r.unique.length ; f2++ )
    {

      let file2 = r.unique[ f2 ];
      let path2 = o.relativePaths ? file2.relative : file2.absolute;
      let minSize = Math.min( file1.stat.size, file2.stat.size );
      let maxSize = Math.max( file1.stat.size, file2.stat.size );

      if( _.fileStatsCouldBeLinked( file1.stat, file2.stat ) )
      {
        // console.log( 'linked :', file1.absolute, file2.absolute );
        // if( _.strHas( file1.absolute, 'fonts/icons' ) )
        // debugger;
        linkAdd();
        continue;
      }

      if( minSize / maxSize < o.similarityLimit )
      continue;

      if( !file1.stat.hash )
      file1.stat.hash = _.strLattersSpectre( self.fileRead( file1.absolute ) );
      if( !file2.stat.hash )
      file2.stat.hash = _.strLattersSpectre( self.fileRead( file2.absolute ) );

      if( self.verbosity >= 4 )
      logger.log( '. strLattersSpectresSimilarity', path1, path2 );
      let similarity = _.strLattersSpectresSimilarity( file1.stat.hash, file2.stat.hash );

      if( similarity < o.similarityLimit )
      continue;

      similarityAdd( similarity );

    }

  }

  /* */

  similarGroupsRefine();
  linkGroupsRefine();

  return o.result;

  /* */

  function similarityAdd( similarity )
  {

    let d = Object.create( null );
    d.path1 = path1;
    d.path2 = path2;
    d.similarity = similarity;
    d.id = r.similarArray.length;
    r.similarArray.push( d );

    let similarMap = r.similarMaps[ path1 ] = r.similarMaps[ path1 ] || Object.create( null );
    similarMap[ path2 ] = d;
    let similarMap = r.similarMaps[ path2 ] = r.similarMaps[ path2 ] || Object.create( null );
    similarMap[ path1 ] = d;

    let group1 = r.similarGroupsMap[ path1 ];
    let group2 = r.similarGroupsMap[ path2 ];

    if( !group1 )
    r.similarFilesInTotal += 1;

    if( !group2 )
    r.similarFilesInTotal += 1;

    if( group1 && group2 )
    {
      if( group1 === group2 )
      return;
      groupMove( group1, group2 );
    }

    let group = group1 || group2;

    if( !group )
    {
      group = Object.create( null );
      group.paths = [];
      group.paths.push( path1 );
      group.paths.push( path2 );
      r.similarGroupsArray.push( group );
    }
    else if( !group1 )
    {
      _.arrayAppendOnceStrictly( group.paths, path1 );
    }
    else if( !group2 )
    {
      _.arrayAppendOnceStrictly( group.paths, path2 );
    }

    r.similarGroupsMap[ path1 ] = group;
    r.similarGroupsMap[ path2 ] = group;

    // if( r.similarGroupsMap[ path2 ] )
    // {
    //   debugger;
    //   if( r.similarGroupsMap[ similarGroup1 ] )
    //   similarGroup1 = groupMove( path2, similarGroup1 );
    // }
    // else
    // {
    //   r.similarFilesInTotal += 1;
    //
    //   if( !r.similarGroupsMap[ similarGroup1 ] )
    //   {
    //     _.arrayAppendOnceStrictly( r.similarGroupsArray, similarGroup1 );
    //     r.similarGroupsMap[ similarGroup1 ] = [];
    //     r.similarFilesInTotal += 1;
    //   }
    //
    //   let group = r.similarGroupsMap[ similarGroup1 ]
    //   _.arrayAppendOnce( group, path1 );
    //   _.arrayAppendOnce( group, path2 );
    //
    // }

  }

  /* */

  function groupMove( dst, src )
  {
    debugger;

    _.arrayAppendArrayOnceStrictly( dst.paths, src.paths );
    _.arrayRemoveOnceStrictly( r.similarGroupsArray, src );

    // if( _.strIs( r.similarGroupsMap[ dst ] ) )
    // debugger;
    // if( _.strIs( r.similarGroupsMap[ dst ] ) )
    // dst = r.similarGroupsMap[ dst ];
    // _.assert( _.arrayIs( r.similarGroupsMap[ src ] ) );
    // _.assert( _.arrayIs( r.similarGroupsMap[ dst ] ) );
    // for( let i = 0 ; i < r.similarGroupsMap[ src ].length ; i++ )
    // {
    //   debugger;
    //   let srcElement = r.similarGroupsMap[ src ][ i ];
    //   _.assert( _.strIs( r.similarGroupsMap[ srcElement ] ) || srcElement === src );
    //   _.arrayAppendOnceStrictly( r.similarGroupsMap[ dst ], srcElement );
    //   r.similarGroupsMap[ srcElement ] = dst;
    // }
    // _.arrayRemoveOnceStrictly( r.similarGroupsArray, src );

    return dst;
  }

  /* */

  function similarGroupsRefine()
  {
    for( let g in r.similarGroupsMap )
    {
      let group = r.similarGroupsMap[ g ];
      group.id = r.similarGroupsArray.indexOf( group );
      r.similarGroupsMap[ g ] = group.id;
    }
  }

  /* */

  function linkAdd()
  {
    let d1 = r.linkedFilesMap[ path1 ];
    let d2 = r.linkedFilesMap[ path2 ];
    _.assert( !d1 || !d2, 'Two link descriptors for the same instance of linked file', path1, path2 );
    let d = d1 || d2;
    if( !d )
    {
      d = Object.create( null );
      d.paths = [];
      d.paths.push( path1 );
      d.paths.push( path2 );
      r.linkGroupsArray.push( d );
    }
    else if( !d1 )
    {
      _.arrayAppendOnceStrictly( d.paths, path1 );
    }
    else
    {
      _.arrayAppendOnceStrictly( d.paths, path2 );
    }
    r.linkedFilesMap[ path1 ] = d;
    r.linkedFilesMap[ path2 ] = d;
  }

  /* */

  function linkGroupsRefine()
  {
    for( let f in r.linkedFilesMap )
    {
      let d = r.linkedFilesMap[ f ];
      d.id = r.linkGroupsArray.indexOf( d )
      r.linkedFilesMap[ f ] = d.id;
    }
  }

}

_.routineExtend( _filesFindSame_body, filesFindRecursive );

var defaults = _filesFindSame_body.defaults;

defaults.maxSize = 1 << 22;
// defaults.lattersFileSizeLimit = 1048576;
defaults.similarityLimit = 0.95;

// defaults.usingFast = 1;
// defaults.usingContentComparing = 1;
// defaults.usingTakingNameIntoAccountComparingContent = 1;
// defaults.usingLinkedCollecting = 0;
// defaults.usingSameNameCollecting = 0;

defaults.investigatingLinking = 1;
defaults.investigatingSimilarity = 1;
defaults.usingTiming = 0;
defaults.relativePaths = 0;

defaults.result = null;

let filesFindSame = _.routineForPreAndBody( _filesFind_pre, _filesFindSame_body );

filesFindSame.having.aspect = 'entry';

// --
// delete
// --

function _filesDelete_pre( routine,args )
{
  let self = this;
  args = _.longSlice( args );
  // if( args[ 1 ] === undefined )
  // args[ 1 ] = null;
  let o = self.__filesFind_pre( routine, args, 0 );
  return o;
}

//

function _filesDelete_body( o )
{
  let self = this;

  let time;
  if( o.verbosity >= 2 )
  time = _.timeNow();

  _.assert( !o.includingTransients, 'Transient files should not be included' );
  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( o.outputFormat === 'record' );
  _.assert( arguments.length === 1 );

  /* */

  // _.each( o.filePath, () =>

  let exists = self.fileExists( o.filePath );
  // let stat = self.fileStat( o.filePath );
  // let stat = self.fileExists( o.filePath );

  if( !exists )
  return;

  let stat = self.fileStat({ filePath : o.filePath, throwing : 1, resolvingSoftLink : 0 });

  if( stat.isFile() )
  return self.fileDelete
  ({
    filePath : o.filePath,
    sync : 1,
    throwing :  o.throwing,
    verbosity : o.verbosity
  });

  /* */

  // debugger;
  let optionsForFind = _.mapOnly( o, self.filesFind.defaults );
  optionsForFind.verbosity = 0;
  self.fieldSet( 'resolvingSoftLink', 0 );
  // debugger;
  let files = self.filesFind.body.call( self, optionsForFind );
  // debugger;
  self.fieldReset( 'resolvingSoftLink', 0 );
  // debugger;

  /* */

  for( let f = files.length-1 ; f >= 0 ; f-- )
  {
    let file = files[ f ];
    file.context.fileProviderEffective.fileDelete
    ({
      filePath : file.absolute,
      sync : 1,
      throwing : o.throwing,
      verbosity : o.verbosity-1,
    });
  }

  if( o.verbosity >= 2 )
  logger.log( _.timeSpent( 'filesDelete ' + o.result.length + ' files at ' + o.filePath + ' in', time ) );

}

_.routineExtend( _filesDelete_body, filesFind );

var defaults = _filesDelete_body.defaults;

defaults.outputFormat = 'record';
defaults.recursive = 1;
defaults.includingTransients = 0;
defaults.includingDirectories = 1;
defaults.includingTerminals = 1;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;
defaults.verbosity = null;

defaults.throwing = null;

//

let filesDelete = _.routineForPreAndBody( _filesDelete_pre, _filesDelete_body );

filesDelete.having.aspect = 'entry';

var defaults = filesDelete.defaults;
var paths = filesDelete.paths;
var having = filesDelete.having;

_.assert( !!defaults );
_.assert( !!paths );
_.assert( !!having );

//

function filesDeleteForce( o )
{
  let self = this;

  o = self._filesFindOptions( arguments,0 );

  _.routineOptions( filesDeleteForce, o );

  return self.filesDelete( o );
}

_.routineExtend( filesDeleteForce, filesDelete );

var defaults = filesDeleteForce.defaults;

//

function filesDeleteFiles( o )
{
  let self = this;

  o = self._filesFindOptions( arguments,0 );

  _.routineOptions( filesDeleteFiles, o );

  _.assert( o.includingTerminals );
  _.assert( !o.includingDirectories );
  _.assert( !o.includingTransients );

  _.assert( 0, 'not tested' ); // qqq

  return self.filesDelete( o );
}

_.routineExtend( filesDeleteFiles, filesDelete );

defaults.recursive = 1;
defaults.includingTerminals = 1;
defaults.includingDirectories = 0;
defaults.includingTransients = 0;

//

/*
qqq : add test coverage, extract pre and body, please
*/

function filesDeleteEmptyDirs()
{
  let self = this;

  // _.assert( arguments.length === 1 || arguments.length === 3 );
  // let o = self._filesFindOptions( arguments,1 );

  debugger;
  let o = filesDeleteEmptyDirs.pre.call( self,filesDeleteEmptyDirs,arguments );
  debugger;

  /* */

  // _.assert( 0, 'not tested' ); // qqq

  o.outputFormat = 'absolute'; // qqq
  // o.includingTerminals = 0;
  // o.includingTransients = 1;

  _.assert( !o.includingTerminals );
  _.assert( o.includingDirectories );
  _.assert( !o.includingTransients );

  if( o.recursive === undefined )
  o.recursive = 1;

  // _.routineOptions( filesDeleteEmptyDirs, o );

  /* */

  let options = _.mapOnly( o, self.filesFind.defaults );

  options.onDown = _.arrayAppendElement( _.arrayAs( o.onDown ), function( record )
  {

    try
    {

      let sub = self.directoryRead( record.absolute );
      if( !sub )
      debugger;

      if( !sub.length )
      {
        if( self.verbosity >= 2 )
        logger.log( '- deleted :',record.absolute );
        self.fileDelete({ filePath : record.absolute, throwing : o.throwing });
      }
    }
    catch( err )
    {
      if( !o.throwing )
      throw _.err( err );
    }

  });

  debugger;
  let files = self.filesFind.body.call( self, options );
  debugger;

  // return new _.Consequence().give();
}

_.routineExtend( filesDeleteEmptyDirs, filesDelete );

var defaults = filesDeleteEmptyDirs.defaults;

defaults.throwing = false;
defaults.verbosity = null;
defaults.outputFormat = 'absolute';
defaults.includingTerminals = 0;
defaults.includingDirectories = 1;
defaults.includingTransients = 0;
defaults.recursive = 1;

// --
// other find
// --

function softLinksBreak( o )
{
  let self = this;

  o = self._filesFind_pre( softLinksBreak,arguments );

  _.assert( o.outputFormat === 'record' );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {

    debugger;
    throw _.err( 'not tested' );

    if( o.breakingSoftLink && record.isSoftLink )
    self.softLinkBreak( record.absolute );
    if( o.breakingTextLink && record.isTextLink )
    self.softLinkBreak( record.absolute );

  });

  let files = self.filesFind.body.call( self,optionsFind );

  return files;
}

_.routineExtend( softLinksBreak, filesFind );

var defaults = softLinksBreak.defaults;

defaults.outputFormat = 'record';
defaults.breakingSoftLink = 1;
defaults.breakingTextLink = 0;
defaults.recursive = 1;

//

function softLinksRebase( o )
{
  let self = this;
  o = self._filesFind_pre( softLinksRebase,arguments );

  _.assert( o.outputFormat === 'record' );
  _.assert( !o.resolvingSoftLink );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {
    if( !record.isSoftLink )
    return;

    record.isSoftLink;
    let resolvedPath = self.pathResolveSoftLink( record.absoluteEffective );
    let rebasedPath = self.path.rebase( resolvedPath, o.oldPath, o.newPath );
    self.fileDelete({ filePath : record.absoluteEffective, verbosity : 0 });
    self.linkSoft
    ({
      dstPath : record.absoluteEffective,
      srcPath : rebasedPath,
      allowMissing : 1,
    });
    _.assert( !!self.fileStat({ filePath : record.absoluteEffective, resolvingSoftLink : 0 }) );
  });

  let files = self.filesFind.body.call( self,optionsFind );

  return files;
}

_.routineExtend( softLinksRebase, filesFind );

var defaults = softLinksRebase.defaults;

defaults.outputFormat = 'record';
defaults.oldPath = null;
defaults.newPath = null;
defaults.recursive = 1;
defaults.resolvingSoftLink = 0;

// --
// resolver
// --

function filesResolve( o )
{
  let self = this;
  let result;
  var o = _.routineOptions( filesResolve,arguments );

  _.assert( _.objectIs( o.translator ) );

  let globPath = o.translator.realFor( o.globPath );
  let globOptions = _.mapOnly( o, self.filesGlob.defaults );

  globOptions.filter = globOptions.filter || Object.create( null );
  globOptions.filePath = globPath;
  globOptions.filter.basePath = o.translator.realRootPath;
  globOptions.outputFormat = o.outputFormat;

  _.assert( !!self );

  result = self.filesGlob( globOptions );

  return result;
}

_.routineExtend( filesResolve, filesGlob );

var defaults = filesResolve.defaults;

defaults.recursive = 1;
defaults.globPath = null;
defaults.translator = null;
defaults.outputFormat = 'record';

var paths = filesResolve.paths;

paths.globPath = null;

// --
// relationship
// --

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

// --
// declare
// --

let Supplement =
{

  // etc

  recordsOrder : recordsOrder,
  _filesFilterMasksSupplement : _filesFilterMasksSupplement,

  // find

  _filesFindOptions : _filesFindOptions,
  // _filesFindGlobAdjust : _filesFindGlobAdjust,
  // _filesFindMasksAdjust : _filesFindMasksAdjust,
  _filesFilterForm : _filesFilterForm,
  __filesFind_pre : __filesFind_pre,
  _filesFind_pre : _filesFind_pre,

  _filesFindFast : _filesFindFast,
  filesFind : filesFind,
  filesFindRecursive : filesFindRecursive,
  filesGlob : filesGlob,

  filesFinder : filesFinder,
  filesGlober : filesGlober,

  // difference

  // filesFindDifference : filesFindDifference,
  // filesCopyOld : filesCopyOld,
  filesCopyWithAdapter : filesCopyWithAdapter,

  // move

  filesCompareFast : filesCompareFast,
  filesCompare : filesCompare,
  filesReflect : filesReflect,
  filesReflector : filesReflector,

  filesGrab : filesGrab,

  // same

  // filesFindSameOld : filesFindSameOld,
  filesFindSame : filesFindSame,

  // delete

  filesDelete : filesDelete,

  filesDeleteForce : filesDeleteForce,
  filesDeleteFiles : filesDeleteFiles,
  filesDeleteEmptyDirs : filesDeleteEmptyDirs,

  // other find

  softLinksBreak : softLinksBreak,
  softLinksRebase : softLinksRebase,

  // resolver

  filesResolve : filesResolve,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

let Self =
{

  supplement : Supplement,

  name : 'wFilePorviderFindMixin',
  shortName : 'Find',
  onMixin : onMixin,

}

//

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.shortName ] = _.mixinDelcare( Self );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
