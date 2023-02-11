#######################################################################
#  clean_addr.pl - clean addresses in file using USPS Web lookup
#
#######################################################################


use strict;
use LWP::UserAgent;


#my $USPS_LOOKUP_URL = 'http://zip4.usps.com/zip4/zip4_responseA.jsp';
my $USPS_LOOKUP_URL = 'http://mwf:8088/';


#######################################################################


my $useragent = LWP::UserAgent->new;
$useragent->agent( "" );


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
    my ( $search_uid, $search_addr, $search_zip ) = split( /\|/ );


    $search_uid = strip( $search_uid );
    $search_addr = strip( $search_addr );
    $search_zip = strip( $search_zip );


    my $request = HTTP::Request->new( POST => $USPS_LOOKUP_URL );

    $request->content_type( 'application/x-www-form-urlencoded' );
    $request->content( "Selection=1&urbanization=&firm=&address=${search_addr}&address1=${search_addr}&address2=&city=&state=&zipcode=${search_zip}&Submit.x=18&Submit.y=8" );


    my $response = $useragent->request( $request );


    if ( $response->is_success ) {
        $_ = $response->content;

        if ( />(.*)<!--<Address Line\/>--><\/font>/ ) {
            my $address = strip( $1 );

            if ( />(.*) (..) &nbsp;(\d{5})-(\d{4}).*<!--<City-State-ZIP\/>-->/ ) {
                my $city = strip( $1 );
                my $state = strip( $2 );
                my $zip = strip( $3 );
                my $zip4 = strip( "$3-$4" );


                print "$search_uid|$address|$city|$state|$zip|$zip4\n";
            } else {
                print "$search_uid|||||\n";
            }
        } else {
            print "$search_uid|||||\n";
        }
    } else {
        print "$search_uid|||||\n";
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