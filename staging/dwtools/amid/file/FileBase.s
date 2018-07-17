( function _FileBase_s_() {

'use strict'; /**/

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _global = _global_; var _ = _global_.wTools;

  _.include( 'wExecTools' );
  _.include( 'wProto' );

  _.include( 'wLogger' );
  _.include( 'wRegexpObject' );
  _.include( 'wFieldsStack' );
  _.include( 'wPath' );
  _.include( 'wConsequence' );
  _.include( 'wStringer' );
  _.include( 'wStringsExtra' );

}

var Self = _global_.wTools;
var _global = _global_; var _ = _global_.wTools;

_.assert( _global_.wFieldsStack );

Self.FileProvider = Self.FileProvider || Object.create( null );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
