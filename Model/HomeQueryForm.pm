# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Cal54::Model::HomeQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    my(@res) = shift->SUPER::execute_empty(@_);
    $self->internal_put_field(
	where => 'Boulder',
	when => 'now',
    );
    return @res;
}

sub internal_query_fields {
    return [
	[qw(where Line)],
	[qw(what Line)],
	[qw(when Line)],
    ];
}

1;
