"""
Utility script to insert the compiled code into asyncstdlib

For testing only!
"""
import asyncstdlib


for module in (asyncstdlib._core,):
    with open(module.__file__, "ab") as module_source:
        _, _, name = module.__name__.partition(".")
        module_source.write(
            b"from asyncstdlib_cy.%(s) import *\n" % name.encode("ascii")
        )
