jQuery(function($) {

    // Upload file when a new file was selected
    $('span.attachmentForm input[type="file"]').change(function(evt) {
        var $this = $(this);

        // target
        var web = $this.attr('data-targetweb');
        var topic = $this.attr('data-targettopic');
        if(!web || !topic) {
            window.console && console.log("Missing parameters: targetweb or targettopic");
            alert('Unable to upload file.');
            return;
        }

        var $parentForm = $this.closest('form');
        var $parent = $this.parent(); // direct parent for re-attaching
        var $span = $this.closest('span.attachmentField'); // the span holding the complete formfield

        // Create temporary form for uploading the file.
        // It will be submitted via jQuery.form because of good cross platform compatibility
        var $form = $('<form method="post" enctype="multipart/form-data"></form>');
        var uploadurl = foswiki.getPreference('SCRIPTURLPATH') + '/rest' + foswiki.getPreference('SCRIPTSUFFIX') + '/AttachmentFormfieldPlugin/upload';
        $form.attr('action', uploadurl);
        $('<input type="hidden" name="webtopic" />').val(web + '.' + topic).appendTo($form);
        $('<input type="hidden" name="filecomment" value="" />').appendTo($form);

        // Moving this input to the temporary form, because copying does not work across all platforms (<=IE9)
        $form.append($this);
        $this.attr('name', 'filepath'); // originally this input does not have a name, so it doesn't do anything outside this script

        if(window.StrikeOne) {
            StrikeOne.submit($parentForm.get(0));
              $('<input type="hidden" name="validation_key" />').val($parentForm.find('[name="validation_key"]').val()).appendTo($form);
        }

        // Progressbar
        // TODO: Make nicer; add text 'Uploading...'
        var $block = $('<div><div style="width:200px;border:1px solid white; padding: 1px"><div style="width:0px;height:5px;background-color:#EEE;" class="bar"></div></div></div>');
        var $bar = $block.find('.bar');

        // TODO: StrikeOne login dialog; general login dialog
        $form.ajaxForm({
            success:function(data, textStatus, jqXHR) {
                $parent.append($this);
                $this.removeAttr('name');
                $form.remove();
                var uploadedResponse = /OK (.*) uploaded/.exec(data);
                var uploadedFile;
                if(uploadedResponse) {
                    uploadedFile = uploadedResponse[1];
                    $span.find('input.oldFile').val(uploadedFile);
                } else {
                    alert(data);
                }
                // insert new StrikeOne
                $.ajax({
                    url:foswiki.getPreference('SCRIPTURLPATH') + '/rest' + foswiki.getPreference('SCRIPTSUFFIX') + '/RenderPlugin/render?text=<form method="post"></form>',
                    success: function(data, textStatus, jqXHR) {
                        var $data = $(data);
                        var key = $data.find('[name="validation_key"]:first').val();
                        if(key) {
                            $('[name="validation_key"]').val(key);
                        }
                    }
                });

                $span.find('.clearFile').closest('.jqButton').show();
                $span.find('.undoClearFile').closest('.jqButton').hide();
                $.unblockUI && $.unblockUI();
            },
            uploadProgress:function(evt, pos, total, percent) {
                if(percent) $bar.css('width', percent);
            },
            error:function(jqXHR, textStatus, errorThrown) {
                $parent.append($this);
                $this.removeAttr('name');
                $form.remove();
                $.unblockUI && $.unblockUI();
                alert(errorThrown);
            }
        });

        $.blockUI && $.blockUI({message: $block});
        $form.hide();
        $('body').append($form);
        $form.submit();

    });

    // Clear button
    $('span.attachmentField .clearFile').click(function() {
        var $this = $(this);

        var $span = $this.closest('span.attachmentField');
        var $input = $span.find('input');
				
		
        $input.val('');

        $this.closest('.jqButton').hide();

        return false;
    });
	
    // initialize (hide) undo buttons
    $('span.unhideByJs').find('.undoClearFile').closest('.jqButton').hide();
    $('span.unhideByJs').removeClass('foswikiHidden');
});
