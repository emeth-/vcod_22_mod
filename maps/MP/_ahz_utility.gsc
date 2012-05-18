playSoundinSpace (alias, origin)
{
	org = spawn ("script_origin",(0,0,1));
	org.origin = origin;
	org playsound (alias, "sounddone");
	org waittill ("sounddone");
	org delete();
}

printDebug (text) {
  if (getcvar("scr_cnq_debug") == "1" ) {
    iprintln ("DEBUG: " + text);
  }
}

///////////////////////////////////////////////////////////////////////////////
// Convert uppercase characters in a string to lowercase
// CODE COURTESY OF [MC]HAMMER's CODADM
toLower( str ) {
	return ( mapChar( str, "U-L" ) );
}

//
///////////////////////////////////////////////////////////////////////////////
// Convert lowercase characters in a string to uppercase
// CODE COURTESY OF [MC]HAMMER's CODADM
toUpper( str ) {
	return ( mapChar( str, "L-U" ) );
}

///////////////////////////////////////////////////////////////////////////////
// PURPOSE: 	Convert (map) characters in a string to another character.  A
//		conversion parameter determines how to perform the mapping.
// RETURN:	Mapped string
// CALL:	<str> = waitthread level.ham_f_utils::mapChar <str> <str>
// CODE COURTESY OF [MC]HAMMER's CODADM
mapChar( str, conv )
{
	if ( !isdefined( str ) || ( str == "" ) )
		return ( "" );

	switch ( conv )
	{
	  case "U-L":	case "U-l":	case "u-L":	case "u-l":
		from = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		to   = "abcdefghijklmnopqrstuvwxyz";
		break;
	  case "L-U":	case "L-u":	case "l-U":	case "l-u":
		from = "abcdefghijklmnopqrstuvwxyz";
		to   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		break;
	  default:
	  	return ( str );
	}

	s = "";
	for ( i = 0; i < str.size; i++ )
	{
		ch = str[ i ];

		for ( j = 0; j < from.size; j++ )
			if ( ch == from[ j ] )
			{
				ch = to[ j ];
				break;
			}

		s += ch;
	}

	return ( s );
}