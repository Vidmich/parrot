# Copyright (C) 2004-2010, Parrot Foundation.

# $Id$

=head1 NAME

Parrot::Pmc2c - PMC to C Code Generation

=head1 SYNOPSIS

    use Parrot::Pmc2c;

=head1 DESCRIPTION

C<Parrot::Pmc2c> is used by F<tools/build/pmc2c.pl> to generate C code from PMC files.

=head2 Functions

=over

=cut

package Parrot::Pmc2c::PMC::WB;
use strict;
use warnings;
use base qw( Parrot::Pmc2c::PMC );

use Parrot::Pmc2c::Emitter ();
use Parrot::Pmc2c::PMCEmitter ();
use Parrot::Pmc2c::Method ();
use Parrot::Pmc2c::UtilFunctions qw( return_statement );
use Text::Balanced 'extract_bracketed';

=item C<new($type)>

Create a WB version of the PMC

=cut

sub new {
    my ( $class, $parent ) = @_;
    my $classname = ref($parent) || $class;

    my $self = bless Parrot::Pmc2c::PMC->new(
        {
            # prepend self to parent
            parents => [ $parent->name, @{ $parent->parents } ],
            # copy flags,
            flags      => $parent->get_flags,
            # and alias vtable
            vtable     => $parent->vtable,
            # set pmcname
            name       => $parent->name . "_wb",
            # set parentname
            parentname => $parent->name,
        }
    ), $classname;

    {

      # autogenerate for nonstandard types
      # (TT #1240: is this appropriate or do we want them to each be
      # explicitly cleared to have RO ?)
        no strict 'refs';
        if ( !@{ ref($self) . '::ISA' } ) {
            @{ ref($self) . '::ISA' } = "Parrot::Pmc2c::PMC::WB";
        }
    }

    my $pmcname = $parent->name;
    foreach my $vt_method ( @{ $self->vtable->methods } ) {
        my $name = $vt_method->name;

        #warn "$pmcname $name\n";
        # Generate WB variant
        next unless exists $parent->{has_method}{$name}
                    && $parent->vtable_method_does_write($name);

        # Get parameters.      strip type from param
        my $parameters = join ', ',
                         map { s/(\s*\S+\s*\*?\s*)//; $_ }
                         split (/,/, $vt_method->parameters);
        $parameters = ', ' . $parameters if $parameters;

        my $method = Parrot::Pmc2c::Method->new(
            {
                name        => $name,
                parent_name => $parent->name,
                return_type => $vt_method->return_type,
                parameters  => $vt_method->parameters,
                type        => Parrot::Pmc2c::Method::VTABLE,
            }
        );
        my $ret     = return_statement($method);
        my $body    = <<"EOC";
        /* Switch vtable here and redispatch to original method */
        VTABLE *t = _self->vtable;
        PARROT_ASSERT(_self->vtable != _self->vtable->wb_variant_vtable);
        _self->vtable = _self->vtable->wb_variant_vtable;
        _self->vtable->wb_variant_vtable = t;
        PARROT_ASSERT(_self->vtable != _self->vtable->wb_variant_vtable);
        PARROT_GC_WRITE_BARRIER(interp, _self);
        return _self->vtable->$name(interp, _self $parameters);
EOC

        # don't return after a Parrot_ex_throw_from_c_args
        $method->body( Parrot::Pmc2c::Emitter->text($body) );
        $self->add_method($method);
    }

    return $self;
}


1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
