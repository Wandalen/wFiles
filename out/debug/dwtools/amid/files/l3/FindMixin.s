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

/**
 @class wFileProviderFind
 @memberof module:Tools/mid/Files.wTools.FileProvider
*/

let Parent = null;
let Self = function wFileProviderFind( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Find';

// let debugPath = '/dstNew';

// --
// etc
// --

function recordsOrder( records, orderingExclusion )
{

  _.assert( _.arrayIs( records ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( !orderingExclusion.length )
  return records;

  orderingExclusion = _.RegexpObject.Order( orderingExclusion || [] );

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

  return _.arrayAppendArrays( [], result );
}

//
//
// function _filesFilterMasksSupplement( dst, src )
// {
//   _.assert( arguments.length === 2, 'Expects exactly two arguments' );
//
//   _.mapSupplement( dst, src );
//
//   dst.maskDirectory = _.RegexpObject.And( null, dst.maskDirectory || Object.create( null ), src.maskDirectory || Object.create( null ) );
//   dst.maskTerminal = _.RegexpObject.And( null, dst.maskTerminal || Object.create( null ), src.maskTerminal || Object.create( null ) );
//   dst.maskAll = _.RegexpObject.And( null, dst.maskAll || Object.create( null ), src.maskAll || Object.create( null ) );
//
//   return dst;
// }

// --
// files find
// --

function _filesFindPrepare0( routine, args )
{
  let o;

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );

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

  }

  _.routineOptions( routine, o );

  if( Config.debug )
  {

    // _.assert( _.arrayHas( [ 'legacy', 'distinct' ], o.mode ), () => 'Unknown mode ' + _.strQuote( o.mode ) );
    _.assert( arguments.length === 2 );
    _.assert( 1 <= args.length && args.length <= 3 );
    _.assert( o.basePath === undefined );
    _.assert( o.prefixPath === undefined );
    _.assert( o.postfixPath === undefined );

    // let knownFormats = [ 'absolute', 'relative', 'real', 'record', 'nothing' ];
    // _.assert
    // (
    //   _.arrayHas( knownFormats, o.outputFormat ),
    //     'Unknown output format ' + _.toStrShort( o.outputFormat )
    //   + '\nKnown output formats ' + _.toStr( knownFormats )
    // );

  }

  return o;
}

//

function _filesFindPrepare1( routine, args )
{
  let self = this;
  let path = self.path;
  let o = args[ 0 ];

  // let o = self._filesFindPrepare0( routine, args );
  // self._filesFindFilterPrepare( o );

  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );

  let hasGlob = o.filter.filePathHasGlob();

  if( o.recursive === null )
  {
    if( o.mode === 'distinct' )
    o.recursive = hasGlob ? 2 : 0;
    else
    o.recursive = hasGlob ? 2 : 1;
  }
  if( o.filter.recursive === null )
  o.filter.recursive = o.recursive;

  if( o.includingDefunct === null )
  {
    if( o.mode === 'distinct' )
    o.includingDefunct = !hasGlob;
    else
    o.includingDefunct = false;
  }

  if( o.onUp === null )
  o.onUp = [];

  if( o.onDown === null )
  o.onDown = [];

  // if( o.mandatory === null )
  // {
  //   if( o.mode === 'distinct' )
  //   o.mandatory = hasGlob;
  //   else
  //   o.mandatory = false;
  // }
  //
  // if( o.result === null )
  // o.result = [];

  // if( o.orderingExclusion === null )
  // o.orderingExclusion = [];

  o.includingTerminals = !!o.includingTerminals;

  if( o.mode === 'distinct' && o.includingDirs === null )
  {
    o.includingDirs = !hasGlob;
  }
  o.includingDirs = !!o.includingDirs;

  if( o.includingStem === null )
  o.includingStem = 1;
  o.includingStem = !!o.includingStem;

  if( !o.filter.formed || o.filter.formed < 5 )
  o.filter.form();

  o.filter.effectiveFileProvider._providerDefaultsApply( o );

  if( Config.debug )
  {
    _.assert( o.recursive === 0 || o.recursive === 1 || o.recursive === 2, () => 'Incorrect value of recursive option', _.strQuote( o.recursive ), ', should be 0, 1 or 2' );
    _.assert( !self.hub || o.filter.hubFileProvider === self.hub );
    _.assert( !!o.filter.effectiveFileProvider );
    _.assert( path.s.allAreNormalized( o.filter.filePath ) );
    _.assert( o.filter.recursive === o.recursive );
  }

  return o;
}

//

function _filesFindFilterPrepare( routine, args )
{
  let self = this;
  let path = self.path;
  let o = args[ 0 ];

  _.assert( !o.filter || !o.filter.formed <= 3, 'Filter is already formed, but should not be!' )
  _.assert( arguments.length === 2 );
  _.assert( args.length === 1 );

  o.filter = self.recordFilter( o.filter || {} );

  if( o.filePath )
  {
    if( o.filePath instanceof _.FileRecordFilter )
    {
      o.filter.pathsExtend( o.filePath ).and( o.filePath );
      o.filePath = null;
    }
    else
    {
      o.filter.filePath = path.mapExtend( o.filter.filePath, o.filePath );
    }
    o.filePath = null;
  }

  // if( o.maskPreset && !o.filter.formed )
  // {
  //   _.assert( o.maskPreset === 'default.exclude', 'Not supported preset', o.maskPreset );
  //   let filter2 = { maskAll : _.files.regexpMakeSafe() };
  //   o.filter.and( filter2 );
  // }

  if( o.filter.recursive === null )
  {
    _.assert( !o.filter.formed || o.filter.formed < 5, 'o.filter.recursive should have the same value o.recursive' );
    o.filter.recursive = o.recursive;
  }

  if( !o.filter.formed )
  o.filter._formAssociations();

  return o;
}

//

function filesFindSingle_pre( routine, args )
{
  let self = this;
  let path = self.path;

  let o = self._filesFindPrepare0( routine, args );
  self._filesFindFilterPrepare( routine, [ o ] );
  self._filesFindPrepare1( routine, [ o ] );

  o.filter.effectiveFileProvider.assertProviderDefaults( o );

  _.assertRoutineOptions( filesFindSingle_body, o );
  _.assert( _.routineIs( o.onUp ) || _.arrayIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) || _.arrayIs( o.onDown ) );
  _.assert( path.isNormalized( o.filePath ), 'Expects normalized path {-o.filePath-}' );
  _.assert( path.isAbsolute( o.filePath ), 'Expects absolute path {-o.filePath-}' );
  _.assert( 0 <= o.recursive && o.recursive <= 2 );
  _.assert( o.filter.formed === 5, 'Expects formed filter' );
  _.assert( _.objectIs( o.filter.effectiveFileProvider ) );
  _.assert( _.mapIs( o.filter.formedBasePath ), 'Expects base path' );
  _.assert( _.boolLike( o.includingTerminals ) );
  _.assert( _.boolLike( o.includingDirs ) );
  _.assert( _.boolLike( o.includingStem ) );
  _.assert( o.filter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( o.filter.defaultFileProvider instanceof _.FileProvider.Abstract );
  _.assert( o.filter.recursive === o.recursive );
  _.assert( o.mandatory === undefined );
  _.assert( o.orderingExclusion === undefined );
  _.assert( o.outputFormat === undefined );
  _.assert( o.outputFormat === undefined );
  _.assert( o.safe === undefined );
  _.assert( o.maskPreset === undefined );
  _.assert( o.mode === undefined );
  _.assert( o.result === undefined );
  _.assert( !!o.factory );

  return o;
}

//

function filesFindSingle_body( o )
{
  let self = this;
  let path = self.path;

  _.assertRoutineOptions( filesFindSingle_body, arguments );
  _.assert( o.filter.recursive === o.recursive );
  _.assert( !!o.factory );
  o.filter.effectiveFileProvider.assertProviderDefaults( o );

  /* handler */

  if( _.arrayIs( o.onUp ) )
  if( o.onUp.length === 0 )
  o.onUp = function( record ){ return record };
  else
  o.onUp = _.routinesComposeAllReturningLast( o.onUp );

  if( _.arrayIs( o.onDown ) )
  o.onDown = _.routinesComposeReturningLast( o.onDown );

  // if( _.arrayIs( o.onDown ) )
  // o.onDown = _.routinesCompose( o.onDown );

  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );

  /* */

  // let recordAdd = recordAdd_functor( o );
  // o.result = o.result || [];
  Object.freeze( o );

  // let o2 =
  // {
  //   stemPath : o.filePath,
  //   basePath : o.filter.formedBasePath[ o.filePath ],
  // };
  //
  // _.assert( _.strDefined( o2.basePath ), 'No base path for', o.filePath );
  //
  // let recordFactory = _.FileRecordFactory.TollerantFrom( o, o2 ).form();

  // let factory = o.factory;
  let stemRecord = o.factory.record( o.filePath );
  _.assert( stemRecord.isStem === true );

  _.assert( o.factory.basePath === o.filter.formedBasePath[ o.filePath ] );
  _.assert( o.factory.dirPath === null );
  _.assert( o.factory.effectiveFileProvider === o.filter.effectiveFileProvider );
  _.assert( o.factory.hubFileProvider === o.filter.hubFileProvider || o.filter.hubFileProvider === null );
  _.assert( o.factory.defaultFileProvider === o.filter.defaultFileProvider );

  if( !stemRecord.stat )
  {
    if( o.includingDefunct )
    {
      // let r = handleUp( stemRecord, o );
      if( handleUp( stemRecord, o ) === _.dont )
      return o;
      // o.onRecord( stemRecord, o );
      // handleRecord( stemRecord, o  );
      handleDown( stemRecord, o );
    }
    // if( o.allowingMissed || !o.mandatory )
    // if( o.allowingMissed )
    // {
    //   return o;
    // }
    // debugger;
    // throw _.err( 'Nothing found. Stem file', _.strQuote( stemRecord.absolute ), 'does not exist!' );
    return o;
  }

  forStem( stemRecord, o );

  return o;

  /* */

  function forStem( record, op )
  {
    forDirectory( record, op )
    forTerminal( record, op )
  }

  /* */

  function forDirectory( r, op )
  {

    if( !r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    // let or = r;
    // let isTransient = r.isTransient;
    let includingTransient = ( op.includingTransient && r.isTransient && op.includingDirs );
    let includingActual = ( op.includingActual && r.isActual && op.includingDirs );
    let including = true;
    including = including && ( includingTransient || includingActual );
    including = including && ( op.includingStem || !r.isStem );
    including = including && ( op.includingDefunct || !!r.stat );

    /* up */

    if( including )
    {
      // let res = handleUp( r, op );
      if( handleUp( r, op ) === _.dont )
      {
        debugger;
        handleDown( r, op ); // xxx yyy
        return false;
      }
      // _.assert( res === r );
      // recordAdd( r );
      // op.onRecord( r, op );
      // handleRecord( r, op );
    }

    /* read */

    if( r.isTransient && op.recursive )
    if( op.recursive === 2 || r.isStem )
    {
      /* Vova : real path should be used for soft/text link to a dir for two reasons:
      - files from linked directory should be taken into account
      - usage of r.absolute path for a link will lead to recursion on next forDirectory( file, op ), because dirRead will return same path( r.absolute )
      outputFormat : relative is used because absolute path should contain path to a link in head
      */
      // let files = op.filter.effectiveFileProvider.dirRead({ filePath : r.absolute, outputFormat : 'absolute' });
      let files = op.filter.effectiveFileProvider.dirRead({ filePath : r.real, outputFormat : 'relative' });

      if( files === null )
      {
        if( op.allowingMissed )
        {
          files = [];
        }
        else
        {
          debugger;
          throw _.err( 'Failed to read directory', _.strQuote( r.absolute ) );
        }
      }

      files = self.path.s.join( r.absolute, files );
      files = r.factory.records( files );

      /* terminals */

      if( op.includingTerminals )
      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forTerminal( file, op );
      }

      /* dirs */

      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forDirectory( file, op );
      }

    }

    /* down */

    if( including )
    handleDown( r, op );

  }

  /* */

  function forTerminal( r, op )
  {

    if( r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    // let or = r;
    let includingTransient = ( op.includingTransient && r.isTransient && op.includingTerminals );
    let includingActual = ( op.includingActual && r.isActual && op.includingTerminals );
    let including = true;
    including = including && ( includingTransient || includingActual );
    including = including && ( op.includingStem || !r.isStem );
    including = including && ( op.includingDefunct || !!r.stat );

    if( !including )
    return;

    // let res = handleUp( r, op );
    // if( handleUp( r, op ) === _.dont )
    // return false;
    // _.assert( r === res );
    // op.onRecord( r, op );
    // handleRecord( r, op );
    // recordAdd( r );

    handleUp( r, op );
    handleDown( r, op );

  }

  /* - */

  function handleUp( record, op )
  {
    _.assert( arguments.length === 2 );
    let r = op.onUp.call( self, record, op );
    _.assert( r === _.dont || r === record, 'onUp should return original record or false, but returned', _.toStrShort( r ) );
    return r;
  }

  /* - */

  function handleDown( record, op )
  {
    _.assert( arguments.length === 2 );
    let r = op.onDown.call( self, record, op );
    _.assert( r === undefined, 'onDown should return nothing( undefined ), but returned', _.toStrShort( r ) );
    // return r;
  }

  // /* - */
  //
  // function handleRecord( record, op )
  // {
  //   _.assert( arguments.length === 2 );
  //   let r = op.onRecord.call( self, record, op );
  //   _.assert( r === undefined || r === record, 'onRecord should return original record or undefined, but returned', _.toStrShort( r ) );
  //   // return r;
  // }

  //
  // /* - */
  //
  // function recordAdd_functor( o )
  // {
  //   let recordAdd;
  //
  //   if( o.outputFormat === 'absolute' )
  //   recordAdd = function addAbsolute( record )
  //   {
  //     _.assert( arguments.length === 1, 'Expects single argument' );
  //     o.result.push( record.absolute );
  //   }
  //   else if( o.outputFormat === 'relative' )
  //   recordAdd = function addRelative( record )
  //   {
  //     _.assert( arguments.length === 1, 'Expects single argument' );
  //     o.result.push( record.relative );
  //   }
  //   else if( o.outputFormat === 'real' )
  //   recordAdd = function addReal( record )
  //   {
  //     _.assert( arguments.length === 1, 'Expects single argument' );
  //     o.result.push( record.real );
  //   }
  //   else if( o.outputFormat === 'record' )
  //   recordAdd = function addRecord( record )
  //   {
  //     _.assert( arguments.length === 1, 'Expects single argument' );
  //     o.result.push( record );
  //   }
  //   else if( o.outputFormat === 'nothing' )
  //   recordAdd = function addNothing( record )
  //   {
  //   }
  //   else _.assert( 0, 'Unknown output format :', o.outputFormat );
  //
  //   return recordAdd;
  // }

}

filesFindSingle_body.defaults =
{

  filePath : null,
  filter : null,
  factory : null,

  includingTerminals : 1,
  includingDirs : null,
  includingStem : 1,
  includingActual : 1,
  includingTransient : 0,
  includingDefunct : null,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  allowingMissed : 0,
  allowingCycled : 0,
  recursive : null,
  sync : 1,

  onUp : null,
  onDown : null,
  // onRecord : null,

}

var having = filesFindSingle_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesFindSingle = _.routineFromPreAndBody( filesFindSingle_pre, filesFindSingle_body );

//

/**
 * @summary Searches for files in the specified path `o.filePath`.
 * @returns Returns flat array with FileRecord instances of found files.
 * @param {Object} o Options map.
 *
 * @param {} o.filePath
 * @param {} o.filter
 * @param {} o.includingTerminals=1
 * @param {} o.includingDirs=0
 * @param {} o.includingStem=1
 * @param {} o.includingActual=1
 * @param {} o.includingTransient=0
 * @param {} o.allowingMissed=0
 * @param {} o.allowingCycled=0
 * @param {} o.recursive=1
 * @param {} o.resolvingSoftLink=0
 * @param {} o.resolvingTextLink=0
 * @param {} o.maskPreset='default.exclude'
 * @param {} o.outputFormat='record'
 * @param {} o.safe=null
 * @param {} o.sync=1
 * @param {} o.orderingExclusion=[]
 * @param {} o.sortingWithArray
 * @param {} o.verbosity
 * @param {} o.mandatory
 * @param {} o.result=[]
 * @param {} o.onUp=[]
 * @param {} o.onDown=[]
 *
 * @function filesFind
 * @memberof module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind#
 */

//

function filesFind_pre( routine, args )
{
  let self = this;
  let path = self.path;

  let o = self._filesFindPrepare0( routine, args );

  self._filesFindFilterPrepare( routine, [ o ] );

  if( Config.debug )
  {

    _.assert( _.arrayHas( [ 'legacy', 'distinct' ], o.mode ), () => 'Unknown mode ' + _.strQuote( o.mode ) );

    let knownFormats = [ 'absolute', 'relative', 'real', 'record', 'nothing' ];
    _.assert
    (
      _.arrayHas( knownFormats, o.outputFormat ),
        'Unknown output format ' + _.toStrShort( o.outputFormat )
      + '\nKnown output formats ' + _.toStr( knownFormats )
    );

  }

  let hasGlob = o.filter.filePathHasGlob();

  if( o.mandatory === null )
  {
    if( o.mode === 'distinct' )
    o.mandatory = hasGlob;
    else
    o.mandatory = false;
  }

  if( o.result === null )
  o.result = [];

  if( o.maskPreset )
  {
    _.assert( o.maskPreset === 'default.exclude', 'Not supported preset', o.maskPreset );
    o.filter = o.filter || Object.create( null );
    if( !o.filter.formed || o.filter.formed < 5 )
    _.files.filterSafer( o.filter );
  }

  if( o.orderingExclusion === null )
  o.orderingExclusion = [];

  if( o.resolvingSoftLink || o.resolvingTextLink )
  {
    if( o.once === null )
    o.once = 1;
  }

  if( o.once || o.onceHardLinked )
  if( o.visited === null )
  o.visited = Object.create( null );

  o = self._filesFindPrepare1( routine, [ o ] );

  return o;
}

function filesFind_body( o )
{
  let self = this;
  let path = self.path;
  let counter = 0;
  let ready = new _.Consequence().take( o );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( o.filePath === null );
  _.assert( o.filter.formed === 5 );
  // _.assert( o.onRecord === null, 'not implemented' );
  // _.assert( o.sync );

  if( _.arrayIs( o.onUp ) )
  if( o.onUp.length === 0 )
  o.onUp = function( record ){ return record };
  else
  o.onUp = _.routinesComposeAllReturningLast( o.onUp );

  let time;
  if( o.verbosity >= 1 )
  time = _.timeNow();

  if( o.verbosity >= 3 )
  self.logger.log( 'filesFind', _.toStr( o, { levels : 2 } ) );

  let pathMap = o.filter.formedFilePath;

  o.filePath = [];

  for( let src in pathMap )
  {
    let dst = pathMap[ src ];
    if( _.boolLike( dst ) )
    continue;
    o.filePath.push( src );
  }

  o.result = o.result || [];

  _.assert( _.strsAreAll( o.filePath ) );
  _.assert( !o.orderingExclusion.length || o.orderingExclusion.length === 0 || o.outputFormat === 'record' );

  forStems( o.filePath, o );

  return end();

  /* - */

  function forStems( stemPaths, op )
  {

    if( _.strIs( stemPaths ) )
    stemPaths = [ stemPaths ];
    stemPaths = _.longUnduplicate( stemPaths );
    _.strsSort( stemPaths );
    _.assert( _.arrayIs( stemPaths ), 'Expects path or array of paths' );

    let o2 = Object.assign( Object.create( null ), op );

    delete o2.orderingExclusion;
    delete o2.sortingWithArray;
    delete o2.verbosity;
    delete o2.mode;
    delete o2.maskPreset;
    delete o2.mandatory;
    delete o2.outputFormat;
    delete o2.safe;
    delete o2.once;
    delete o2.onceHardLinked;
    delete o2.visited;
    delete o2.result;

    o2.onUp = recordAdd_functor( op );
    // o2.onRecord = recordAdd_functor( op );

    for( let p = 0 ; p < stemPaths.length ; p++ ) ready.then( () =>
    {
      let stemPath = stemPaths[ p ];
      return forStem( stemPath, o2 )
    })

  }

  /* - */

  function forStem( stemPath, o2 )
  {
    let o3 = Object.assign( Object.create( null ), o2 );

    _.assert( _.strIs( stemPath ) );

    o3.filePath = stemPath;

    let o4 =
    {
      stemPath : stemPath,
      basePath : o2.filter.formedBasePath[ stemPath ],
    };
    _.assert( _.strDefined( o4.basePath ), 'No base path for', stemPath );
    o3.factory = _.FileRecordFactory.TollerantFrom( o3, o4 ).form();

    _.assert( o3.factory.basePath === o3.filter.formedBasePath[ stemPath ] );
    _.assert( o3.factory.dirPath === null );
    _.assert( o3.factory.effectiveFileProvider === o3.filter.effectiveFileProvider );
    _.assert( o3.factory.hubFileProvider === o3.filter.hubFileProvider || o3.filter.hubFileProvider === null );
    _.assert( o3.factory.defaultFileProvider === o3.filter.defaultFileProvider );

    let counterWas = counter;

    return _.Consequence.Try( () =>
    {
      return self.filesFindSingle.body.call( self, o3 );
    })
    .then( ( op ) =>
    {
      if( !o.mandatory )
      return op;

      if( counterWas === counter )
      {
        debugger;
        throw _.err( 'No file found at ' + stemPath );
      }
      else if( counterWas === counter-1 )
      {
        if( !o.allowingMissed )
        throw _.err( 'Stem does not exist ' + stemPath );
      }
      return op;
    })
    .catch( ( err ) =>
    {
      debugger;
      throw _.err( err );
    });

  }

  /* - */

  function handleRecord( record, op )
  {

    _.assert( arguments.length === 2, 'Expects single argument' );
    counter += 1;

    let r = o.onUp.call( self, record, op );
    _.assert( r === _.dont || r === record, 'onUp should return original record or false, but returned', _.toStrShort( r ) );
    if( r === _.dont )
    return _.dont;

    if( o.once )
    {
      if( o.visited[ record.real ] )
      {
        debugger;
        return _.dont;
      }
    }

    if( o.visited )
    o.visited[ record.real ] = record;

    return record;
  }

  /* - */

  function recordAdd_functor( fop )
  {
    let recordAdd;

    if( fop.outputFormat === 'absolute' )
    recordAdd = function addAbsolute( record, op )
    {
      if( handleRecord.apply( this, arguments ) === _.dont )
      return _.dont;
      fop.result.push( record.absolute );
      return record;
    }
    else if( fop.outputFormat === 'relative' )
    recordAdd = function addRelative( record, op )
    {
      if( handleRecord.apply( this, arguments ) === _.dont )
      return _.dont;
      fop.result.push( record.relative );
      return record;
    }
    else if( fop.outputFormat === 'real' )
    recordAdd = function addReal( record, op )
    {
      if( handleRecord.apply( this, arguments ) === _.dont )
      return _.dont;
      fop.result.push( record.real );
      return record;
    }
    else if( fop.outputFormat === 'record' )
    recordAdd = function addRecord( record, op )
    {
      if( handleRecord.apply( this, arguments ) === _.dont )
      return _.dont;
      fop.result.push( record );
      return record;
    }
    else if( fop.outputFormat === 'nothing' )
    recordAdd = function addNothing( record, op )
    {
      if( handleRecord.apply( this, arguments ) === _.dont )
      return _.dont;
      return record;
    }
    else _.assert( 0, 'Unknown output format :', o.outputFormat );

    return recordAdd;
  }

  /* - */

  function end()
  {
    ready.then( () =>
    {

      /* order */

      o.result = self.recordsOrder( o.result, o.orderingExclusion );

      /* sort */

      if( o.sortingWithArray )
      {

        _.assert( _.arrayIs( o.sortingWithArray ) );

        if( o.outputFormat === 'record' )
        o.result.sort( function( a, b )
        {
          return _.regexpArrayIndex( o.sortingWithArray, a.relative ) - _.regexpArrayIndex( o.sortingWithArray, b.relative );
        })
        else
        o.result.sort( function( a, b )
        {
          return _.regexpArrayIndex( o.sortingWithArray, a ) - _.regexpArrayIndex( o.sortingWithArray, b );
        });

      }

      /* mandatory */

      if( o.mandatory )
      if( !o.result.length )
      {
        debugger;
        throw _.err( 'No file found at ' + path.commonTextualReport( o.filter.filePath || o.filePath ) );
      }

      /* timing */

      if( o.verbosity >= 1 )
      self.logger.log( ' . Found ' + o.result.length + ' files at ' + o.filePath + ' in ', _.timeSpent( time ) );

      return o.result;
    });

    if( o.sync )
    return ready.sync();
    else
    return ready;
  }

}

_.routineExtend( filesFind_body, filesFindSingle.body );

var defaults = filesFind_body.defaults;

defaults.sync = 1;
defaults.orderingExclusion = null;
defaults.sortingWithArray = null;
defaults.verbosity = null;
defaults.mandatory = null;
defaults.safe = null;
defaults.maskPreset = 'default.exclude';
defaults.outputFormat = 'record';
defaults.result = null;
defaults.mode = 'legacy';
defaults.once = null;
defaults.onceHardLinked = 0;
defaults.visited = null;

_.assert( defaults.maskAll === undefined );
_.assert( defaults.glob === undefined );

let filesFind = _.routineFromPreAndBody( filesFind_pre, filesFind_body );

filesFind.having.aspect = 'entry';

//

/**
 * @description Short-cut for {@link module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind.filesFind}.
 * Performs recursive search for files from specified path `o.filePath`.
 * Includes terminals,directories and transient files into the result array.
 * @param {Object} o Options map.
 *
 * @param {} o.filePath
 * @param {} o.filter
 * @param {} o.includingTerminals=1
 * @param {} o.includingDirs=1
 * @param {} o.includingStem=1
 * @param {} o.includingActual=1
 * @param {} o.includingTransient=1
 * @param {} o.allowingMissed=1
 * @param {} o.allowingCycled=1
 * @param {} o.recursive=2
 * @param {} o.resolvingSoftLink=0
 * @param {} o.resolvingTextLink=0
 * @param {} o.maskPreset='default.exclude'
 * @param {} o.outputFormat='record'
 * @param {} o.safe=null
 * @param {} o.sync=1
 * @param {} o.orderingExclusion=[]
 * @param {} o.sortingWithArray
 * @param {} o.verbosity
 * @param {} o.mandatory
 * @param {} o.result=[]
 * @param {} o.onUp=[]
 * @param {} o.onDown=[]
 *
 * @function filesFindRecursive
 * @memberof module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind#
 */

let filesFindRecursive = _.routineFromPreAndBody( filesFind.pre, filesFind.body );

var defaults = filesFindRecursive.defaults;
defaults.filePath = null;
defaults.recursive = 2;
defaults.includingTransient = 0;
defaults.includingDirs = 1;
defaults.includingTerminals = 1;
defaults.allowingMissed = 1;
defaults.allowingCycled = 1;

//

/**
 * @description Short-cut for {@link module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind.filesFind}.
 * Performs recursive search for files using glob pattern `o.filePath` using glob pattern.
 * Includes terminals,directories into the result array.
 * @param {Object} o Options map.
 *
 * @param {} o.filePath
 * @param {} o.filter
 * @param {} o.includingTerminals=1
 * @param {} o.includingDirs=1
 * @param {} o.includingStem=1
 * @param {} o.includingActual=1
 * @param {} o.includingTransient=0
 * @param {} o.allowingMissed=0
 * @param {} o.allowingCycled=0
 * @param {} o.recursive=2
 * @param {} o.resolvingSoftLink=0
 * @param {} o.resolvingTextLink=0
 * @param {} o.maskPreset='default.exclude'
 * @param {} o.outputFormat='absolute'
 * @param {} o.safe=null
 * @param {} o.sync=1
 * @param {} o.orderingExclusion=[]
 * @param {} o.sortingWithArray
 * @param {} o.verbosity
 * @param {} o.mandatory
 * @param {} o.result=[]
 * @param {} o.onUp=[]
 * @param {} o.onDown=[]
 *
 * @function filesGlob
 * @memberof module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind#
 */

function filesGlob( o )
{
  let self = this;

  if( _.strIs( o ) )
  o = { filePath : o }

  if( o.recursive === undefined )
  o.recursive = 2;

  o.filter = o.filter || Object.create( null );

  if( !o.filePath && !o.filter.filePath )
  {
    o.filter.filePath = o.recursive === 2 ? '**' : '*';
  }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.objectIs( o ) );

  let result = self.filesFind( o );

  return result;
}

_.routineExtend( filesGlob, filesFind );

var defaults = filesGlob.defaults;

// defaults.outputFormat = 'absolute';
defaults.recursive = 2;
defaults.includingTerminals = 1;
defaults.includingDirs = 1;
defaults.includingTransient = 0;

//

/**
 * @description Functor for {@link module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind.filesFind} routine.
 * Creates a filesFind routine with options saved in inner context.
 * It allows to reuse created routine changing only necessary options and don't worry about other options.
 * @param {Object} o Options map. Please see {@link module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind.filesFind} for options description.
 * @function filesFinder
 * @memberof module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind#
 */

function filesFinder_functor( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.routineExtend( finder, routine );
  return finder;

  function finder()
  {
    let self = this;
    let path = self.path;
    let op0 = self._filesFindPrepare0( routine, arguments );
    _.assertMapHasOnly( op0, finder.defaults );
    return er;

    function er()
    {
      let o = _.mapExtend( null, op0 );
      o.filter = self.recordFilter( o.filter );
      if( o.filePath )
      {
        o.filter.filePath = path.mapExtend( o.filter.filePath, o.filePath );
        o.filePath = null;
      }

      for( let a = 0 ; a < arguments.length ; a++ )
      {
        let op2 = arguments[ a ];

        if( !_.objectIs( op2 ) )
        op2 = { filePath : op2 }

        op2.filter = self.recordFilter( op2.filter || Object.create( null ) );

        if( op2.filePath )
        {
          op2.filter.filePath = path.mapExtend( op2.filter.filePath, op2.filePath );
          op2.filePath = null;
        }

        o.filter.and( op2.filter );
        o.filter.pathsExtendJoining( op2.filter );
        // o.filter.pathsJoin( op2.filter );

        op2.filter = o.filter;
        op2.filePath = o.filePath;

        _.mapExtend( o, op2 );

      }

      // debugger;
      return routine.call( self, o );
    }

  }

}

let filesFinder = filesFinder_functor( filesFind );
let filesGlober = filesFinder_functor( filesGlob );

// --
// files find groups
// --

function filesFindGroups_pre( routine, args )
{
  let self = this;
  // let o = self._preFileFilterWithProviderDefaults.apply( self, arguments );

  let o = self._preFileFilterWithoutProviderDefaults.apply( self, arguments );

  // o.dst = self.recordFilter( o.dst );
  // o.src.pairWithDst( o.dst );
  // o.src.pairRefineLight();
  // o.dst.form();

  // o.src._formPaths();
  // if( o.dst )
  // o.dst._formPaths();
  // o.src.effectiveFileProvider._providerDefaultsApply( o );

  // if( o.dst )
  // {
  //   o.src.pairRefineLight();
  //   o.dst.form();
  // }

  // o.src.form();

  return o;
}

//

/*
qqq : filesFindGroups requires tests

don't forget option mandatory

*/

function filesFindGroups_body( o )
{
  let self = this;
  let path = self.path;
  let con = new _.Consequence();

  _.assert( o.src.formed === 3 );
  _.assert( o.dst.formed === 3 );

  let r = Object.create( null );
  r.options = o;
  r.pathsGrouped = path.mapGroupByDst( o.src.filePath );
  r.filesGrouped = Object.create( null );
  r.srcFiles = Object.create( null );
  r.errors = [];

  /* */

  for( let dstPath in r.pathsGrouped ) ( function( dstPath )
  {
    let srcPath = r.pathsGrouped[ dstPath ];
    let o2 = _.mapOnly( o, self.filesFind.body.defaults );

    con.finallyGive( 1 );

    o2.result = [];
    o2.filter = o.src.clone();
    o2.filter.filePathSelect( srcPath, dstPath );
    _.assert( o2.filter.formed === 3 );
    // o2.filter._formPaths();
    // o2.filter.form();

    _.Consequence.Try( () => self.filesFind( o2 ) )
    .finally( ( err, files ) =>
    {

      if( err )
      {
        r.errors.push( err );
      }
      else
      {
        r.filesGrouped[ dstPath ] = files;
        files.forEach( ( file ) =>
        {
          if( _.strIs( file ) )
          r.srcFiles[ file ] = file;
          else
          r.srcFiles[ file.absolute ] = file;
        });
      }

      con.take( null );
      return null;
    });

  })( dstPath );

  /* */

  con.take( null );
  con.finally( () =>
  {
    if( r.errors.length )
    {
      debugger;
      if( o.throwing )
      throw r.errors[ 0 ];
    }
    return r;
  });

  return con.syncMaybe();
}

var defaults = filesFindGroups_body.defaults = _.mapExtend( null, filesFind.defaults );

delete defaults.filePath;
delete defaults.filter;

defaults.src = null;
defaults.dst = null;
defaults.sync = 1;
defaults.throwing = null;
defaults.recursive = 2;
defaults.mode = 'distinct';

//

let filesFindGroups = _.routineFromPreAndBody( filesFindGroups_pre, filesFindGroups_body );

//

/*
qqq : new filesRead requires tests
*/

function filesRead_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( o.src.formed === 3 );

  let con = self.filesFindGroups( o );
  let r;

  /* */

  con = _.Consequence.From( con );

  con.then( ( result ) =>
  {
    r = result;
    r.dataMap = Object.create( null );
    r.grouped = Object.create( null );

    for( let dstPath in r.filesGrouped )
    {
      let files = r.filesGrouped[ dstPath ];
      for( let f = 0 ; f < files.length ; f++ )
      fileRead( files[ f ], dstPath );
    }

    return r;
  });

  return con.syncMaybe();

  /* */

  function fileRead( record, dstPath )
  {

    let descriptor = r.grouped[ dstPath ];

    if( !descriptor )
    {
      descriptor = r.grouped[ dstPath ] = Object.create( null );
      descriptor.dstPath = dstPath;
      descriptor.pathsGrouped = r.pathsGrouped[ dstPath ];
      descriptor.filesGrouped = r.filesGrouped[ dstPath ];
      descriptor.dataMap = Object.create( null );
    }

    try
    {
      r.dataMap[ record.absolute ] = self.fileRead({ filePath : record.absolute, sync : o.sync });
      con.finallyGive( 1 );
      _.Consequence.From( r.dataMap[ record.absolute ] )
      .finally( ( err, data ) =>
      {
        if( err )
        {
          r.errors.push( err );
          return null;
        }
        r.dataMap[ record.absolute ] = data;
        descriptor.dataMap[ record.absolute ] = data;
        return null;
      })
      .finally( con );
    }
    catch( err )
    {
      r.errors.push( err );
    }

  }

}

filesRead_body.defaults = Object.create( filesFindGroups.defaults );

let filesRead = _.routineFromPreAndBody( filesFindGroups.pre, filesRead_body );

// --
//
// --

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
// defaults.recursive = 2;
// defaults.allowDelete = 0;
// defaults.allowWrite = 0;
// defaults.allowRewrite = 1;
// defaults.allowRewriteFileByDir = 0;
//
// defaults.tryingPreserve = 1;
// defaults.silentPreserve = 1;
// defaults.preservingTime = 1;

//

// function filesCopyWithAdapter( o )
// {
//   let self = this;

//   if( arguments.length === 2 )
//   o = { dst : arguments[ 0 ] , src : arguments[ 1 ] }

//   _.assert( arguments.length === 1 || arguments.length === 2 );

//   if( !o.allowDelete && o.investigateDestination === undefined )
//   o.investigateDestination = 0;

//   if( o.allowRewrite === undefined )
//   o.allowRewrite = filesCopyWithAdapter.defaults.allowRewrite;

//   if( o.allowRewrite && o.allowWrite === undefined )
//   o.allowWrite = 1;

//   if( o.allowRewrite && o.allowRewriteFileByDir === undefined  )
//   o.allowRewriteFileByDir = true;

//   _.routineOptions( filesCopyWithAdapter, o );
//   self._providerDefaultsApply( o );

//   if( o.onUp === null )
//   o.onUp = [];
//   if( o.onDown === null )
//   o.onDown = [];

//   /* safe */

//   // if( self.safe )
//   // if( o.removingSource && ( !o.allowWrite || !o.allowRewrite ) )
//   // throw _.err( 'not safe removingSource:1 with allowWrite:0 or allowRewrite:0' );

//   o.src = self.path.normalize( o.src );
//   o.dst = self.path.normalize( o.dst );

//   let options = Object.create( null );
//   _.mapExtend( options, _.mapOnly( o, filesReflect.defaults ) );

//   /*
//     'investigateDestination',
//     'verbosity',
//     'silentPreserve?',
//     'resolvingSoftLink',
//     'resolvingTextLink',
//     'allowDelete',
//     'allowWrite',
//     'allowRewrite',
//     'allowRewriteFileByDir',
//     'removingSourceTerminals',
//     'removingSource',
//     'tryingPreserve',
//     'ext?',
//     'maxSize?',
//     'usingExtraStat?',
//   */

//   options.linking = options.linking ? 'hardLink' : 'fileCopy';
//   options.srcDeleting = o.removingSource || o.removingSourceTerminals; // check it
//   options.dstDeleting = o.allowDelete;
//   options.writing = o.allowWrite;
//   options.dstRewriting = o.allowRewrite;
//   options.dstRewritingByDistinct = o.allowRewriteFileByDir; // check it
//   options.preservingTime = o.preservingTime;
//   options.preservingSame = o.tryingPreserve; // check it
//   options.includingDst = o.investigateDestination;

//   /*
//   zzz : wrong! resolving*Link and resolvingSoftLink are not related, as well as resolvingTextLink
//   Vova : low priority
//   */

//   options.resolvingSrcSoftLink = o.resolvingSoftLink;
//   options.resolvingDstSoftLink = o.resolvingSoftLink;
//   options.resolvingSrcTextLink = o.resolvingTextLink;
//   options.resolvingDstTextLink = o.resolvingTextLink;

//   options.onWriteDstUp = o.onUp;
//   options.onWriteDstDown = o.onDown;

//   delete options.onUp;
//   delete options.onDown;

//   options.reflectMap = Object.create( null );
//   options.reflectMap[ o.src ] = o.dst;

//   // options.srcProvider = self;
//   // options.dstProvider = self;

//   if( !options.filter )
//   options.filter = Object.create( null );

//   if( options.filter instanceof _.FileRecordFilter )
//   {
//     options.src = options.filter.clone();
//     // options.dst = options.filter.clone();
//   }
//   else
//   {
//     options.src = self.recordFilter( options.filter );
//     // options.dst = self.recordFilter( options.filter );
//   }

//   options.filter = null;

//   options.src.effectiveFileProvider = self;
//   // options.dst.effectiveFileProvider = self;

//   if( o.ext )
//   {
//     _.assert( _.strIs( o.ext ) );
//     _.assert( !o.onDstName, 'o.ext is not compatible with o.onDstName' );
//     let ext = o.ext;
//     options.onDstName = function( relative, dstRecordFactory, op, o, srcRecord )
//     {
//       if( !srcRecord.isDir )
//       return self.path.changeExt( relative, ext );
//       return relative;
//     }
//   }

//   let result = self.filesReflect( options );

//   result.forEach( ( r ) =>
//   {

//     if( !r.relative )
//     r.relative = r.effective.relative;

//     if( r.action === 'dirMake' )
//     if( r.preserve )
//     r.action = 'directory preserved';
//     else
//     r.action = 'directory new';

//     if( r.action === 'fileCopy' )
//     if( r.preserve )
//     r.action = 'same';
//     else
//     r.action = 'copied'

//   })

//   return result;
// }

// filesCopyWithAdapter.defaults =
// {
//   outputFormat : 'record',
//   ext : null,
//   investigateDestination : 1,

//   maxSize : 1 << 21,
//   usingExtraStat : 1,
//   recursive : 0,

//   includingTerminals : 1,
//   includingDirs : 1,

//   resolvingSoftLink : 0,
//   resolvingTextLink : 0,

//   filter : null,
//   result : null,
//   src : null,
//   dst : null,

//   onUp : null,
//   onDown : null,
// }

// // filesCopyWithAdapter.defaults.__proto__ = filesFindMasksAdjust.defaults
// // var paths = filesCopyWithAdapter.paths = Object.create( null );
// // paths.src = null;
// // paths.dst = null;

// var having = filesCopyWithAdapter.having = Object.create( null );
// having.writing = 0;
// having.reading = 1;
// having.driving = 0;

// // _.routineExtend( filesCopyWithAdapter, filesFindDifference );

// var defaults = filesCopyWithAdapter.defaults;

// defaults.verbosity = 1;
// defaults.linking = 0;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;

// defaults.removingSource = 0;
// defaults.removingSourceTerminals = 0;

// defaults.recursive = 2;
// defaults.allowDelete = 0;
// defaults.allowWrite = 0;
// defaults.allowRewrite = 1;
// defaults.allowRewriteFileByDir = 0;

// defaults.tryingPreserve = 1;
// defaults.silentPreserve = 1;
// defaults.preservingTime = 1;

//

function _filesFiltersPrepare( routine, o )
{
  let self = this;

  _.assert( arguments.length === 2 );

  /* */

  o.src = self.recordFilter( o.src );
  o.dst = self.recordFilter( o.dst );

  o.src.pairWithDst( o.dst );
  o.src.pairRefineLight();

  // if( o.filter )
  // {
  //   o.src.and( o.filter ).pathsJoinWithoutNull( o.filter );
  //   o.dst.and( o.filter ).pathsJoinWithoutNull( o.filter );
  // }

  if( o.filter ) /* qqq : cover please */
  {
    o.src.and( o.filter ).pathsSupplement( o.filter );
    o.dst.and( o.filter ).pathsSupplement( o.filter );
  }

  if( o.src.recursive === null )
  o.src.recursive = o.recursive;
  if( o.dst.recursive === null )
  o.dst.recursive = 2;

  /* */

  _.assert( _.objectIs( o.src ) );
  _.assert( _.objectIs( o.dst ) );

  _.assert( o.src.formed <= 1 );
  _.assert( o.dst.formed <= 1 );

  _.assert( _.objectIs( o.src.defaultFileProvider ) );
  _.assert( _.objectIs( o.dst.defaultFileProvider ) );

  _.assert( !( o.src.effectiveFileProvider instanceof _.FileProvider.Hub ) );
  _.assert( !( o.dst.effectiveFileProvider instanceof _.FileProvider.Hub ) );

  _.assert( o.srcProvider === undefined );
  _.assert( o.dstProvider === undefined );

  _.assert( o.src.recursive === o.recursive );
  _.assert( o.dst.recursive === 2 );

}

//

function _filesReflectPrepare( routine, args )
{
  let self = this;
  let o = args[ 0 ];

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  if( args.length === 2 )
  o = { dst : args[ 0 ] , src : args[ 1 ] }

  _.routineOptions( routine, o );
  self._providerDefaultsApply( o );

  o.onUp = _.routinesComposeAll( o.onUp );
  // o.onDown = _.routinesCompose( o.onDown );
  o.onDown = _.routinesComposeReturningLast( o.onDown );

  if( o.result === null )
  o.result = [];

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = o.dstDeleting;

  self._filesFiltersPrepare( routine, o );

  _.assert( o.srcPath === undefined );
  _.assert( o.dstPath === undefined );
  _.assert( o.src.isPaired( o.dst ) );
  _.assert( !o.dstDeleting || o.includingDst );
  _.assert( o.onDstName === null || _.routineIs( o.onDstName ) );
  _.assert( _.boolLike( o.includingDst ) );
  _.assert( _.boolLike( o.dstDeleting ) );
  _.assert( _.arrayIs( o.result ) );
  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );
  _.assert( _.arrayHas( [ 'fileCopy', 'hardLink', 'hardLinkMaybe', 'softLink', 'softLinkMaybe', 'nop' ], o.linking ), 'unknown kind of linking', o.linking );

  return o;
}

//

function filesReflectEvaluate_pre( routine, args )
{
  let self = this;
  let o = self._filesReflectPrepare( routine, args );

  _.assert( o.filter === undefined );
  _.assert( o.rebasingLink === undefined );

  return o;
}

//

function filesReflectEvaluate_body( o )
{
  let self = this;
  let actionMap = Object.create( null );
  let touchMap = Object.create( null );
  let dstDeleteMap = Object.create( null );
  let recordAdd = recordAdd_functor( o );
  let recordRemove = recordRemove_functor( o );
  let dstPath = o.dst.filePathSimplest( o.dst.filePathNormalizedGet() );

  _.assertRoutineOptions( filesReflectEvaluate_body, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.strIs( dstPath ) );
  _.assert( o.outputFormat === undefined );

  let srcOptions = srcOptionsForm();
  let dstOptions = dstOptionsForm();
  let dstRecordFactory = dstFactoryForm();
  let dst = o.dst.effectiveFileProvider;
  let src = o.src.effectiveFileProvider;

  _.assert( o.dst.hubFileProvider.hasProvider( o.dst.effectiveFileProvider ), 'Hub should have destination and source file providers' );
  _.assert( o.src.hubFileProvider.hasProvider( o.src.effectiveFileProvider ), 'Hub should have destination and source file providers' );
  _.assert( o.dst.hubFileProvider === o.src.hubFileProvider, 'Hub should have the same destination and source hub' );
  _.assert( o.dst.effectiveFileProvider === dstRecordFactory.effectiveFileProvider );
  _.assert( o.dst.defaultFileProvider === dstRecordFactory.defaultFileProvider );
  _.assert( o.dst.hubFileProvider === dstRecordFactory.hubFileProvider || o.dst.hubFileProvider === null );
  _.assert( !!o.dst.effectiveFileProvider );
  _.assert( !!o.dst.defaultFileProvider );
  _.assert( !!o.src.effectiveFileProvider );
  _.assert( !!o.src.defaultFileProvider );
  _.assert( o.dst.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( o.src.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( dst.path.isAbsolute( dstPath ) );
  _.assert( o.src.isPaired( o.dst ) );
  _.assert( src.path.s.allAreNormalized( o.src.filePath ) );
  _.assert( dst.path.isNormalized( dstPath ) );
  _.assert( _.boolLike( o.mandatory ) );

  /* find */

  let found = self.filesFind( srcOptions );

  o.visited = srcOptions.visited;

  return o.result;

  /* src options */

  function srcOptionsForm()
  {

    if( !o.src.formed || o.src.formed < 5 )
    {
      o.src.hubFileProvider = o.src.hubFileProvider || self;
      o.src.recursive = o.recursive;
      o.src.form();
    }

    _.assert( o.srcPath === undefined );
    _.assert( o.dstPath === undefined );

    let srcOptions = _.mapOnly( o, self.filesFind.defaults );
    // srcOptions.mandatory = 0;
    srcOptions.mandatory = o.mandatory;
    srcOptions.includingStem = 1;
    srcOptions.includingTransient = 1;
    srcOptions.includingDefunct = 1; // yyy
    srcOptions.allowingMissed = 1;
    srcOptions.allowingCycled = 1;
    srcOptions.verbosity = 0;
    srcOptions.maskPreset = 0;
    srcOptions.filter = o.src;
    srcOptions.result = null;
    srcOptions.visited = o.visited;
    srcOptions.onUp = [ handleSrcUp ];
    srcOptions.onDown = [ handleSrcDown ];

    // _.mapSupplement( srcOptions, self.filesFindSingle.defaults ); // xxx

    return srcOptions;
  }

  /* dst options */

  function dstOptionsForm()
  {

    if( o.dst.formed < 5 )
    {
      o.dst.hubFileProvider = o.dst.hubFileProvider || self;
      o.dst.recursive = 2;
      o.dst.form();
    }

    _.assert( o.dst.basePath === null || _.objectIs( o.dst.basePath ) );
    _.assert( _.objectIs( o.dst.formedBasePath ) );
    _.assert( !!o.dst.effectiveFileProvider );
    _.assert( !!o.dst.defaultFileProvider );

    let dstOptions = _.mapExtend( null, srcOptions );
    dstOptions.filter = o.dst;
    dstOptions.filePath = o.dst.filePathSimplest( o.dst.filePathNormalizedGet() );
    dstOptions.includingStem = 1;
    dstOptions.recursive = 2;
    dstOptions.maskPreset = 0;
    dstOptions.verbosity = 0;
    dstOptions.result = null;
    dstOptions.onUp = [];
    dstOptions.onDown = [ handleDstDown ];

    _.assert( _.strIs( dstOptions.filePath ) );

    return dstOptions;
  }

  /* dst factory */

  function dstFactoryForm()
  {

    _.assert( _.strIs( dstPath ) );
    let dstOp =
    {
      basePath : o.dst.formedBasePath[ dstPath ] ? o.dst.formedBasePath[ dstPath ] : dstPath,
      stemPath : dstPath,
      filter : o.dst,
      allowingMissed : 1,
      allowingCycled : 1,
    }

    if( _.arrayIs( dstOp.stemPath ) && dstOp.stemPath.length === 1 )
    dstOp.stemPath = dstOp.stemPath[ 0 ];

    _.assert( !!dstOp.basePath, () => 'No base path for ' + _.strQuote( dstPath ) );
    let dstRecordFactory = _.FileRecordFactory.TollerantFrom( o, dstOp ).form();

    _.assert( _.strIs( dstOp.basePath ) );
    _.assert( dstRecordFactory.basePath === _.uri.parse( dstPath ).longPath || dstRecordFactory.basePath === _.uri.parse( o.dst.formedBasePath[ dstPath ] ).longPath );

    return dstRecordFactory;
  }

  /* add record to result array */

  function recordAdd_functor( o )
  {
    let routine;

    // if( o.outputFormat === 'src.absolute' )
    // routine = function add( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.assert( record.include === true );
    //   o.result.push( record.src.absolute );
    // }
    // else if( o.outputFormat === 'src.relative' )
    // routine = function add( record )
    // {
    //   debugger;
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.assert( record.include === true );
    //   o.result.push( record.src.relative );
    // }
    // else if( o.outputFormat === 'dst.absolute' )
    // routine = function add( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.assert( record.include === true );
    //   o.result.push( record.dst.absolute );
    // }
    // else if( o.outputFormat === 'dst.relative' )
    // routine = function add( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.assert( record.include === true );
    //   o.result.push( record.dst.relative );
    // }
    // else if( o.outputFormat === 'record' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record );
    }
    // else if( o.outputFormat === 'nothing' )
    // routine = function add( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.assert( record.include === true );
    // }
    // else _.assert( 0, 'Unknown output format :', o.outputFormat );

    return routine;
  }

  /* remove record from result array */

  function recordRemove_functor( o )
  {
    let routine;

    // if( o.outputFormat === 'src.absolute' )
    // routine = function remove( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.arrayRemoveElementOnceStrictly( o.result, record.src.absolute );
    // }
    // else if( o.outputFormat === 'src.relative' )
    // routine = function remove( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.arrayRemoveElementOnceStrictly( o.result, record.src.relative );
    // }
    // else if( o.outputFormat === 'dst.absolute' )
    // routine = function remove( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.arrayRemoveElementOnceStrictly( o.result, record.dst.absolute );
    // }
    // else if( o.outputFormat === 'dst.relative' )
    // routine = function remove( record )
    // {
    //   _.assert( arguments.length === 1, 'Expects single argument' );
    //   _.arrayRemoveElementOnceStrictly( o.result, record.dst.relative );
    // }
    // else if( o.outputFormat === 'record' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record );
    }
    // else if( o.outputFormat === 'nothing' )
    // routine = function remove( record )
    // {
    // }
    // else _.assert( 0, 'Unknown output format :', o.outputFormat );

    return routine;
  }

  /* */

  function recordMake( dstRecord, srcRecord, effectiveRecord )
  {
    _.assert( dstRecord === effectiveRecord || srcRecord === effectiveRecord );
    let record = Object.create( null );
    record.dst = dstRecord;
    record.src = srcRecord;
    record.effective = effectiveRecord;
    record.goingUp = true;
    record.upToDate = false;
    record.srcAction = null;
    record.srcAllow = true;
    record.reason = null;
    record.action = null;
    record.allow = true;
    record.preserve = false;
    record.deleteFirst = false;
    record.touch = false;
    record.include = true;

    dstRecord.associated = record;
    srcRecord.associated = record;

    return record;
  }

  /* */

  function handleUp( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    // if( touchMap[ record.dst.absolute ] )
    // debugger;
    if( touchMap[ record.dst.absolute ] )
    touch( record, touchMap[ record.dst.absolute ] );
    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    // if( actionMap[ record.dst.absolute ] )
    // debugger;
    // if( actionMap[ record.dst.absolute ] ) // yyy
    // action( record, actionMap[ record.dst.absolute ] ); // yyy
    // _.assert( actionMap[ record.dst.absolute ] === record.action || !record.action ); // yyy

    _.sure( !_.strBegins( record.dst.absolute, '/../' ), () => 'Destination path ' + _.strQuote( record.dst.absolute ) + ' leads out of file system.' );

    if( !record.src.isActual && !record.dst.isActual )
    {
      if( !record.src.isDir && !record.dst.isDir )
      return end( false );
    }

    if( !o.includingDst && record.reason === 'dstDeleting' )
    return end( record );

    if( !o.includingDirs && record.effective.isDir )
    return end( record );

    if( !o.includingTerminals && !record.effective.isDir )
    return end( record );

    _.assert( _.routineIs( o.onUp ) );
    _.assert( arguments.length === 2 );

    let result = true;
    let r = o.onUp.call( self, record, o );
    if( r === _.dont )
    return end( false );

    handleUp2.call( self, record, o );

    return end( record );

    function end( result )
    {
      if( result && record.include && ( o.includingNonAllowed || record.allow ) )
      {
        recordAdd( record );
      }
      else
      {
        record.include = false;
      }
      return result;
    }

  }

  /* */

  function handleUp2( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    let a = actionMap[ record.dst.absolute ];
    let t = touchMap[ record.dst.absolute ];

    if( !o.writing )
    record.allow = false;

    if( record.reason !== 'srcLooking' && a )
    {
      record.include = false;
      return record
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );

    if( !record.src.stat )
    {
      /* src does not exist or is not actual */

      if( 0 ) // xxx
      if( o.mandatory )
      if( record.src.isStem )
      throw _.err
      (
        `Stem file does not exist: ${_.strQuote( record.src.absolute )}` +
        `\nTo fix it you may set option mandatory to false or exclude the file from filePath of source filter`
      );

      if( record.reason === 'dstDeleting' && !record.dst.isActual )
      {
      }
      else if( record.reason === 'srcLooking' && record.dst.isActual && record.dst.isDir && !record.src.isActual && record.src.stat )
      {
        record.include = false;
      }
      else if( ( !record.dst.stat && !record.src.isDir ) || ( record.dst.isTerminal && !record.dst.isActual ) )
      {
        record.include = false;
      }

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        /* src is dir, dst does not exist */

      }
      else if( record.dst.isDir )
      {
        /* both src and dst are dir */

        if( record.reason === 'srcLooking' && record.dst.isActual && !record.src.isActual && !record.src.isTransient )
        {
          debugger;
          record.include = false;
          dstDelete( record, op );
        }

      }
      else
      {
        /* src is dir, dst is terminal */

        if( !record.dst.isActual )
        record.include = false;

        if( !record.src.isActual && record.dst.isActual )
        {
        }
        else if( !record.dst.isActual )
        {
          record.goingUp = false;
          ignore( record );
        }
        else if( !o.dstRewriting || !o.dstRewritingByDistinct )
        {
          record.goingUp = false;
          record.allow = false;
          dirMake( record );
          preserve( record );
          forbid( record );
        }
        else
        {
          record.deleteFirst = true;
          dirMake( record );
        }

      }

    }
    else
    {

      if( !record.dst.stat )
      {
        /* src is terminal, dst does not exist */

        /* checks if terminals with equal dst path are same before link */
        if( record.src.isTerminal )
        if( o.writing && o.dstRewriting && o.dstRewritingPreserving && a )
        checkSrcTerminalsSameDst( record, op );

        link( record );

      }
      else if( record.dst.isDir )
      {
        /* src is terminal, dst is dir */

        if( !record.src.isActual && record.reason !== 'dstDeleting' )
        {
          record.include = false;
        }
        else if( record.src.isActual )
        {
          record.deleteFirst = true;
        }

      }
      else
      {
        /* both src and dst are terminals */

        if( record.src.isActual )
        {

          if( shouldPreserve( record ) )
          record.preserve = true;

          if( !o.writing )
          record.allow = false;

          if( !o.dstRewriting )
          {
            forbid( record );
          }

          link( record );

        }
        else
        {

          if( record.reason !== 'srcLooking' && o.dstDeleting )
          fileDelete( record );
          else
          record.include = false;

        }

      }

    }

    return record;
  }

  /* */

  function handleDown( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    // _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch ); // yyy
    if( touchMap[ record.dst.absolute ] )
    touch( record, touchMap[ record.dst.absolute ] );
    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    let srcExists = !!record.src.stat;
    let dstExists = !!record.dst.stat;

    _.assert( !!record.dst && !!record.src );
    _.assert( arguments.length === 2 );

    if( !record.include )
    return end( false );

    if( !record.src.isActual && !record.src.isDir && record.reason === 'srcLooking' )
    return end( false );

    if( !o.includingDst && record.reason === 'dstDeleting' )
    return end( record );

    if( !o.includingDirs && record.effective.isDir )
    return end( record );

    if( !o.includingTerminals && !record.effective.isDir )
    return end( record );

    handleDown2.call( self, record, o );
    let r = o.onDown.call( self, record, o );
    // _.assert( r !== _.dont );
    _.assert( r === undefined, () => 'onDown should return nothing( undefined ), but returned ' + _.toStrShort( r ) );

    _.assert( record.action !== 'exclude' || record.touch === false, () => 'Attempt to exclude touched ' + record.dst.absolute );

    if( record.action === 'exclude' )
    return end( false );

    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    if( !srcExists && record.reason === 'srcLooking' )
    return end( false );

    if( !record.src.isActual && !record.dst.isActual && !record.touch )
    return end( false );

    if( !o.includingNonAllowed && !record.allow )
    return end( false );

    return end( record.touch );

    function end( result )
    {
      if( result === false )
      {
        if( record.include )
        recordRemove( record );
        record.include = false;
      }
      return result;
    }
  }

  /* */

  function handleDown2( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );
    _.assert( !!record.touch === !!touchMap[ record.dst.absolute ] );

    if( record.reason === 'srcLooking' )
    {
      // if( !record.src.stat )
      // debugger;
      // if( ( !record.src.isActual || !record.src.stat ) && !record.touch )
      if( !record.src.isActual || !record.src.stat )
      if( !record.touch || actionMap[ record.dst.absolute ] )
      {
        if( !record.touch )
        {
          action( record, 'exclude' );
        }
        else if( actionMap[ record.dst.absolute ] === 'dirMake' )
        {
          dirMake( record );
          preserve( record );
        }
        _.assert( !!record.action, () => 'Not clear what action to apply to ' + record.src.absolute );
        return;
      }
    }

    if( !record.src.stat )
    {
      /* src does not exist */

      if( record.reason === 'dstRewriting' )
      {
        /* if dst rewriting and src is included */
        if( !o.dstRewriting && record.src.isActual )
        {
          forbid( record );
        }
      }
      else if( record.reason === 'dstDeleting' )
      {
        /* if dst deleting or src is not included then treat as src does not exist */
        if( !o.dstDeleting )
        {
          forbid( record );
        }
      }
      else if( !record.src.isActual )
      {
        /* if dst deleting or src is not included then treat as src does not exist */
        if( !o.dstDeleting )
        {
          debugger;
          forbid( record );
        }
      }

      _.assert( !record.action );
      _.assert( !record.srcAction );
      _.assert( !!record.reason );

      if( record.reason === 'dstDeleting' && !record.dst.isActual && !record.touch )
      {
        ignore( record );
      }
      else if( record.reason !== 'dstDeleting' && ( !record.dst.isActual || !record.dst.stat ) && !record.touch )
      {
        debugger;
        forbid( record );
        action( record, 'exclude' );
      }
      else
      {
        dirDeleteOrPreserve( record, 'ignore' );
      }

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        /* src is dir, dst does not exist */

        if( !record.src.isActual )
        {
          if( record.touch === 'constructive' )
          dirMake( record );
          else
          action( record, 'exclude' );
        }
        else
        {
          dirMake( record );
        }

      }
      else if( record.dst.isDir )
      {
        /* both src and dst are dir */

        if( !record.src.isActual )
        {

          if( record.reason === 'srcLooking' && record.dst.isStem )
          {
            dirMake( record );
            preserve( record );
          }
          else
          {
            dirDeleteOrPreserve( record );
          }

        }
        else
        {
          dirMake( record );
        }

      }
      else
      {
        /* src is dir, dst is terminal */

        if( o.dstRewritingPreserving )
        if( o.writing && o.dstRewriting && o.dstRewritingByDistinct )
        {
          debugger;
          throw _.err( 'Can\'t rewrite terminal file ' + record.dst.absolute + ' by directory ' + record.src.absolute + ', dstRewritingPreserving is enabled' );
        }

        if( !record.src.isActual && record.dst.isActual )
        if( record.touch === 'constructive' )
        {
          record.deleteFirst = true;
          dirMake( record );
        }
        else
        {
          fileDelete( record );
        }

        _.assert( !record.src.isActual || !!record.touch );

      }

    }
    else
    {

      if( !record.dst.stat )
      {
        /* src is terminal file and dst does not exists */
        _.assert( record.action === o.linking || _.strHas( o.linking, 'Maybe' ) );
      }
      else if( record.dst.isDir )
      {
        /* src is terminal, dst is dir */

        if( !o.writing || !o.dstRewriting || !o.dstRewritingByDistinct )
        {
          forbid( record );
        }
        else if( o.dstRewritingPreserving )
        {
          if( record.dst.factory.effectiveFileProvider.filesHasTerminal( record.dst.absolute ) )
          {
            debugger;
            throw _.err( 'Can\'t rewrite directory ' + _.strQuote( record.dst.absolute ) + ' by terminal ' + _.strQuote( record.src.absolute ) + ', directory has terminal(s)' );
          }
        }

        if( record.touch === 'constructive' )
        {
          record.preserve = true;
          dirMake( record );
        }
        else
        {
          if( record.src.isActual )
          {
            record.deleteFirst = true;
            link( record );
          }
          else
          {
            _.assert( record.deleteFirst === false );
            if( !o.dstDeleting )
            {
              debugger;
              forbid( record );
            }
            if( !record.dst.isActual && record.touch !== 'destructive' )
            {
              debugger;
              forbid( record );
            }

            dirDeleteOrPreserve( record );
          }
        }

      }
      else
      {
        /* both src and dst are terminals */

        if( o.writing && o.dstRewriting && o.dstRewritingPreserving )
        if( !self.filesAreSame( record.src, record.dst, true ) )
        if( record.src.stat.size !== 0 || record.dst.stat.size !== 0 )
        {
          debugger;
          let same = self.filesAreSame( record.src, record.dst, true );
          throw _.err
          (
            'Can\'t rewrite' + ' ' + 'terminal file ' + _.strQuote( record.dst.absolute ) + '\n' +
            'by terminal file ' + _.strQuote( record.src.absolute ) + '\n' +
            'files have different content'
          );
        }
      }

    }

    _.assert( !!record.reason );
    _.assert( !record.srcAction );
    _.assert( _.strIs( record.action ), () => 'Action for record ' + _.strQuote( record.src.relative ) + ' was not defined' );

    srcDeleteMaybe( record );

    return record;
  }

  /* */

  function handleDstUp( srcContext, reason, dst, dstRecord, op )
  {

    // if( _.strEnds( dstRecord.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 5 );
    _.assert( _.strIs( reason ) );
    let srcRecord = srcContext.record( dstRecord.relative );
    let record = recordMake( dstRecord, srcRecord, dstRecord );
    record.reason = reason;

    if( handleUp( record, op ) === false )
    record.include = false;

    return dstRecord;
  }

  /* */

  function handleDstDown( dstRecord, op )
  {
    let record = dstRecord.associated;
    handleDown( record, op );
    // return record;
  }

  /* */

  function handleSrcUp( srcRecord, op )
  {
    let relative = srcRecord.relative;
    if( o.onDstName )
    relative = o.onDstName.call( self, relative, dstRecordFactory, op, o, srcRecord );

    let dstRecord = dstRecordFactory.record( relative );
    let record = recordMake( dstRecord, srcRecord, srcRecord );
    record.reason = 'srcLooking';

    let isSoftLink = record.dst.isSoftLink;

    if( o.filesGraph )
    {
      if( record.dst.absolute === dstPath )
      {
        debugger;
        // o.filesGraph.dstPath = o.dstPath;
        // o.filesGraph.srcPath = o.srcPath;
        o.filesGraph.dst.filePath = o.dst.filePath;
        o.filesGraph.src.filePath = o.src.filePath;
        o.filesGraph.actionBegin( o.dst.filePath + ' <- ' + o.src.filePath );
      }
      if( !record.src.isDir )
      {
        o.filesGraph.filesUpdate( record.dst );
        o.filesGraph.filesUpdate( record.src );
        if( o.filesGraph.fileIsUpToDate( record.dst ) )
        record.upToDate = true;
      }
    }

    /* */

    handleUp( record, op );

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( record.include && record.src.isActual && record.src.stat )
    if( record.dst.isDir && !record.src.isDir )
    {
      /* src is terminal, dst is dir */

      _.assert( _.strIs( record.dst.factory.basePath ) );
      let filter2 = self.recordFilter
      ({
        effectiveFileProvider : dstOptions.filter.effectiveFileProvider,
        hubFileProvider : dstOptions.filter.hubFileProvider,
      });
      filter2.filePath = null;
      filter2.basePath = record.dst.factory.basePath;

      let dstOptions2 = _.mapExtend( null, dstOptions );
      dstOptions2.filePath = record.dst.absolute;
      dstOptions2.filter = filter2;
      dstOptions2.filter.filePath = null;
      dstOptions2.includingStem = 0;
      dstOptions2.mandatory = 0;
      dstOptions2.includingDefunct = 0;
      dstOptions2.onUp = [ _.routineJoin( undefined, handleDstUp, [ srcRecord.factory, 'dstRewriting', filter2 ] ) ];

      let found = self.filesFind( dstOptions2 );

    }

    /* */

    if( record.include && record.goingUp )
    return srcRecord;
    else
    return _.dont;
    // return _.dont;
  }

  /* */

  function handleSrcDown( srcRecord, op )
  {
    let record = srcRecord.associated;

    if( o.filesGraph && !record.src.isDir && !record.upToDate )
    {
      record.dst.reset();
      o.filesGraph.dependencyAdd( record.dst, record.src );
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    dstDelete( record, op );
    handleDown( record, op );

    if( o.filesGraph )
    {
      if( record.dst.absolute === dstPath )
      o.filesGraph.actionEnd();
    }

    // return record;
  }

  function dstDelete( record, op )
  {

    _.assert( !!record ); // xxx
    if( !o.includingDst )
    return;
    if( !record.dst.isDir || !record.src.isDir )
    return;

    _.assert( _.strIs( record.dst.factory.basePath ) );
    _.assert( _.strIs( record.src.factory.basePath ) );

    let dstFiles = record.dst.factory.effectiveFileProvider.dirRead({ filePath : record.dst.absolute, outputFormat : 'absolute' });
    let dstRecords = record.dst.factory.records( dstFiles );
    let srcFiles = record.src.factory.effectiveFileProvider.dirRead({ filePath : record.src.absolute, outputFormat : 'absolute' });
    let srcRecords = record.src.factory.records( srcFiles );

    for( let f = dstRecords.length-1 ; f >= 0 ; f-- )
    {
      let dstRecord = dstRecords[ f ];
      let srcRecord = _.arrayLeft( srcRecords, dstRecord, ( r ) => r.relative ).element;
      if( !srcRecord )
      continue;
      if( !srcRecord.isActual )
      continue;
      dstRecords.splice( f, 1 );
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    for( let f = 0 ; f < dstRecords.length ; f++ )
    {
      let dstRecord = dstRecords[ f ];

      if( dstDeleteMap[ dstRecord.absolute ] )
      continue;

      dstDeleteTouch( dstRecord );

      let dstOptions2 = _.mapExtend( null, dstOptions );
      dstOptions2.filePath = dst.path.join( record.dst.factory.basePath, dstRecord.absolute );
      dstOptions2.filter = dstOptions2.filter.clone();
      dstOptions2.filter.filePath = null;
      dstOptions2.filter.filePath = null;
      dstOptions2.filter.basePath = record.dst.factory.basePath;
      dstOptions2.mandatory = 0;
      dstOptions2.includingDefunct = 0;
      dstOptions2.onUp = [ _.routineJoin( null, handleDstUp, [ record.src.factory, 'dstDeleting', null ] ) ];

      let found = self.filesFind( dstOptions2 );

    }

  }

  /* */

  function dstDeleteTouch( record )
  {

    _.assert( _.strIs( dstPath ) );
    _.assert( _.strIs( record.absolute ) );
    _.assert( arguments.length === 1 );

    let absolutePath = record.absolute;
    dstDeleteMap[ absolutePath ] = 1;

    do
    {
      absolutePath = dst.path.detrail( dst.path.dir( absolutePath ) );
      dstDeleteMap[ absolutePath ] = 1;
    }
    while( absolutePath !== dstPath && absolutePath !== '/' );

  }

  /* touch */

  function action( record, action )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );
    _.assert( _.arrayHas( [ 'exclude', 'ignore', 'fileDelete', 'dirMake', 'fileCopy', 'softLink', 'hardLink', 'nop' ], action ), () => 'Unknown action ' + _.strQuote( action ) );

    let absolutePath = record.dst.absolute;
    let result = actionMap[ absolutePath ] === action;

    _.assert( record.action === null );
    record.action = action;

    if( action === 'exclude' || action === 'ignore' )
    {
      _.assert( actionMap[ absolutePath ] === undefined );
      return result;
    }

    actionMap[ absolutePath ] = action;

    return result
  }

  /* touch */

  function touch( record, kind )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    kind = kind || 'constructive';

    _.assert( _.strIs( dstPath ) );
    _.assert( arguments.length === 2 );
    _.assert( _.arrayHas( [ 'src', 'constructive', 'destructive' ], kind ) );

    let absolutePath = record.dst.absolute;
    kind = touchAct( absolutePath, kind );

    record.touch = kind;

    while( absolutePath !== dstPath && absolutePath !== '/' )
    {
      absolutePath = dst.path.detrail( dst.path.dir( absolutePath ) );
      touchAct( absolutePath, kind );
    }

    if( kind === 'destructive' )
    {
      for( let m in touchMap )
      if( _.strBegins( m, absolutePath ) )
      touchMap[ m ] = 'destructive';
    }

  }

  /* touchAct */

  function touchAct( absolutePath, kind )
  {

    if( kind === 'src' && touchMap[ absolutePath ] )
    return touchMap[ absolutePath ];

    if( kind === 'destructive' && touchMap[ absolutePath ] === 'constructive' )
    return touchMap[ absolutePath ];

    touchMap[ absolutePath ] = kind;

    return kind;
  }

  /* */

  function dirHaveFiles( record )
  {
    if( !record.dst.isDir )
    return false;
    if( touchMap[ record.dst.absolute ] === 'constructive' )
    return true;
    let files = record.dst.factory.effectiveFileProvider.dirRead({ filePath : record.dst.absolute, outputFormat : 'absolute' });
    files = files.filter( ( file ) => actionMap[ file ] !== 'fileDelete' );
    return !!files.length;
  }

  /* */

  function shouldPreserve( record )
  {

    if( !o.preservingSame )
    return false;

    if( record.upToDate )
    return true;

    if( o.linking === 'fileCopy' )
    {
      if( self.filesAreSame( record.dst, record.src, true ) )
      return true;
    }

    return false;
  }

  /* */

  function dirDeleteOrPreserve( record, preserveAction )
  {
    _.assert( !record.action );
    if( !preserveAction )
    preserveAction = 'dirMake';

    if( dirHaveFiles( record ) )
    {
      /* preserve dir if it has filtered out files */
      if( preserveAction === 'dirMake' )
      {
        dirMake( record );
        _.assert( record.preserve === true );
      }
      else
      ignore( record );
    }
    else
    {
      if( !o.writing )
      record.allow = false;

      if( !o.dstDeletingCleanedDirs )
      if( record.dst.isDir && !record.dst.isActual )
      return ignore( record );

      fileDelete( record );
    }

    return record;
  }

  /* */

  function preserve( record )
  {
    _.assert( _.strIs( record.action ) );
    record.preserve = true;
    touch( record, 'constructive' );
    return record;
  }

  /* */

  function link( record )
  {
    _.assert( !record.action );
    _.assert( !record.upToDate );

    if( !record.src.isActual )
    {
      record.include = false;
      return;
    }

    let linking = o.linking;
    if( _.strHas( linking, 'Maybe' ) )
    {
      if( src === dst )
      linking = _.strRemoveEnd( linking, 'Maybe' );
      else
      linking = 'fileCopy';
    }

    action( record, linking );
    touch( record, 'constructive' );

    return record;
  }

  /* */

  function dirMake( record )
  {
    _.assert( !record.action );

    if( record.dst.isDir || actionMap[ record.dst.absolute ] === 'dirMake' )
    record.preserve = true;

    action( record, 'dirMake' );
    touch( record, 'constructive' );

    return record;
  }

  /* */

  function ignore( record )
  {
    _.assert( !record.action );
    touch( record, 'constructive' );
    action( record, 'ignore' );
    record.preserve = true;
    record.allow = false;
    return record;
  }

  /* */

  function forbid( record )
  {
    delete actionMap[ record.dst.absolute ];
    /* no need to delete it from touchMap */
    record.allow = false;
    return record;
  }

  /* */

  function fileDelete( record )
  {
    _.assert( !record.action );

    action( record, 'fileDelete' );
    touch( record, 'destructive' );

    if( record.reason === 'dstDeleting' && !o.dstDeleting )
    {
      forbid( record );
    }

  }

  /* */

  function srcDeleteMaybe( record )
  {

    if( !o.srcDeleting )
    return false;
    if( !record.src.isActual )
    return false;
    if( !record.allow )
    return false;
    if( !record.include )
    return false;

    srcDelete( record );
  }

  /* delete src */

  function srcDelete( record )
  {

    /* record.dst.isActual could be false */

    _.assert( !!record.src.isActual );
    _.assert( !!record.include );
    _.assert( !!record.allow );
    _.assert( !!record.action );
    _.assert( !!o.srcDeleting );

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( record.allow )
    if( !record.src.stat )
    {
    }
    else if( record.src.isDir )
    {
      _.assert( record.action === 'dirMake' || record.action === 'fileDelete' );
      record.srcAction = 'fileDelete';
      record.srcAllow = !!o.writing;
      touch( record, 'src' )
    }
    else
    {
      record.srcAction = 'fileDelete';
      record.srcAllow = !!o.writing;
      touch( record, 'src' )
    }

  }

  //

  function checkSrcTerminalsSameDst( record, op )
  {
    for( let i = op.result.length - 1; i >= 0; i-- )
    {
      let result = op.result[ i ];
      if( result.dst.absolute === record.dst.absolute )
      {
        if( result.src.isTerminal )
        {
          if( !self.filesAreSame( result.src, record.src, true ) )
          if( result.src.stat.size !== 0 || record.src.stat.size !== 0 )
          {
            debugger
            throw _.err
            (
              'Source terminal files: \n' + _.strQuote( result.src.absolute ) + ' and ' + _.strQuote( record.src.absolute ) + '\n' +
              'have same destination path: ' + _.strQuote( record.dst.absolute ) +', but different content.' + '\n' +
              'Can\'t perform rewrite operation when option dstRewritingPreserving is enabled.'
            );
          }
        }
        break;
      }
    }
  }
}

let filesReflectPrimeDefaults = Object.create( null );
var defaults = filesReflectPrimeDefaults;

defaults.result = null;
defaults.visited = null;
defaults.extra = null;
defaults.linking = 'fileCopy';

defaults.verbosity = 0;
defaults.mandatory = 1;
defaults.allowingMissed = 0;
defaults.allowingCycled = 0;
defaults.includingTerminals = 1;
defaults.includingDirs = 1;
defaults.includingNonAllowed = 1;
defaults.includingDst = null;
defaults.recursive = 2;

defaults.writing = 1;
defaults.srcDeleting = 0;
defaults.dstDeleting = 0;
defaults.dstDeletingCleanedDirs = 1;
defaults.dstRewriting = 1;
defaults.dstRewritingByDistinct = 1;
defaults.dstRewritingPreserving = 0;
defaults.preservingTime = 0;
defaults.preservingSame = 0;

defaults.onUp = null;
defaults.onDown = null;
defaults.onDstName = null;

var defaults = filesReflectEvaluate_body.defaults = Object.create( filesReflectPrimeDefaults );

defaults.filesGraph = null;
defaults.src = null;
defaults.dst = null;

var having = filesReflectEvaluate_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesReflectEvaluate = _.routineFromPreAndBody( filesReflectEvaluate_pre, filesReflectEvaluate_body );
filesReflectEvaluate.having.aspect = 'entry';

//

function filesReflectSingle_pre( routine, args )
{
  let self = this;
  let o = self._filesReflectPrepare( routine, args );

  if( o.rebasingLink === false )
  o.rebasingLink = 0
  else if( o.rebasingLink === true )
  o.rebasingLink = 2;
  _.assert( _.arrayHas( [ 0, 1, 2 ], o.rebasingLink ) );

  o.onWriteDstUp = _.routinesCompose( o.onWriteDstUp );
  o.onWriteDstDown = _.routinesCompose( o.onWriteDstDown );
  o.onWriteSrcUp = _.routinesCompose( o.onWriteSrcUp );
  o.onWriteSrcDown = _.routinesCompose( o.onWriteSrcDown );

  return o;
}

//

function filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;
  let srcToDstHash = null;

  _.assertRoutineOptions( filesReflectSingle_body, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.boolLike( o.mandatory ) );
  _.assert( o.filter === undefined );
  _.assert( o.src.dst === o.dst );
  _.assert( o.dst.src === o.src );
  _.assert( o.outputFormat === undefined );

  if( o.rebasingLink && o.visited === null )
  {
    o.visited = Object.create( null );
  }

  let o2 = _.mapOnly( o, self.filesReflectEvaluate.body.defaults );
  o2.result = [];
  _.assert( _.arrayIs( o2.result ) );
  self.filesReflectEvaluate.body.call( self, o2 );
  _.assert( o2.result !== o.result );
  _.arrayAppendArray( o.result, o2.result );

  let dirsMap = Object.create( null );
  let hub = self.hub || self;
  let src = o.src.effectiveFileProvider;
  let dst = o.dst.effectiveFileProvider;

  /* */

  if( o.writing )
  forEach( writeDstUp1, writeDstDown1 );

  if( o.writing )
  forEach( writeDstUp2, writeDstDown2 );

  /* */

  if( o.writing && o.srcDeleting )
  forEach( writeSrcUp, writeSrcDown );

  /* */

  return end();

  /* - */

  function end()
  {

    if( o.mandatory )
    if( !o2.result.length )
    {
      _.assert( o.src.isPaired() );
      let mtr = o.src.moveTextualReport();
      debugger;
      throw _.err( 'Error. No file moved :', mtr );
    }

    return o.result;
  }

  /* */

  function srcToDst( srcRecord )
  {
    if( !srcToDstHash )
    {
      srcToDstHash = new Map();
      for( let r = 0 ; r < o.result.length ; r++ )
      srcToDstHash.set( o.result[ r ].src, o.result[ r ].dst );
    }
    return srcToDstHash.get( srcRecord );
  }

  /* */

  function forEach( up, down )
  {
    let filesStack = [];

    for( let r = 0 ; r < o.result.length ; r++ )
    {
      let record = o.result[ r ];

      while( filesStack.length && !_.strBegins( record.dst.absolute, filesStack[ filesStack.length-1 ].dst.absolute ) )
      down( filesStack.pop() );
      filesStack.push( record );

      up( record );
    }

    while( filesStack.length )
    down( filesStack.pop() );

  }

  /*  */

  function writeDstUp1( record )
  {

    let onr = o.onWriteDstUp.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );

    /* */

    if( !onr )
    return onr;

    return onr;
  }

  /* */

  function writeDstDown1( record )
  {

    if( record.deleteFirst )
    dstDelete( record );
    else if( record.action === 'fileDelete' )
    dstDelete( record );

  }

  /*  */

  function writeDstUp2( record )
  {

    let linking = _.arrayHas( [ 'fileCopy', 'hardLink', 'softLink', 'textLink', 'nop' ], record.action );
    if( linking && record.allow && !path.isRoot( record.dst.absolute ) )
    {

      let dirPath = record.dst.dir;
      if( !dirsMap[ dirPath ] )
      {
        for( let d in dirsMap )
        if( _.strBegins( dirPath, d ) )
        {
          dirsMap[ dirPath ] = true;
          break;
        }
        if( !dirsMap[ dirPath ] )
        {
          record.dst.factory.effectiveFileProvider.dirMake
          ({
            recursive : 1,
            rewritingTerminal : 0,
            filePath : dirPath,
          });
          dirsMap[ dirPath ] = true;
        }
      }

    }

    if( linking )
    link( record );
    else if( record.action === 'fileDelete' )
    {}
    else if( record.action === 'dirMake' )
    dstDirectoryMake( record );
    else if( record.action === 'ignore' )
    {}
    else _.assert( 0, 'Not implemented action ' + record.action );

  }

  /* */

  function writeDstDown2( record )
  {

    let onr = o.onWriteDstDown.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );
    return onr;
  }

  /* */

  function writeSrcUp( record )
  {

    let onr = o.onWriteDstUp.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );

    /* */

    if( !onr )
    return onr;

    return onr;
  }

  /* */

  function writeSrcDown( record )
  {

    srcDeleteMaybe( record );

    let onr = o.onWriteSrcDown.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );
    return onr;
  }

  /* */

  function dstDirectoryMake( record )
  {

    if( !record.allow )
    return;
    if( record.preserve )
    return;

    _.assert( !record.upToDate );
    _.assert( !!record.src.isActual || !!record.touch );
    _.assert( !!record.touch );
    _.assert( !!record.action );

    record.dst.factory.effectiveFileProvider.dirMake
    ({
      recursive : 1,
      rewritingTerminal : 0,
      filePath : record.dst.absolute,
    });

  }

  /* */

  function dstDelete( record )
  {
    if( !record.allow )
    return;
    if( record.dst.absolute === record.src.absolute )
    return;
    record.dst.factory.effectiveFileProvider.fileDelete( record.dst.absolute );
  }

  /* */

  function linkRebasing( record )
  {

    if( !o.rebasingLink )
    return false;

    let isSoftLink = record.src.isSoftLink;
    let isTextLink = record.src.isTextLink;
    if( !isSoftLink && !isTextLink )
    return false;

    let srcPath;
    let srcAbsolute = record.src.real;
    /* xxx qqq : use resolvingMultiple / recursive option instead of if-else */

    if( o.rebasingLink === 1 )
    {
      srcPath = src.pathResolveLinkStep
      ({
        filePath : srcAbsolute,
        resolvingSoftLink : 1,
        resolvingTextLink : 1,
        throwing : o.throwing,
        allowingMissed : o.allowingMissed,
        allowingCycled : o.allowingCycled,
      });
      srcAbsolute = path.join( srcAbsolute, srcPath );
    }
    else if( o.rebasingLink === 2 )
    {
      let srcAbsolute2 = src.pathResolveLinkFull
      ({
        filePath : srcAbsolute,
        resolvingSoftLink : 1,
        resolvingTextLink : 1,
        throwing : o.throwing,
        allowingMissed : o.allowingMissed,
        allowingCycled : o.allowingCycled,
      });
      // if(  )
      srcPath = srcAbsolute;
    }
    else _.assert( 0 );

    if( !o.visited[ srcAbsolute ] )
    debugger;
    if( !o.visited[ srcAbsolute ] )
    return false

    let srcRecord = o.visited[ srcAbsolute ];
    let dstRecord = srcToDst( srcRecord );
    if( record.src === dstRecord )
    debugger;
    if( record.src === dstRecord )
    return false;
    record.src = dstRecord;

    if( path.isAbsolute( srcPath ) )
    debugger;
    if( path.isAbsolute( srcPath ) )
    srcPath = record.src.absolutePreferred;

    let action = isSoftLink ? 'softLink' : 'textLink';

    if( action === 'softLink' )
    {
      /* zzz : should not change time of file if it is already linked */
      hub.softLink
      ({
        dstPath : record.dst.absolutePreferred,
        srcPath : srcPath,
        makingDirectory : 0,
        allowingMissed : 1,
        allowingCycled : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( action === 'textLink' )
    {
      /* zzz : should not change time of file if it is already linked */
      hub.textLink
      ({
        dstPath : record.dst.absolutePreferred,
        srcPath : srcPath,
        makingDirectory : 0,
        allowingMissed : 1,
        allowingCycled : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }

    return true;
  }

  /* */

  function link( record )
  {

    _.assert( !record.upToDate );
    _.assert( !!record.src.isActual );
    _.assert( !!record.touch );
    _.assert( !!record.action );

    if( !record.allow || record.preserve )
    return;

    if( record.action === 'nop' )
    return false;

    let action = record.action;

    if( linkRebasing( record ) )
    return true;

    if( action === 'hardLink' )
    {
      /* zzz : should not change time of file if it is already linked */

      dst.hardLink
      ({
        dstPath : record.dst.absolute,
        srcPath : record.src.absolute,
        makingDirectory : 0,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });

    }
    else if( action === 'softLink' )
    {
      /* zzz : should not change time of file if it is already linked */

      hub.softLink
      ({
        dstPath : record.dst.absolutePreferred,
        srcPath : record.src.absolutePreferred,
        makingDirectory : 0,
        allowingMissed : 1,
        allowingCycled : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( action === 'textLink' )
    {
      /* zzz : should not change time of file if it is already linked */
      hub.textLink
      ({
        dstPath : record.dst.absolutePreferred,
        srcPath : record.src.absolutePreferred,
        makingDirectory : 0,
        allowingMissed : 1,
        allowingCycled : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( action === 'fileCopy' )
    {
      hub.fileCopy
      ({
        dstPath : record.dst.absolutePreferred,
        srcPath : record.src.absolutePreferred,
        makingDirectory : 0,
        allowingMissed : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else _.assert( 0 );

    return true;
  }

  /* */

  function srcDeleteMaybe( record )
  {
    if( !record.srcAllow || !record.srcAction )
    return false;
    srcDelete( record );
  }

  /* delete src */

  function srcDelete( record )
  {

    /* record.dst.isActual could be false */

    _.assert( !!record.src.isActual );
    _.assert( !!record.include );
    _.assert( !!record.allow );
    _.assert( !!record.action );
    _.assert( !!o.srcDeleting );
    _.assert( record.srcAction === 'fileDelete' );

    if( record.allow )
    if( !record.src.stat || !record.src.isActual )
    {
      _.assert( 0, 'not tested' );
    }
    else if( record.src.isDir )
    {
      _.assert( record.action === 'dirMake' || record.action === 'fileDelete' );
      if( !record.src.factory.effectiveFileProvider.dirRead( record.src.absolute ).length )
      {
        record.src.factory.effectiveFileProvider.fileDelete( record.src.absolute );
      }
      else
      {
        record.srcAllow = false;
      }
    }
    else
    {
      _.assert( record.action === 'fileCopy' || record.action === 'hardLink' || record.action === 'softLink' || record.action === 'nop' );
      record.src.factory.effectiveFileProvider.fileDelete( record.src.absolute );
    }

  }

}

let filesReflectAdvancedDefaults = Object.create( null );
var defaults = filesReflectAdvancedDefaults;

defaults.onWriteDstUp = null;
defaults.onWriteDstDown = null;
defaults.onWriteSrcUp = null;
defaults.onWriteSrcDown = null;

defaults.breakingSrcHardLink = null;
defaults.resolvingSrcSoftLink = null;
defaults.resolvingSrcTextLink = null;
defaults.breakingDstHardLink = null;
defaults.resolvingDstSoftLink = null;
defaults.resolvingDstTextLink = null;
defaults.rebasingLink = 0;

var defaults = filesReflectSingle_body.defaults = Object.create( filesReflectEvaluate.defaults );
_.mapExtend( defaults, filesReflectAdvancedDefaults );

var having = filesReflectSingle_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesReflectSingle = _.routineFromPreAndBody( filesReflectSingle_pre, filesReflectSingle_body );
filesReflectSingle.having.aspect = 'entry';

//

function filesReflect_pre( routine, args )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { reflectMap : { [ args[ 1 ] ] : args[ 0 ] } }

  // self._filesReflectPrepare( routine, [ o ] );
  self.filesReflectSingle.pre.call( self, routine, args );

  if( Config.debug )
  {

    let srcFilePath = o.src.filePathSimplest();
    let dstFilePath = o.dst.filePathSimplest();
    _.assert( o.reflectMap === null || srcFilePath === null || srcFilePath === '' );
    _.assert( o.reflectMap === null || dstFilePath === null || dstFilePath === '' );
    _.assert( o.filter === null || o.src.filePath === '.' || o.filter.filePath === null || o.filter.filePath === undefined );
    _.assert( o.src.isPaired( o.dst ) );

    let knownFormats = [ 'src.absolute', 'src.relative', 'dst.absolute', 'dst.relative', 'record', 'nothing' ];
    _.assert
    (
      _.arrayHas( knownFormats, o.outputFormat ),
        'Unknown output format ' + _.toStrShort( o.outputFormat )
      + '\nKnown output formats ' + _.toStr( knownFormats )
    );

  }

  if( o.reflectMap )
  {
    if( Config.debug )
    if( !path.isEmpty( o.src.filePath ) )
    {
      let filePath1 = path.mapExtend( null, o.src.filePath );
      let filePath2 = path.mapExtend( null, o.reflectMap );
      _.assert( _.entityIdentical( filePath1, filePath2 ) );
    }
    o.src.filePath = o.reflectMap;
    o.reflectMap = null;
  }

  o.src.pairWithDst( o.dst );
  o.src.pairRefineLight();
  o.dst._formPaths();
  o.src._formPaths();

  _.assert( _.mapIs( o.src.filePath ), 'Cant deduce source filter' );
  _.assert( _.mapIs( o.dst.filePath ), 'Cant deduce destination filter' );
  _.assert( o.src.filePath === o.dst.filePath );
  _.assert( o.filter === null || o.filter.filePath === null || o.filter.filePath === undefined );
  _.assert( o.reflectMap === null );
  _.assert( o.dstPath === undefined );
  _.assert( o.srcPath === undefined );
  _.assert( o.src.formed <= 3 );
  _.assert( o.dst.formed <= 3 );

  return o;
}

//

/**
 * @summary Reflects files from source to the destination using `o.reflectMap`.
 * @description Reflect map contains key:value pairs. In signle pair key is a source path and value is a destination path.
 * @param {Object} o Options map.
 * @param {Object} o.reflectMap Map with keys as source path and values as destination path.
 * @param {Object} o.filesGraph
 * @param {Object} o.filter
 * @param {Object} o.rc
 * @param {Object} o.dst
 * @param {Array} o.result
 * @param {String} o.outputFormat='record'
 * @param {Number} o.verbosity=0
 * @param {Boolean} o.allowingMissed=0
 * @param {Boolean} o.allowingCycled=0
 * @param {Boolean} o.includingTerminals=1
 * @param {Boolean} o.includingDirs=1
 * @param {Boolean} o.includingNonAllowed=1
 * @param {Boolean} o.includingDst
 * @param {Number} o.recursive=2
 * @param {String} o.linking='fileCopy'
 * @param {Boolean} o.writing=1
 * @param {Boolean} o.srcDeleting=0
 * @param {Boolean} o.dstDeleting=0
 * @param {Boolean} o.dstDeletingCleanedDirs=1
 * @param {Boolean} o.dstRewriting=1
 * @param {Boolean} o.dstRewritingByDistinct=1
 * @param {Boolean} o.dstRewritingPreserving=0
 * @param {Boolean} o.preservingTime=0
 * @param {Boolean} o.preservingSame=0
 * @param {} o.extral
 * @param {Function} o.onUp
 * @param {Function} o.onDown
 * @param {Function} o.onDstName
 *
 * @function filesReflect
 * @memberof module:Tools/mid/Files.wTools.FileProvider.wFileProviderFind#
 */

function filesReflect_body( o )
{
  let self = this;
  let path = self.path;
  let cons = [];
  let time;

  if( o.verbosity >= 1 )
  time = _.timeNow();

  _.assertRoutineOptions( filesReflect_body, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( o.src.formed === 3 );
  _.assert( o.dst.formed === 3 );
  _.assert( o.dst.src === o.src );
  _.assert( o.src.dst === o.dst );
  _.assert( _.mapIs( o.src.filePath ) );
  _.assert( o.src.isPaired( o.dst ) );

  /* */

  let filePath = o.src.filePathMap( o.src.filePath, 1 );
  let groupedByDstMap = path.mapGroupByDst( filePath );
  for( let dstPath in groupedByDstMap )
  {

    let srcPath = groupedByDstMap[ dstPath ];
    let o2 = _.mapOnly( o, self.filesReflectSingle.body.defaults );

    o2.result = [];

    o2.dst = o2.dst.clone();
    o2.src = o2.src.clone();
    o2.src.pairWithDst( o2.dst );
    o2.src.filePathSelect( srcPath, dstPath );

    let src = o2.src.effectiveFileProvider;
    _.assert( _.routineIs( src.filesReflectSingle ), () => 'Method filesReflectSingle is not implemented' );
    let r = src.filesReflectSingle.body.call( src, o2 );
    cons.push( r );

    if( _.consequenceIs( r ) )
    r.ifNoErrorThen( ( arg ) => _.arrayAppendArray( o.result, o2.result ) );
    else
    _.arrayAppendArray( o.result, o2.result );

  }

  /* */

  if( _.any( cons, ( con ) => _.consequenceIs( con ) ) )
  {
    let con = new _.Consequence().take( null ).andKeep( cons );
    con.ifNoErrorThen( end );
    return con;
  }

  return end();

  /* */

  function end()
  {

    if( o.mandatory )
    if( !o.result.length )
    {
      _.assert( o.src.isPaired() );
      let mtr = o.src.moveTextualReport();
      debugger;
      throw _.err( 'Error. No file moved :', mtr );
    }

    if( o.verbosity >= 1 )
    {
      _.assert( o.src.isPaired() );
      let mtr = o.src.moveTextualReport();
      self.logger.log( ' + Reflect ' + o.result.length + ' files ' + mtr + ' in ' + _.timeSpent( time ) );
    }

    if( o.outputFormat !== 'record' )
    {
      if( o.outputFormat === 'src.relative' )
      {
        for( let r = 0 ; r < o.result.length ; r++ )
        o.result[ r ] = o.result[ r ].src.relative;
      }
      else if( o.outputFormat === 'src.absolute' )
      {
        for( let r = 0 ; r < o.result.length ; r++ )
        o.result[ r ] = o.result[ r ].src.absolute;
      }
      else if( o.outputFormat === 'dst.relative' )
      {
        for( let r = 0 ; r < o.result.length ; r++ )
        o.result[ r ] = o.result[ r ].dst.relative;
      }
      else if( o.outputFormat === 'dst.absolute' )
      {
        for( let r = 0 ; r < o.result.length ; r++ )
        o.result[ r ] = o.result[ r ].dst.absolute;
      }
      else if( o.outputFormat === 'nothing' )
      {
        o.result.splice( 0, o.result.length );
      }
      else _.assert( 0, 'Unknown output format :', o.outputFormat );
    }

    return o.result;
  }

}

var defaults = filesReflect_body.defaults = Object.create( filesReflectEvaluate.defaults );

_.mapExtend( defaults, filesReflectAdvancedDefaults );

defaults.filter = null;
defaults.reflectMap = null;
defaults.outputFormat = 'record';

// defaults.onWriteDstUp = null;
// defaults.onWriteDstDown = null;
// defaults.onWriteSrcUp = null;
// defaults.onWriteSrcDown = null;
//
// defaults.breakingSrcHardLink = null;
// defaults.resolvingSrcSoftLink = null;
// defaults.resolvingSrcTextLink = null;
// defaults.breakingDstHardLink = null;
// defaults.resolvingDstSoftLink = null;
// defaults.resolvingDstTextLink = null;

let filesReflect = _.routineFromPreAndBody( filesReflect_pre, filesReflect_body );

_.assert( _.boolLike( filesReflect_body.defaults.mandatory ) );

//

function filesReflector_functor( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.routineExtend( reflector, routine );
  return reflector;

  function reflector()
  {
    let self = this;
    let op0 = self._filesFindPrepare0( routine, arguments );
    _.assertMapHasOnly( op0, reflector.defaults );
    return er;

    function er()
    {
      let o = _.mapExtend( null, op0 );
      o.filter = self.recordFilter( o.filter );
      o.src = self.recordFilter( o.src );
      o.dst = self.recordFilter( o.dst );

      for( let a = 0 ; a < arguments.length ; a++ )
      {
        let op2 = arguments[ a ];

        if( _.strIs( op2 ) )
        op2 = { src : { filePath : { [ op2 ] : null } } }

        op2.filter = op2.filter || Object.create( null );
        op2.src = op2.src || Object.create( null );
        if( op2.src.filePath === undefined )
        op2.src.filePath = '';
        // op2.src.filePath = '.'; // yyy

        op2.dst = op2.dst || Object.create( null );

        o.filter.and( op2.filter ).pathsExtendJoining( op2.filter );
        o.src.and( op2.src ).pathsExtendJoining( op2.src );
        o.dst.and( op2.dst ).pathsExtendJoining( op2.dst );

        // o.filter.and( op2.filter );
        // o.filter.pathsJoin( op2.filter );
        // o.src.and( op2.src );
        // o.src.pathsJoin( op2.src );
        // o.dst.and( op2.dst );
        // o.dst.pathsJoin( op2.dst );

        op2.filter = o.filter;
        op2.src = o.src;
        op2.dst = o.dst;

        _.mapExtend( o, op2 );
      }

      return routine.call( self, o );
    }

  }

}

let filesReflector = filesReflector_functor( filesReflect );

//

function filesReflectTo_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = args[ 0 ];

  if( args[ 1 ] !== undefined || !_.mapIs( args[ 0 ] ) )
  o = { dstProvider : args[ 0 ], dst : args[ 1 ] }

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( 1 === args.length || 2 === args.length );
  _.routineOptions( routine, o );
  _.assert( o.dstProvider instanceof _.FileProvider.Abstract, () => 'Expects file provider {- o.dstProvider -}, but got ' + _.strType( o.dstProvider ) );
  // _.assert( path.s.isAbsolute( o.dst ), 'Expects simple path string {- o.dst -}' );
  // _.assert( path.s.isAbsolute( o.src ), 'Expects simple path string {- o.src -}' );

  return o;
}

//

function filesReflectTo_body( o )
{
  let self = this;
  let src = self;
  let dst = o.dstProvider;
  let hub;
  let result;

  _.assertRoutineOptions( filesReflectTo_body, arguments );
  _.assert( !src.hub || !dst.hub || src.hub === dst.hub, 'not implemented' );

  if( src.hub )
  {
    hub = src.hub;
  }
  else if( dst.hub )
  {
    hub = dst.hub;
  }
  else
  {
    hub = new _.FileProvider.Hub({ empty : 1 });
  }

  let srcProtocol = src.protocol;
  let dstProtocol = dst.protocol;
  let srcRegistered = hub.providersWithProtocolMap[ src.protocol ] === src;
  let dstRegistered = hub.providersWithProtocolMap[ dst.protocol ] === dst;

  // debugger;
  // if( !src.protocol )
  // src.protocol = hub.protocolNameGenerate( 0 );
  // if( !dst.protocol )
  // dst.protocol = hub.protocolNameGenerate( 1 );

  if( !src.protocol )
  src.protocol = src.constructor.shortName + src.id;
  if( !dst.protocol )
  dst.protocol = dst.constructor.shortName + dst.id;

  try
  {

    if( !srcRegistered )
    src.providerRegisterTo( hub );
    if( !dstRegistered )
    dst.providerRegisterTo( hub );

    _.assert( src.hub === dst.hub );

    // let filePath = { [ src.path.globalFromPreferred( o.srcPath ) ] : dst.path.globalFromPreferred( o.dstPath ) }
    // let filePath = { [ src.path.globalFromPreferred( o.src ) ] : dst.path.globalFromPreferred( o.dst ) }

    o.src = src.recordFilter( o.src );
    o.dst = dst.recordFilter( o.dst );

    let o2 = _.mapOnly( o, filesReflect.defaults );

    // o2.reflectMap = filePath;
    // delete o2.src;
    // delete o2.dst;

    result = hub.filesReflect( o2 );

    _.assert( !_.consequenceIs( result ), 'not implemented' );

  }
  catch( err )
  {
    debugger;
    throw _.err( err );
  }
  finally
  {
    if( !srcRegistered )
    src.providerUnregister();
    if( !dstRegistered )
    dst.providerUnregister();
    if( !srcRegistered && !dstRegistered )
    hub.finit();
  }

  return result;
}

var defaults = filesReflectTo_body.defaults = Object.create( filesReflectPrimeDefaults );

_.mapExtend( defaults, filesReflectAdvancedDefaults );

defaults.mandatory = 0;
defaults.dstProvider = null;
defaults.dst = '/';
defaults.src = '/';

let filesReflectTo = _.routineFromPreAndBody( filesReflectTo_pre, filesReflectTo_body );

//

function filesExtract_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { src : o }

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 );
  _.routineOptions( routine, o );
  // _.assert( path.isAbsolute( o.filePath ) );

  return o;
}

//

function filesExtract_body( o )
{
  let self = this;

  _.assert( o.dstProvider === null );

  if( o.dstProvider === null )
  o.dstProvider = new _.FileProvider.Extract();

  let result = self.filesReflectTo( o )

  _.assert( !_.consequenceIs( result ), 'not implemented' );

  return o.dstProvider;
}

var defaults = filesExtract_body.defaults = Object.create( filesReflectTo.defaults );

let filesExtract = _.routineFromPreAndBody( filesExtract_pre, filesExtract_body );

//

function filesFindSame_body( o )
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

      if( _.statsAreHardLinked( file1.stat, file2.stat ) )
      {
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
      self.logger.log( '. strLattersSpectresSimilarity', path1, path2 );
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
    similarMap = r.similarMaps[ path2 ] = r.similarMaps[ path2 ] || Object.create( null );
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
    _.arrayRemoveElementOnceStrictly( r.similarGroupsArray, src );

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
    // _.arrayRemoveElementOnceStrictly( r.similarGroupsArray, src );

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

_.routineExtend( filesFindSame_body, filesFindRecursive );

var defaults = filesFindSame_body.defaults;
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

let filesFindSame = _.routineFromPreAndBody( filesFind.pre, filesFindSame_body );

filesFindSame.having.aspect = 'entry';

// --
// delete
// --

function filesDelete_pre( routine, args )
{
  let self = this;
  args = _.longSlice( args );
  let o = self.filesFind.pre.call( self, routine, args );
  return o;
}

//

/*
qqq :
- add extended test routine
- cover option deletingEmptyDirs
- cover returned result, records of non-exitent files should not be in the result

- if deletingEmptyDirs : 1 then

/a/x
/a/b
/a/b/c
/a/b/c/f1
/a/b/c/f2

filesDelete [ /a/b/c/f1, /a/b/c/f2 ] should delete

/a/b
/a/b/c
/a/b/c/f1
/a/b/c/f2

*/

function filesDelete_body( o )
{
  let self = this;
  let provider = o.filter.effectiveFileProvider;
  let path = self.path;
  let con;
  let time;

  if( o.verbosity >= 1 )
  time = _.timeNow();

  if( !o.sync )
  con = new _.Consequence().take( null );

  _.assert( !o.includingTransient, 'Transient files should not be included' );
  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( _.numberIs( o.safe ) );
  _.assert( o.filter.formed === 5 );
  _.assert( arguments.length === 1 );

  /* qqq xxx : strange code! */

  let filePath = o.filter.filePathArrayGet( o.filter.formedFilePath );
  if( filePath.length === 1 && !o.deletingEmptyDirs )
  {
    filePath = filePath[ 0 ];
    if( !provider.fileExists( filePath ) )
    return end();

    /*
      reminder : masks are not applicable to stem file
    */

    if( provider.isTerminal( filePath ) )
    {
      let file = provider.record( filePath );
      file.isActual = true;
      file.isTransient = true;
      o.result.push( file );
      if( o.writing )
      fileDelete( file );

      if( o.sync )
      return end();
      else
      return con.then( () => end() );
    }
  }

  /* */

  let o2 = _.mapOnly( o, provider.filesFind.defaults );
  o2.verbosity = 0;
  o2.outputFormat = 'record';
  o2.includingTransient = 1;
  _.assert( !!o.includingDirs );
  _.assert( !!o.includingActual );
  _.assert( !o.includingTransient );
  _.assert( o.result === o2.result );

  /* */

  /* qqq : refactor please this brute-hack ( filesDelete_body )
    does it work at all??
    result array should not depend on option writing!
    deletingEmptyDirs should not delete files, but only change result array.
    handleWriting should be only deleting subroutine
    deletingEmptyDirs should goes between handleResult and handleWriting
  */

  if( o.sync )
  {
    provider.filesFind.body.call( provider, o2 )
    handleResult();
    if( o.deletingEmptyDirs )
    deleteEmptyDirs();
    if( o.writing )
    handleWriting();
    return end();
  }
  else
  {
    con.then( provider.filesFind.body.call( provider, o2 ) );
    con.then( () => handleResult() );
    if( o.deletingEmptyDirs )
    con.then( () => deleteEmptyDirs() );
    if( o.writing )
    con.then( () => handleWriting() );
    con.then( () => end() );
    return con;
  }

  /* - */

  function handleWriting()
  {
    for( let f = o.result.length-1 ; f >= 0 ; f-- )
    {
      let file = o.result[ f ];
      if( file.isActual && file.absolute !== '/' )
      fileDelete( file );
    }
    return true;
  }

  /* - */

  function handleResult()
  {
    for( let f1 = 0 ; f1 < o.result.length ; f1++ )
    {
      let file1 = o.result[ f1 ];

      if( file1.isActual /* && ( file1.isTransient || file1.isTerminal ) */ )
      {
        // if( file1.isTerminal )
        // continue;

        if( !file1.isDir )
        continue;

        if( file1.isTransient )
        {
          /* delete dir if:
            recursive : 0
            its empty
            terminals from dir will be included in result
          */

          if( !o.recursive )
          continue;
          if( o.recursive === 2 && o.includingTerminals )
          continue;
          if( provider.dirIsEmpty( file1.absolute ) )
          continue;
        }
      }

      o.result.splice( f1, 1 );
      f1 -= 1;

      if( !file1.isActual || !file1.isTransient )
      for( let f2 = f1 ; f2 >= 0 ; f2-- )
      {
        let file2 = o.result[ f2 ];
        // if( file2.relative === '.' ) /* ? */
        if( _.strBegins( file1.absolute, file2.absolute ) )
        {
          o.result.splice( f2, 1 );
          f1 -=1 ;
        }
      }
    }

    return true;
  }

  /* - */

  function end()
  {

    if( o.verbosity >= 1 )
    {
      let spentTime = _.timeNow() - time;
      let groupsMap = path.group({ keys : o.filter.filePath, vals : o.result });
      let textualReport = path.groupTextualReport
      ({
        explanation : ' - Deleted ',
        groupsMap : groupsMap,
        verbosity : o.verbosity,
        spentTime : spentTime,
      });

      if( textualReport )
      provider.logger.log( textualReport );
    }

    // if( o.verbosity >= 1 )
    // provider.logger.log( ' - filesDelete ' + o.result.length + ' files at ' + _.color.strFormat( path.commonTextualReport( _.mapKeys( o.filter.formedFilePath ) ), 'path' ) + ' in ' + _.timeSpent( time ) );

    if( o.outputFormat === 'absolute' )
    o.result = _.select( o.result, '*/absolute' );
    else if( o.outputFormat === 'relative' )
    o.result = _.select( o.result, '*/relative' );
    else _.assert( o.outputFormat === 'record' );

    return o.result;
  }

  /* */

  function fileDelete( file )
  {
    if( o.sync )
    _fileDelete( file );
    else
    con.then( () => _fileDelete( file ) );
  }

  /* */

  function _fileDelete( file )
  {
    let o2 =
    {
      filePath : file.absolute,
      throwing : o.throwing,
      // verbosity : o.verbosity-1,
      verbosity : 0,
      safe : o.safe,
      sync : o.sync,
    }

    let r = file.factory.effectiveFileProvider.fileDelete( o2 );
    if( r === null )
    if( o.verbosity )
    provider.logger.log( ' ! Cant delete ' + file.absolute );
    return r;
  }

  /* - */

  function deleteEmptyDirs()
  {
    if( !o.result.length )
    return true;

    let dirsPath = path.traceToRoot( o.result[ 0 ].dir );
    let factory = o.result[ 0 ].factory;
    let filesMap = Object.create( null );

    _.each( o.result, ( r ) => filesMap[ r.absolute ] = r );

    for( let d = dirsPath.length-1 ; d >= 0 ; d-- )
    {
      let dirPath = dirsPath[ d ];
      let files = provider.dirRead({ filePath : dirPath, outputFormat : 'absolute' });

      for( let f = files.length-1 ; f >= 0 ; f-- )
      {
        let file = files[ f ];
        if( !filesMap[ file ] )
        break;
        files.splice( f, 1 )
      }

      if( files.length )
      break;

      _.assert( !filesMap[ dirPath ] )

      let file = factory.record( dirPath );
      file.isActual = true;
      file.isTransient = true;

      filesMap[ dirPath ] = file;

      o.result.unshift( file )
    }

    return true;
  }

}

_.routineExtend( filesDelete_body, filesFind );

var defaults = filesDelete_body.defaults;
defaults.outputFormat = 'record';
defaults.sync = 1;
defaults.recursive = 2;
defaults.includingTransient = 0;
defaults.includingDirs = 1;
defaults.includingTerminals = 1;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;
defaults.allowingMissed = 1;
defaults.allowingCycled = 1;
defaults.verbosity = null;
defaults.maskPreset = 0;
defaults.throwing = null;
defaults.safe = null;
defaults.writing = 1;
defaults.deletingEmptyDirs = 0;

//

let filesDelete = _.routineFromPreAndBody( filesDelete_pre, filesDelete_body );
filesDelete.having.aspect = 'entry';

var defaults = filesDelete.defaults;
var having = filesDelete.having;

_.assert( !!defaults );
_.assert( !!having );
_.assert( !!filesDelete.defaults.includingDirs );

//

function filesDeleteTerminals_body( o )
{
  let self = this;

  _.assertRoutineOptions( filesDeleteTerminals_body, arguments );
  _.assert( o.includingTerminals );
  _.assert( !o.includingDirs );
  _.assert( !o.includingTransient, 'Transient files should not be included' );
  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( _.numberIs( o.safe ) );
  _.assert( arguments.length === 1 );

  /* */

  let o2 = _.mapOnly( o, self.filesFind.defaults );

  o2.onDown = _.arrayAppendElement( _.arrayAs( o.onDown ), handleDown );

  let files = self.filesFind.body.call( self, o2 );

  return files;

  /* */

  function handleDown( record )
  {
    if( o.writing )
    self.fileDelete({ filePath : record.absolute, throwing : o.throwing, verbosity : o.verbosity });
    // return record;
  }
}

_.routineExtend( filesDeleteTerminals_body, filesDelete );

var defaults = filesDeleteTerminals_body.defaults;

defaults.recursive = 2;
defaults.includingTerminals = 1;
defaults.includingDirs = 0;
defaults.includingTransient = 0;

let filesDeleteTerminals = _.routineFromPreAndBody( filesFind.pre, filesDeleteTerminals_body );

//

/*
qqq : add test coverage, extract pre and body, please
*/

function filesDeleteEmptyDirs_body( o )
{
  let self = this;

  /* */

  _.assertRoutineOptions( filesDeleteEmptyDirs_body, arguments );
  _.assert( !o.includingTerminals );
  _.assert( o.includingDirs );
  _.assert( !o.includingTransient );
  _.assert( o.recursive !== undefined && o.recursive !== null );

  /* */

  let o2 = _.mapOnly( o, self.filesFind.defaults );

  o2.onDown = _.arrayAppendElement( _.arrayAs( o.onDown ), handleDown );

  let files = self.filesFind.body.call( self, o2 );

  return files;

  /* */

  function handleDown( record )
  {

    try
    {

      let sub = self.dirRead( record.absolute );
      if( !sub )
      debugger;

      if( !sub.length )
      {
        // if( self.verbosity >= 1 )
        // self.logger.log( ' - deleted :', record.absolute );
        self.fileDelete({ filePath : record.absolute, throwing : o.throwing, verbosity : o.verbosity });
      }
    }
    catch( err )
    {
      if( o.throwing )
      throw _.err( err );
    }

    // return record;
  }

}

_.routineExtend( filesDeleteEmptyDirs_body, filesFind.body );

var defaults = filesDeleteEmptyDirs_body.defaults;
defaults.throwing = false;
defaults.verbosity = null;
defaults.outputFormat = 'absolute';
defaults.includingTerminals = 0;
defaults.includingDirs = 1;
defaults.includingTransient = 0;
defaults.recursive = 2;

let filesDeleteEmptyDirs = _.routineFromPreAndBody( filesFind.pre, filesDeleteEmptyDirs_body );

// --
// other find
// --

function softLinksBreak( o )
{
  let self = this;

  o = self.filesFind.pre.call( self, softLinksBreak, arguments );

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

  let files = self.filesFind.body.call( self, optionsFind );

  return files;
}

_.routineExtend( softLinksBreak, filesFind );

var defaults = softLinksBreak.defaults;
defaults.outputFormat = 'record';
defaults.breakingSoftLink = 1;
defaults.breakingTextLink = 0;
defaults.recursive = 2;

//

function softLinksRebase( o )
{
  let self = this;
  o = self.filesFind.pre.call( self, softLinksRebase, arguments );

  _.assert( o.outputFormat === 'record' );
  _.assert( !o.resolvingSoftLink );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {

    if( !record.isSoftLink )
    return;

    record.isSoftLink;
    let resolvedPath = self.pathResolveSoftLink( record.absolutePreferred );
    let rebasedPath = self.path.rebase( resolvedPath, o.oldPath, o.newPath );
    self.fileDelete({ filePath : record.absolutePreferred, verbosity : 0 });
    self.softLink
    ({
      dstPath : record.absolutePreferred,
      srcPath : rebasedPath,
      allowingMissed : 1,
      allowingCycled : 1,
    });

    _.assert( !!self.statResolvedRead({ filePath : record.absolutePreferred, resolvingSoftLink : 0 }) );

  });

  let files = self.filesFind.body.call( self, optionsFind );

  return files;
}

_.routineExtend( softLinksRebase, filesFind );

var defaults = softLinksRebase.defaults;
defaults.outputFormat = 'record';
defaults.oldPath = null;
defaults.newPath = null;
defaults.recursive = 2;
defaults.resolvingSoftLink = 0;

//

/*
qqq : optimize
*/

function filesHasTerminal( filePath )
{
  var self = this;
  _.assert( arguments.length === 1 );

  let terminal = false;

  self.filesFind
  ({
    filePath : filePath,
    includingStem : 1,
    includingDirs : 1,
    includingTerminals : 1,
    onUp : onUp,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
    recursive : 2
  })

  return terminal;

  /* */

  function onUp( record )
  {
    if( terminal )
    return false;
    if( record.stat && !record.isDir )
    terminal = record;
    return record;
  }
}

// --
// resolver
// --

function filesResolve( o )
{
  let self = this;
  let result;
  var o = _.routineOptions( filesResolve, arguments );

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
defaults.recursive = 2;
defaults.globPath = null;
defaults.translator = null;
defaults.outputFormat = 'record';

// var paths = filesResolve.paths;
// paths.globPath = null;

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

  recordsOrder,

  // find

  _filesFindPrepare0,
  _filesFindPrepare1,
  _filesFindFilterPrepare,

  filesFindSingle,
  filesFind,
  filesFindRecursive,
  filesGlob,

  filesFinder_functor,
  filesFinder,
  filesGlober,

  //

  filesFindGroups,
  filesRead,

  // reflect

  // filesCopyWithAdapter,

  _filesFiltersPrepare,
  _filesReflectPrepare,

  filesReflectEvaluate,
  filesReflectSingle,
  filesReflect,

  filesReflector_functor,
  filesReflector,

  filesReflectTo,
  filesExtract,

  // same

  filesFindSame,

  // delete

  filesDelete,

  filesDeleteTerminals,
  filesDeleteEmptyDirs,

  // other find

  softLinksBreak,
  softLinksRebase,
  filesHasTerminal,

  // resolver

  filesResolve,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,

}

//

_.classDeclare
({
  cls : Self,
  supplement : Supplement,
  withMixin : true,
  withClass : true,
});

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.shortName ] = Self;

_.assert( !!_.FileProvider.Find.prototype.filesDelete.defaults.includingDirs );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
