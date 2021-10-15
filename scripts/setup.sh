# Create opam switch
opam switch create $SWITCH $COMPILER
# Import dependencies
opam switch import --yes env/switch.export
# Update environment
eval $(opam env)
