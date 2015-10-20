# See bottom of file for default license and copyright information

package Foswiki::Plugins::AttachmentFormfieldPlugin;

use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version
use Encode;

our $VERSION = '1.0';
our $RELEASE = '1.0';

our $SHORTDESCRIPTION = 'Manage attachments in a formfield.';

our $NO_PREFS_IN_TOPIC = 1;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerRESTHandler(
        'upload', \&_restUpload,
        http_allow => 'POST' );
}

# This handler behaves as /bin/upload wiht 'noredirect' option:
#    * Normalize the file name
#    * Attach the file
#    * return the new file name
# However /bin/upload does not work as expected, when the file name changes (the exception is not caught) and a different method is used for normalization.
#
sub _restUpload {
    my ($session, $plugin, $verb, $response) = @_;

    my $query = Foswiki::Func::getCgiQuery();

    my $webtopic = $query->param('webtopic');
    return 'ERROR: Missing webtopic' unless $webtopic;
    my ( $web, $topic ) = Foswiki::Func::normalizeWebTopicName( undef, $webtopic );

    return "ERROR: webtopic '$web.$topic' does not exist" unless Foswiki::Func::topicExists( $web, $topic );

    my $fileComment = $query->param('filecomment') || '';
    my $filePathParam = $query->param('filepath');
    my $fileName = $query->param('filename');
    if ( $filePathParam && !$fileName ) {
        $filePathParam =~ m#([^/\\]*$)#;
        $fileName = $1;
    }
    return 'ERROR: Missing filename' unless $fileName;

    my $stream = $query->upload('filepath');
    return 'ERROR: Missing stream' unless $stream;

    my @stats = stat $stream;
    my $fileSize = $stats[7];
    my $fileDate = $stats[9];

    my $attachName = Foswiki::Func::sanitizeAttachmentName($fileName);
    Foswiki::Func::saveAttachment(
        $web,
        $topic,
        $attachName,
        {
            stream => $stream,
            filesize => $fileSize,
            filedate => $fileDate,
            filecomment => $fileComment
        }
    );

    return "OK $attachName uploaded";
}


1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2014 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
