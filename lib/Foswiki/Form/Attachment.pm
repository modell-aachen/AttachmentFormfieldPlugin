# See bottom of file for license and copyright information
package Foswiki::Form::Attachment;

use strict;
use warnings;

use Foswiki::Form::FieldDefinition ();
use Foswiki::Plugins ();
our @ISA = ('Foswiki::Form::FieldDefinition');

sub new {
    my $class = shift;
    my $this = $class->SUPER::new(@_);

    return $this;
}

sub finish {
    my $this = shift;
    $this->SUPER::finish();
}

sub getDefaultValue {
    return '';
}

sub renderForEdit {
    my ($this, $topicObject, $value) = @_;

    my $request = Foswiki::Func::getRequestObject();
    if($request->param('templatetopic')) {
        undef $value;
    }

    my $size = 50; # TODO

    my $targetWeb = $topicObject->web;
    my $targetTopic = $topicObject->topic;

    $value ||= '';

    my $oldFile = $value;
    $oldFile = "<noautolink><input type='text' name='$this->{name}' value='$oldFile' readonly='readonly' size='$size' class='oldFile' /></noautolink>";
    if($this->{value} =~ m#\bclearable\s*=\s*(?:1|on|yes)\b#) {
        # TODO: beforeSaveHandler needs to check if file was cleared when this option is off
        # TODO: Actually delete file?
        $oldFile .= '<span class="unhideByJs foswikiHidden">%BUTTON{"%MAKETEXT{"Clear file"}%" icon="cross" href="#" class="clearFile"}%%BUTTON{"%MAKETEXT{"undo clear file"}%" icon="arrow_undo" href="#" class="undoClearFile"}%</span>%CLEAR%'; # the js will unhide stuff
    }

    $value = "<span class='attachmentForm'>".'%MAKETEXT{"Upload a new file:"}%'."<noautolink><input type='file' data-targetweb='\%ENCODE{\"$targetWeb\" type=\"url\"}\%' data-targettopic='\%ENCODE{\"$targetTopic\" type=\"url\"}\%' value='$value' size='$size' /></noautolink></span>%JQREQUIRE{\"blockui,form\"}%";

    Foswiki::Func::addToZone('script', 'Form::Attachment::script', <<SCRIPT, 'JQUERYPLUGIN::FOSWIKI,jsi18nCore,JQUERYPLUGIN::FORM,JQUERYPLUGIN::BLOCKUI');
<script type="text/javascript" src="%PUBURLPATH%/%SYSTEMWEB%/AttachmentFormfieldPlugin/upload.js"></script>
SCRIPT

    return (
        '',
        "<span class='attachmentField'>$oldFile<br />$value</span>"
    );
}


    1;
    __END__
    Foswiki - The Free and Open Source Wiki, http://foswiki.org/

    Copyright (C) 2013-2014 Foswiki Contributors. Foswiki Contributors
    are listed in the AUTHORS file in the root of this distribution.
    NOTE: Please extend that file, not this notice.

    Additional copyrights apply to some or all of the code in this
    file as follows:

    Copyright (C) 2001-2007 TWiki Contributors. All Rights Reserved.
    TWiki Contributors are listed in the AUTHORS file in the root
    of this distribution. NOTE: Please extend that file, not this notice.

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version. For
    more details read LICENSE in the root of this distribution.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    As per the GPL, removal of this notice is prohibited.

