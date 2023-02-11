#######################################################################
#  get_phone.pl - lookup phone numbers for people using AnyWho
#######################################################################


use strict;
use LWP::UserAgent;


my $ANYWHO_LOOKUP_URL = 'http://www.anywho.com/qry/wp_fap';
my $ANYWHO_SESSION_URL = 'http://www.anywho.com/qry/getc.pl';


#######################################################################


my $useragent = LWP::UserAgent->new;
$useragent->agent( "" );


my $request;
my $response;


#
#  retrieve a new session id
#
my $session_id;

$request = HTTP::Request->new( GET => $ANYWHO_SESSION_URL );

$response = $useragent->request( $request );

if ( $response->is_success ) {
    $_ = $response->content;

    if ( /e\.value = "(.*)"/mi ) {
        $session_id = strip( $1 );
    } else {
        die;
    }
} else {
    die;
}


#
#  make sure user specified input file on command-line;
#  otherwise, try to read from standard input
#
if ( $#ARGV == 0 ) {
    open( ADDR, "<$ARGV[ 0 ]" ) || die "Unable to open file $ARGV[ 0 ].\n";
} else {
    open( ADDR, "<&STDIN" );
}


while ( <ADDR> ) {
    my ( $search_uid, $search_fname, $search_lname, $search_addr, $search_zip ) = split( /\|/ );


    $search_uid = strip( $search_uid );
    $search_fname = strip( $search_fname );
    $search_lname = strip( $search_lname );
    $search_addr = strip( $search_addr );
    $search_zip = strip( $search_zip );


    $request = HTTP::Request->new( POST => $ANYWHO_LOOKUP_URL );

    $request->content_type( 'application/x-www-form-urlencoded' );
    $request->content( "c=${session_id}&lastname=${search_lname}&firstname=${search_fname}&street=&city=&state=&zip=${search_zip}&btnsubmit=" );


    $response = $useragent->request( $request );


    if ( $response->is_success ) {
        $_ = $response->content;
#print $_;

        if ( /<div class="phone">\s*(.*)\s*<\/div>/mi ) {
            my $phone = strip( $1 );

            print "$search_uid|$phone\n";
        } else {
            print "$search_uid|\n";
        }
    } else {
        print "$search_uid|\n";
    }
}

close( ADDR );


#######################################################################


#
#  strip whitespace
#
sub strip {
    my $str = shift;

    $str =~ s/^\s+//;
    $str =~ s/\s+$//;

    return $str;
}