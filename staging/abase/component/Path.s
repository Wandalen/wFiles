(function(){

'use strict';

var Self = wTools;
var _ = wTools;

//

  /**
   *
   * The URL component object.
   * @typedef {Object} UrlComponents
   * @property {string} protocol the URL's protocol scheme.;
   * @property {string} host host portion of the URL;
   * @property {string} port property is the numeric port portion of the URL
   * @property {string} pathname the entire path section of the URL.
   * @property {string} query the entire "query string" portion of the URL, including '?' character.
   * @property {string} hash property consists of the "fragment identifier" portion of the URL.

   * @property {string} url the whole URL
   * @property {string} hostname host portion of the URL, including the port if specified.
   * @property {string} origin protocol + host + port
   * @private
   */

var _urlComponents =
{

  /* atomic */

  protocol : null,
  host : null,
  port : null,
  pathname : null,
  query : null,
  hash : null,

  /* composite */

  url : null, /* whole */
  hostname : null, /* host + port */
  origin : null, /* protocol + host + port */

}

//

/*
http://www.site.com:13/path/name?query=here&and=here#anchor
2 - protocol
3 - hostname( host + port )
5 - pathname
6 - query
8 - hash
*/

  /**
   * Method parses URL string, and returns a UrlComponents object.
   * @example
   *
     var url = 'http://www.site.com:13/path/name?query=here&and=here#anchor'

     wTools.urlParse( url );

     // {
     //   protocol: 'http',
     //   hostname: 'www.site.com:13',
     //   pathname: undefined,
     //   query: '/path/name?query=here&and=here',
     //   hash: 'anchor',
     //   host: 'www.site.com',
     //   port: '13',
     //   origin: 'http://www.site.com:13'
     // }

   * @param {string} path Url to parse
   * @param {Object} options parse parameters
   * @param {boolean} options.atomicOnly If this parameter set to true, the `hostname` and `origin` will not be
      included into result
   * @returns {UrlComponents} Result object with parsed url components
   * @throws {Error} If passed `path` parameter is not string
   * @method urlParse
   * @memberof wTools
   */

var urlParse = function( path,options )
{
  var result = {};
  var parse = /((\w+):\/\/)?([^\/]+)(([^?#]+)$|[$\?#])?([^#]+)?(\#(.*))?/;
  var options = options || {};

  _.assert( _.strIs( path ) );

  var e = parse.exec( path );
  if( !e )
  throw _.err( 'urlParse :','cant parse :',path );

  result.protocol = e[ 2 ];
  result.hostname = e[ 3 ];
  result.pathname = e[ 5 ];
  result.query = e[ 6 ];
  result.hash = e[ 8 ];

  var h = result.hostname.split( ':' );
  result.host = h[ 0 ];
  result.port = h[ 1 ];

  if( options.atomicOnly )
  delete result.hostname
  else
  result.origin = result.protocol + '://' + result.hostname;

  return result;
}

urlParse.components = _urlComponents;

//

  /**
   * Assembles url string from components
   *
   * @example
   *
     var components =
       {
         protocol: 'http',
         host: 'www.site.com',
         port: '13',
         pathname: '/path/name',
         query: 'query=here&and=here',
         hash: 'anchor',
       };
     wTools.urlMake( UrlComponents );
     // 'http://www.site.com:13/path/name?query=here&and=here#anchor'
   * @param {UrlComponents} components Components for url
   * @returns {string} Complete url string
   * @throws {Error} If `components` is not UrlComponents map
   * @see {@link UrlComponents}
   * @method urlMake
   * @memberof wTools
   */

var urlMake = function( components )
{
  var result = '';

  _.assertMapOnly( components,_urlComponents );

  if( components.url )
  {
    _.assert( _.strIs( components.url ) && components.url );
    return components.url;
  }

  if( _.strIs( components ) )
  return components;
  else if( !_.mapIs( components ) )
  throw _.err( 'unexpected' );

  if( components.origin )
  {
    result += components.origin; // TODO: check fix appropriateness
  }
  else
  {

    if( components.protocol )
    result += components.protocol + ':';

    result += '//';

    if( components.hostname )
    result += components.hostname;
    else
    {
      if( components.host )
      result += components.host;
      else
      result += '127.0.0.1';
      result += ':' + components.port;
    }

  }

  if( components.pathname )
  result = _.urlJoin( result,components.pathname );

  _.assert( !components.query || _.strIs( components.query ) );
  if( components.query )
  result += '?' + components.query;

  if( components.hash )
  result += '#' + components.hash;

  return result;
}

urlMake.components = _urlComponents;

//

  /**
   * Complements current window url origin by components passed in options.
   * All components of current origin is replaced by appropriates components from options if they exist.
   * If `options.url` exists and valid, method returns it.
   * @example
   * // current url http://www.site.com:13/foo/baz
     var components =
     {
       pathname: '/path/name',
       query: 'query=here&and=here',
       hash: 'anchor',
     };
     var res = wTools.urlFor(options);
     // 'http://www.site.com:13/path/name?query=here&and=here#anchor'
   *
   * @param {UrlComponents} options options for resolving url
   * @returns {string} composed url
   * @method urlFor
   * @memberof wTools
   */

var urlFor = function( options )
{

  if( options.url )
  return urlMake( options );

  var url = urlServer();
  var o = _.mapScreens_( options,_urlComponents );

  if( !Object.keys( o ).length )
  return url;

  var parsed = urlParse( url,{ atomicOnly : 1 } );

  _.mapExtend( parsed,o );

  return urlMake( parsed );
}

//

  /**
   * Returns origin plus path without query part of url string.
   * @example
   *
     var path = 'https://www.site.com:13/path/name?query=here&and=here#anchor';
     wTools.urlDocument( path, { withoutProtocol: 1 } );
     // 'www.site.com:13/path/name'
   * @param {string} path url string
   * @param {Object} [options] urlDocument options
   * @param {boolean} options.withoutServer if true rejects origin part from result
   * @param {boolean} options.withoutProtocol if true rejects protocol part from result url
   * @returns {string} Return document url.
   * @method urlDocument
   * @memberof wTools
   */

var urlDocument = function( path,options )
{

  var options = options || {};

  if( path === undefined ) path = window.location.href;

  if( path.indexOf( '//' ) === -1 )
  {
    path = 'http:/' + ( path[0] === '/' ? '' : '/' ) + path;
  }

  var a = path.split( '//' );
  var b = a[ 1 ].split( '?' );

  //

  if( options.withoutServer )
  {
    var i = b[ 0 ].indexOf( '/' );
    if( i === -1 ) i = 0;
    return b[ 0 ].substr( i );
  }
  else
  {
    if( options.withoutProtocol ) return b[0];
    else return a[ 0 ] + '//' + b[ 0 ];
  }

}

//

  /**
   * Return origin (protocol + host + port) part of passed `path` string. If missed arguments, returns origin of
   * current document.
   * @example
   *
     var path = 'http://www.site.com:13/path/name?query=here'
     wTools.urlServer( path );
     // 'http://www.site.com:13/'
   * @param {string} [path] url
   * @returns {string} Origin part of url.
   * @method urlServer
   * @memberof wTools
   */

var urlServer = function( path )
{
  var a,b;

  if( path === undefined )
  path = window.location.href;

  if( path.indexOf( '//' ) === -1 )
  {
    if( path[0] === '/' ) return '/';
    a = [ '',path ]
  }
  else
  {
    a = path.split( '//' );
    a[ 0 ] += '//';
  }

  b = a[ 1 ].split( '/' );

  return a[ 0 ] + b[ 0 ] + '/';
}

//

  /**
   * Returns query part of url. If method is called without arguments, it returns current query of current document url.
   * @example
     var url = 'http://www.site.com:13/path/name?query=here&and=here#anchor',
     wTools.urlQuery( url ); // 'query=here&and=here#anchor'
   * @param {string } [path] url
   * @returns {string}
   * @method urlQuery
   * @memberof wTools
   */

var urlQuery = function( path )
{

  if( path === undefined ) path = window.location.href;

  if( path.indexOf( '?' ) === -1 ) return '';
  return path.split( '?' )[ 1 ];
}

//


  /**
   * Parse a query string passed as a 'query' argument. Result is returned as a dictionary.
   * The dictionary keys are the unique query variable names and the values are decoded from url query variable values.
   * @example
   *
     var query = 'k1=&k2=v2%20v3&k3=v4_v4';

     var res = wTools.urlDequery( query );
     // {
     //   k1: '',
     //   k2: 'v2 v3',
     //   k3: 'v4_v4'
     // },

   * @param {string} query query string
   * @returns {Object}
   * @method urlDequery
   * @memberof wTools
   */

var urlDequery = function( query )
{

  var result = {};
  var query = query || window.location.search.split('?')[1];
  if( !query || !query.length ) return result;
  var vars = query.split("&");
  for( var i=0;i<vars.length;i++ ){

    var w = vars[i].split("=");
    w[0] = decodeURIComponent( w[0] );
    if( w[1] === undefined ) w[1] = '';
    else w[1] = decodeURIComponent( w[1] );

    if( (w[1][0] == w[1][w[1].length-1]) && ( w[1][0] == '"') )
    w[1] = w[1].substr( 1,w[1].length-1 );

    if( result[w[0]] === undefined ) {
      result[w[0]] = w[1];
    } else if( wTools.strIs( result[w[0]] )){
      result[w[0]] = result[result[w[0]], w[1]]
    } else {
      result[w[0]].push(w[1]);
    }

  }

  return result;
}

//

var urlIs = function( url )
{

  var p =
    '^(https?:\\/\\/)?'                                     // protocol
    + '(\\/)?'                                              // relative
    + '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'    // domain
    + '((\\d{1,3}\\.){3}\\d{1,3}))'                         // ip
    + '(\\:\\d+)?'                                          // port
    + '(\\/[-a-z\\d%_.~+]*)*'                               // path
    + '(\\?[;&a-z\\d%_.~+=-]*)?'                            // query
    + '(\\#[-a-z\\d_]*)?$';                                 // anchor

  var pattern = new RegExp( p,'i' );
  return pattern.test( url );

}

//

var urlJoin = function()
{

  var result = _pathJoin( arguments,{ reroot : 0, url : 1 } );
  return result;
}

//

var urlNormalize = function( srcUrl )
{
  _.assert( _.strIs( srcUrl ) );
  _.assert( arguments.length === 1 );
  return srcUrl;
}

// --
// path
// --

  /**
   * Joins filesystem paths fragments or urls fragment into one path/url. Joins always with '/' separator.
   * @param {String[]} pathes Array with paths to join
   * @param {Object} options join options
   * @param {boolean} [options.url=false] If true, method returns url which consists from joined fragments, beginning
   * from element that contains '//' characters. Else method will join elements in `pathes` array as os path names.
   * @param {boolean} [options.reroot=false] If this parameter set to false (by default), method joins all elements in
   * `pathes` array, starting from element that begins from '/' character, or '*:', where '*' is any drive name. If it
   * is set to true, method will join all elements in array. Result
   * @returns {string}
   * @private
   * @throws {Error} If missed arguments.
   * @throws {Error} If elements of `pathes` are not strings
   * @throws {Error} If options has extra parameters.
   * @method _pathJoin
   * @memberof wTools
   */

var _pathJoin = function( pathes,options )
{
  var result = '';
  var optionsDefault =
  {
    reroot : 0,
    url : 0,
  }

  _.assertMapOnly( options,optionsDefault );

  for( var a = pathes.length-1 ; a >= 0 ; a-- )
  {

    if( !_.strIs( pathes[ a ] ) )
    throw _.err( 'wTools.pathJoin:','require strings as path, but #' + a + 'argument is ' + _.strTypeOf( pathes[ a ] ) );

    var src = pathes[ a ];

    if( !src ) continue;

    if( !options.url )
    src = src.replace( /\\/g,'/' );

    if( result && result[ 0 ] !== '/' ) result = '/' + result;
    if( result && src[ src.length-1 ] === '/' ) src = src.substr( 0,src.length-1 );

    result = src + result;

    //if( src.indexOf( '//' ) !== -1 ) return result;
    if( !options.reroot )
    {
      if( options.url )
      {
        if( src.indexOf( '//' ) !== -1 )
        return result;
      }
      else if( src[ 0 ] === '/' )
      {
        //if( options.url ) return urlServer( pathes[ 0 ] ) + result;
        //else
        return result;
      }
      if( !options.url )
      {
        if( src[ 1 ] === ':' ) return result;
      }
    }

  }

  //console.log( '_pathJoin',pathes,'->',result );

  return result;
}

//

  /**
   * Method joins all `paths` together, beginning from string that starts with '/', and normalize the resulting path.
   * @example
   * var res = wTools.pathJoin( '/foo', 'bar', 'baz', '.');
   * // '/foo/bar/baz'
   * @param {...string} paths path strings
   * @returns {string} Result path is the concatenation of all `paths` with '/' directory separator.
   * @throws {Error} If one of passed arguments is not string
   * @method pathJoin
   * @memberof wTools
   */

var pathJoin = function()
{
  var result = _pathJoin( arguments,{ reroot : 0 } );

  if( _.pathNormalize )
  result = _.pathNormalize( result );

  return result;
}

//

  /**
   * Method joins all `paths` strings together.
   * @example
   * var res = wTools.pathReroot( '/foo', '/bar/', 'baz', '.');
   * // '/foo/bar/baz/.'
   * @param {...string} paths path strings
   * @returns {string} Result path is the concatenation of all `paths` with '/' directory separator.
   * @throws {Error} If one of passed arguments is not string
   * @method pathReroot
   * @memberof wTools
   */

var pathReroot = function()
{
  var result = _pathJoin( arguments,{ reroot : 1 } );
  return result;
}

//

  /**
   * Returns the directory name of `path`.
   * @example
   * var path = '/foo/bar/baz/text.txt'
   * wTools.pathDir( path ); // '/foo/bar/baz'
   * @param {string} path path string
   * @returns {string}
   * @throws {Error} If argument is not string
   * @method pathDir
   * @memberof wTools
   */

var pathDir = function( path )
{

  if( !_.strIs( path ) )
  throw _.err( 'wTools.pathName:','require strings as path' );

  var i = path.lastIndexOf( '/' );

  if( i === -1 ) return path;

  if( path[ i - 1 ] === '/' ) return path;

  return path.substr( 0,i );
}

//

  /**
   * Returns file extension of passed `path` string.
   * If there is no '.' in the last portion of the path returns an empty string.
   * @example
   * wTools.pathExt( '/foo/bar/baz.ext' ); // 'ext'
   * @param {string} path path string
   * @returns {string} file extension
   * @throws {Error} If passed argument is not string.
   * @method pathExt
   * @memberof wTools
   */

var pathExt = function( path )
{

  if( !_.strIs( path ) ) throw _.err( 'wTools.pathName:','require strings as path' );

  var index = path.lastIndexOf('/');
  if( index >= 0 ) path = path.substr( index+1,path.length-index-1  );
  var index = path.lastIndexOf('.');
  if( index === -1 ) return '';
  index += 1;
  return path.substr( index,path.length-index );

}

//

  /**
   * Returns dirname + filename without extension
   * @example
   * wTools.pathExt( '/foo/bar/baz.ext' ); // '/foo/bar/baz'
   * @param {string} path Path string
   * @returns {string}
   * @throws {Error} If passed argument is not string.
   * @method pathPrefix
   * @memberof wTools
   */

var pathPrefix = function( path )
{

  if( !_.strIs( path ) ) throw _.err( 'wTools.pathName:','require strings as path' );

  var n = path.lastIndexOf( '/' );
  if( n === -1 ) n = 0;

  var parts = [ path.substr( 0,n ),path.substr( n ) ];

  var n = parts[ 1 ].indexOf( '.' );
  if( n === -1 ) n = parts[ 1 ].length;

  var result = parts[ 0 ] + parts[ 1 ].substr( 0, n );
  //console.log( 'pathPrefix',path,'->',result );
  return result;
}

//

  /**
   * Returns path name (file name).
   * @example
   * wTools.pathName( '/foo/bar/baz.asdf', { withoutExtension: 1 } ); // 'baz'
   * @param {string} path Path string
   * @param {Object} [options] options for getting name
   * @param {boolean} options.withExtension if this parameter set to true method return name with extension.
   * @param {boolean} options.withoutExtension if this parameter set to true method return name without extension.
   * @returns {string}
   * @throws {Error} If passed argument is not string
   * @method pathName
   * @memberof wTools
   */

var pathName = function( path,options )
{

  if( !_.strIs( path ) )
  throw _.err( 'wTools.pathName:','require strings as path' );

  var options = options || {};
  if( options.withoutExtension === undefined )
  {
    options.withoutExtension = options.withExtension !== undefined ? !options.withExtension : true;
  }

  var i = path.lastIndexOf( '/' );
  if( i !== -1 ) path = path.substr( i+1 );

  if( options.withoutExtension )
  {
    var i = path.lastIndexOf( '.' );
    if( i !== -1 ) path = path.substr( 0,i );
  }

  return path;
}

//

  /**
   * Return path without extension.
   * @example
   * wTools.pathWithoutExt( '/foo/bar/baz.txt' ); // '/foo/bar/baz'
   * @param {string} path String path
   * @returns {string}
   * @throws {Error} If passed argument is not string
   * @method pathWithoutExt
   * @memberof wTools
   */

var pathWithoutExt = function( path )
{

  var n = path.lastIndexOf( '.' );
  if( n === -1 ) n = path.length;
  var result = path.substr( 0, n );
  return result;
}

//

  /**
   * Replaces existing path extension on passed in `ext` parameter. If path has no extension, adds passed extension
      to path.
   * @example
   * wTools.pathChangeExt( '/foo/bar/baz.txt', 'text' ); // '/foo/bar/baz.text'
   * @param {string} path Path string
   * @param {string} ext
   * @returns {string}
   * @throws {Error} If passed argument is not string
   * @method pathChangeExt
   * @memberof wTools
   */

var pathChangeExt = function( path,ext )
{

  if( ext === '' ) return pathWithoutExt( path );
  else return pathWithoutExt( path ) + '.' + ext;

}

// --
// prototype
// --

var Proto =
{

  urlParse: urlParse,
  urlMake: urlMake,
  urlFor: urlFor,

  urlDocument: urlDocument,
  urlServer: urlServer,
  urlQuery: urlQuery,
  urlDequery: urlDequery,
  urlIs: urlIs,
  urlJoin: urlJoin,

  urlNormalize: urlNormalize,

  _pathJoin: _pathJoin,
  pathJoin: pathJoin,
  pathReroot: pathReroot,
  pathDir: pathDir,
  pathPrefix: pathPrefix,

  pathName: pathName,
  pathWithoutExt: pathWithoutExt,
  pathChangeExt: pathChangeExt,
  pathExt: pathExt,

  // var

  _urlComponents : _urlComponents,

};

_.mapExtend( wTools,Proto );

// export

if( typeof module !== 'undefined' )
{
  module['exports'] = Self;
}

})();
