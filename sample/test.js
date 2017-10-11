require( 'wConsequence' );

var con = new wConsequence().give();

var _ = wTools
debugger
con.doThen( () =>
{
	throw 1;
})
.ifNoErrorThen( () =>
{
	return 2;
})
.ifErrorThen( ( err ) =>
{
	console.log( _.errIs( err ) );
})