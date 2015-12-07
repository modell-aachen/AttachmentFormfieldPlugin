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
    if($value) {
        $oldFile .= '<span class="unhideByJs">%BUTTON{"%MAKETEXT{"Clear file"}%" icon="cross" href="#" class="clearFile"}%</span>%CLEAR%'; # the js will unhide stuff
    }

    $value = "<span class='attachmentForm'>".'%MAKETEXT{"Upload file:"}%'."<noautolink><input type='file' ref='$this->{name}' name='filepath' data-targetweb='\%ENCODE{\"$targetWeb\" type=\"url\"}\%' data-targettopic='\%ENCODE{\"$targetTopic\" type=\"url\"}\%' value='$value' size='$size' /></noautolink></span>%JQREQUIRE{\"blockui,form\"}%";
	my $ret = "<span class='attachmentField'>$oldFile<br />$value</span>";
	
	if(Foswiki::Func::topicExists($targetWeb,$targetTopic) ne 1){
		$value = "<noautolink><span>".'%MAKETEXT{"Please save first"}%'."</span></noautolink>";
		$ret = $value;
	}

    Foswiki::Func::addToZone('script', 'Form::Attachment::script', <<SCRIPT, 'JQUERYPLUGIN::FOSWIKI,jsi18nCore,JQUERYPLUGIN::FORM,JQUERYPLUGIN::BLOCKUI');
<script type="text/javascript" src="%PUBURLPATH%/%SYSTEMWEB%/AttachmentFormfieldPlugin/upload.js"></script>
SCRIPT

    return (
        '',
        $ret
    );
}

sub renderForDisplay {
    my ($this, $topicObject, $value) = @_;

	return unless $value;
		
	my $ret='<a class="attachmentField" href="%PUBURLPATH%/%WEB%/%TOPIC%/'.$value.'">'.$value.'</a>';
	my @attributes  = split(/ /, $this->{value});
	if ( scalar grep { $_ eq "image" } @attributes ) {
		my @size = split(/x/, $this->{size});
		my $width = $size[0] || "auto";
		my $height = $size[1] || "auto";
		$ret = '<img width="'.$width.'" height="'.$height.'" class="attachmentField" src="%PUBURLPATH%/%WEB%/%TOPIC%/'.$value.'"/>';
	}

    return (
        '',
        $ret
    );
}
sub isDeleteAttachment {
 return shift->{attributes} =~ /del/
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

