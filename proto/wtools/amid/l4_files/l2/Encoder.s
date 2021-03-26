( function _Namespace_s_()
{

'use strict';

/**
 * @namespace Tools.files.encoder
 * @module Tools/mid/Files
 */

const _global = _global_;
const _ = _global_.wTools;
_.files = _.files || Object.create( null );
const Self = _.files.encoder = _.files.encoder || Object.create( null );

// --
// encoder
// --

function normalize( o )
{

  o = _.routineOptions( normalize, o );
  if( _.strIs( o.exts ) )
  o.exts = [ o.exts ];
  else if( o.exts === null )
  o.exts = [];

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o.feature ) );
  _.assert( _.longIs( o.exts ) );
  _.assert( o.feature.reader || o.feature.writer );

  let collectionMap = o.feature.reader ? _.files.ReadEncoders : _.files.WriteEncoders;

  if( o.name === null && o.exts.length )
  o.name = nameGenerate();

  _.assert( _.strDefined( o.name ) );
  // _.assert( _.routineIs( o.onData ) ); /* zzz : implement */

  return o;

  /* */

  function nameGenerate()
  {
    let name = o.exts[ 0 ];
    let counter = 2;
    while( collectionMap[ name ] !== undefined )
    {
      debugger;
      name = o.exts[ 0 ] + '.' + counter;
    }
    return name;
  }

}

normalize.defaults =
{

  name : null,
  exts : null,
  feature : null,
  gdf : null,
  // forConfig : null, /* zzz : remove */

  onBegin : null,
  onEnd : null,
  onError : null, /* zzz : remove */
  onData : null,

}

//

function register( o, ext )
{

  o = _.files.encoder.normalize( o );

  let collectionMap = o.feature.reader ? _.files.ReadEncoders : _.files.WriteEncoders;
  let name = ext ? ext : o.name;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( ext === undefined || _.strDefined( ext ) );

  if( collectionMap[ name ] !== undefined )
  {
    let encoder2 = collectionMap[ o.name ];
    if( encoder2 === o )
    return o;
    if( encoder2.feature.default )
    return o;
    if( !o.feature.default )
    return o;
  }

  // console.log( `Registered encoder::${name}` );

  collectionMap[ name ] = o;

  return o;
}

register.defaults =
{

  ... normalize.defaults,

}

//

function _fromGdf( gdf )
{

  _.assert( gdf.ext.length );
  _.assert( gdf instanceof _.gdf.Encoder );

  let encoder = Object.create( null );
  encoder.gdf = gdf;
  encoder.exts = gdf.ext.slice();

  // if( gdf.forConfig ) /* zzz : remove */
  // encoder.forConfig = true;

  encoder.feature = Object.create( null );
  if( gdf.feature.config )
  encoder.feature.config = true;
  // if( gdf.default )
  if( gdf.feature.default )
  encoder.feature.default = true;

  return encoder;
}

//

let _writerFromGdfCache = new HashMap;
function writerFromGdf( gdf )
{

  if( _writerFromGdfCache.has( gdf ) )
  return _writerFromGdfCache.get( gdf );

  let encoder = _.files.encoder._fromGdf( gdf );
  encoder.feature.writer = true;

  encoder.onBegin = function( op )
  {
    let encoded = op.encoder.gdf.encode({ data : op.operation.data, params : op.operation });
    op.operation.data = encoded.out.data;
    if( encoded.out.format === 'string' || encoded.out.format === 'string.utf8' || encoded.out.format === 'utf8.string' )
    op.operation.encoding = 'utf8';
    else
    op.operation.encoding = encoded.out.format;
  }

  _writerFromGdfCache.set( gdf, encoder );
  return encoder;
}

//

let _readerFromGdfCache = new HashMap;
function readerFromGdf( gdf )
{

  if( _readerFromGdfCache.has( gdf ) )
  return _readerFromGdfCache.get( gdf );

  let encoder = _.files.encoder._fromGdf( gdf );
  encoder.feature.reader = true;
  // let expectsString = _.longHas( gdf.inFormat, 'string' );
  let expectsString = gdf.inFormatSupports( 'string' );
  // if( expectsString )
  // debugger;

  encoder.onBegin = function( op )
  {
    if( expectsString )
    op.operation.encoding = 'utf8';
    else
    op.operation.encoding = op.encoder.gdf.inFormat[ 0 ];
  }

  encoder.onEnd = function( op ) /* zzz : should be onData */
  {
    let decoded = op.encoder.gdf.encode({ data : op.data, params : op.operation });
    op.data = decoded.out.data;
  }

  _readerFromGdfCache.set( gdf, encoder );
  return encoder;
}

//

function fromGdfs()
{
  _.assert( _.Gdf, 'module::Gdf is required to generate encoders!' );
  _.assert( _.mapIs( _.gdf.inMap ) );
  _.assert( _.mapIs( _.gdf.outMap ) );

  for( let k in _.gdf.inOutMap )
  {
    if( !_.strHas( k, 'structure' ) )
    continue;
    var defaults = _.filter_( null, _.gdf.inOutMap[ k ], ( c ) => c.feature.default ? c : undefined );
    if( defaults.length > 1 )
    {
      debugger;
      throw _.err( `Several default converters for '${k}' in-out combination:`, _.select( defaults, '*/name' )  );
    }
  }

  let writeGdf = _.gdf.inMap[ 'structure' ];
  let readGdf = _.gdf.outMap[ 'structure' ];

  let WriteEndoders = Object.create( null );
  let ReadEncoders = Object.create( null );

  writeGdf.forEach( ( gdf ) =>
  {
    let encoder = _.files.encoder.writerFromGdf( gdf );
    _.assert( gdf.ext.length );
    _.each( gdf.ext, ( ext ) =>
    {
      // debugger;
      if( !WriteEndoders[ ext ] || gdf.feature.default )
      _.files.encoder.register( encoder, ext );
    })
  })

  /* */

  readGdf.forEach( ( gdf ) =>
  {
    let encoder = _.files.encoder.readerFromGdf( gdf );
    _.assert( gdf.ext.length );
    _.each( gdf.ext, ( ext ) =>
    {
      // debugger;
      if( !ReadEncoders[ ext ] || gdf.feature.default )
      _.files.encoder.register( encoder, ext );
    })
  })

  /* */

  for( let k in _.files.ReadEncoders )
  {
    let gdf = _.files.ReadEncoders[ k ].gdf;
    if( gdf )
    if( !_.longHas( readGdf, gdf ) || !_.longHas( gdf.ext, k ) )
    {
      _.assert( 0, 'not tested' );
      delete _.files.ReadEncoders[ k ]
    }
  }

  for( let k in _.files.WriteEncoders )
  {
    let gdf = _.files.WriteEncoders[ k ].gdf;
    if( gdf )
    if( !_.longHas( writeGdf, gdf ) || !_.longHas( gdf.ext, k ) )
    {
      // _.assert( 0, 'not tested' );
      delete _.files.WriteEncoders[ k ];
    }
  }

  /* */

  _.assert( _.mapIs( _.files.ReadEncoders ) );
  _.assert( _.mapIs( _.files.WriteEncoders ) );

  Object.assign( _.files.ReadEncoders, ReadEncoders );
  Object.assign( _.files.WriteEncoders, WriteEndoders );
}

//

function deduce( o )
{
  let result = [];

  o = _.routineOptions( deduce, arguments );

  if( o.filePath && !o.ext )
  o.ext = _.path.ext( o.filePath );
  if( o.ext )
  o.ext = o.ext.toLowerCase();

  _.assert( _.strIs( o.ext ) || o.ext === null );
  _.assert( _.mapIs( o.feature ) );
  _.assert( o.feature.writer || o.feature.reader );
  _.assert( _.mapIs( _.gdf.inMap ) );
  _.assert( _.mapIs( _.gdf.outMap ) );

  let fromMethodName = o.feature.writer ? 'writerFromGdf' : 'readerFromGdf';
  let typeMap = o.feature.writer ? _.gdf.outMap : _.gdf.inMap;
  let encodersMap = o.feature.writer ? _.files.WriteEncoders : _.files.ReadEncoders;

  if( o.ext )
  if( encodersMap[ o.ext ] )
  {
    let encoder = encodersMap[ o.ext ];
    _.assert( _.objectIs( encoder ), `Write encoder ${o.ext} is missing` );
    _.assert( _.longHas( encoder.exts, o.ext ) );
    _.arrayAppendOnce( result, encoder );
  }

  result = filterAll( result );

  if( !o.single || !result.length )
  for( let i = 0 ; i < _.files.encoder.gdfTypesForFiles.length ; i++ )
  {
    let type = _.files.encoder.gdfTypesForFiles[ i ];
    if( !typeMap[ type ] )
    continue;
    for( let i2 = 0 ; i2 < typeMap[ type ].length ; i2++ )
    {
      let gdf = typeMap[ type ][ i2 ];
      let o2 = _.mapBut_( null, o, [ 'single', 'returning', 'feature' ] );
      let methodName = o.feature.reader ? 'supportsInput' : 'supportsOutput';
      let supports = gdf[ methodName ]( o2 );
      if( supports )
      _.arrayAppendOnce( result, _.files.encoder[ fromMethodName ]( gdf ) );
    }
  }

  result = filterAll( result );

  if( o.single )
  {

    if( result.length > 1 )
    _.filter_( result, ( encoder ) => encoder.feature.default ? encoder : undefined );

    _.assert
    (
      result.length >= 1,
      () => `Found no reader for format:${o.format} ext:${o.ext} filePath:${o.filePath}.`
    );
    _.assert
    (
      result.length <= 1,
      () => `Found ${result.length} readers for format:${o.format} ext:${o.ext} filePath:${o.filePath}, but need only one.`
    );
    if( o.returning === 'name' )
    return result[ 0 ].name;
    else
    return result[ 0 ];
  }

  debugger;
  if( o.returning === 'name' )
  return result.map( ( encoder ) => encoder.name );
  else
  return result;

  function filterAll( encoders )
  {
    if( o.feature === null )
    return encoders;
    if( _.mapKeys( o.feature ).length === 0 )
    return encoders;
    return _.filter_( encoders, ( encoder ) =>
    {
      let satisfied = _.objectSatisfy
      ({
        src : encoder.feature,
        template : o.feature,
        levels : 1,
        strict : false,
      });
      if( satisfied )
      return encoder;
    });
  }
}

deduce.defaults =
{
  data : null,
  format : null,
  filePath : null,
  ext : null,
  feature : null,
  single : 1,
  returning : 'name',
}

// --
// declaration
// --

let gdfTypesForFiles = [ 'string', 'buffer.raw', 'buffer.bytes', 'buffer.node' ];

let Extension =
{

  // encoder

  normalize,
  register,
  _fromGdf,
  writerFromGdf,
  readerFromGdf,
  fromGdfs,
  deduce,

  // fields

  gdfTypesForFiles,

}

_.mapSupplement( Self, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
