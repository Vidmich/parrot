# Copyright (C) 2010, Parrot Foundation.
# $Id$

=head1 NAME

PAST::Transformer::Dynamic - A PAST::Transformer subclass that doesn't require creating a new subclass to change its behavior.

=head1 DESCRIPTION

PAST::Transformer's behavior can only be customized by subclassing. This subclass determines its behavior based on Subs stored in its attributes, allowing modification of its behavior without creating a new class, including at runtime.

=cut

.sub 'onload' :anon :init :load
    load_bytecode 'PAST/Transformer.pbc'
    load_bytecode 'PAST/Walker/Dynamic.pbc'
    load_bytecode 'P6object.pbc'
    .local pmc p6meta, walkdyn, trans
    p6meta = new 'P6metaclass'
    walkdyn = get_class ['PAST'; 'Walker'; 'Dynamic']
    trans = get_class ['PAST'; 'Transformer']
    $S0 = 'PAST::Transformer::Dynamic'
    $P0 = p6meta.'new_class'($S0, 'parent'=> walkdyn)
    p6meta.'add_parent'($P0, trans)
.end

=head1 PAST::Transformer::Dynamic

It has the same attributes as PAST::Walker::Dynamic.

They should behave just like specializations of 'walk' for PAST::Transformer subclasses, taking a walker and a PAST::Node and returning the replacement node or null to delete it.

=cut

.namespace ['PAST'; 'Walker']

.sub 'walk' :multi(['PAST'; 'Transformer'; 'Dynamic'], ['PAST'; 'Block'])
    .param pmc walker
    .param pmc node
    $P0 = getattribute walker, 'block'
    unless null $P0 goto has_handler
    $P1 = 'walkChildren'(walker, node)
    'replaceChildren'(node, $P1)
    .return (node)
has_handler:
    .tailcall $P0(walker, node)
.end

.sub 'walk' :multi(['PAST'; 'Transformer'; 'Dynamic'], ['PAST'; 'Op'])
    .param pmc walker
    .param pmc node
    $P0 = getattribute walker, 'op'
    unless null $P0 goto has_handler
    $P1 = 'walkChildren'(walker, node)
    'replaceChildren'(node, $P1)
    .return (node)
has_handler:
    .tailcall $P0(walker, node)
.end

.sub 'walk' :multi(['PAST'; 'Transformer'; 'Dynamic'], ['PAST'; 'Stmts'])
    .param pmc walker
    .param pmc node
    $P0 = getattribute walker, 'stmts'
    unless null $P0 goto has_handler
    $P1 = 'walkChildren'(walker, node)
    'replaceChildren'(node, $P1)
    .return (node)
has_handler:
    .tailcall $P0(walker, node)
.end

.sub 'walk' :multi(['PAST'; 'Transformer'; 'Dynamic'], ['PAST'; 'Val'])
    .param pmc walker
    .param pmc node
    $P0 = getattribute walker, 'val'
    unless null $P0 goto has_handler
    $P1 = 'walkChildren'(walker, node)
    'replaceChildren'(node, $P1)
    .return (node)
has_handler:
    .tailcall $P0(walker, node)
.end

.sub 'walk' :multi(['PAST'; 'Transformer'; 'Dynamic'], ['PAST'; 'Var'])
    .param pmc walker
    .param pmc node
    $P0 = getattribute walker, 'var'
    unless null $P0 goto has_handler
    $P1 = 'walkChildren'(walker, node)
    'replaceChildren'(node, $P1)
    .return (node)
has_handler:
    .tailcall $P0(walker, node)
.end

.sub 'walk' :multi(['PAST'; 'Transformer'; 'Dynamic'], ['PAST'; 'VarList'])
    .param pmc walker
    .param pmc node
    $P0 = getattribute walker, 'varlist'
    unless null $P0 goto has_handler
    $P1 = 'walkChildren'(walker, node)
    'replaceChildren'(node, $P1)
    .return (node)
has_handler:
    .tailcall $P0(walker, node)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir: